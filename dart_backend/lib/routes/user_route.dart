import 'package:alfred/alfred.dart';
import 'package:dart_backend/utils/crud_util.dart';
import 'package:dart_backend/utils/log_util.dart';
import 'package:dart_backend/utils/request_helper.dart';
import 'package:dart_backend/utils/validator.dart';
import '../config/db.dart';
import '../config/redis.dart';
import '../config/jwt.dart';
import '../utils/result.dart';

void userRoutes(Alfred app) {
  // 登录
  app.post('/user/login1', (req, res) async {
    final reqBody = await req.body;
    print('Login request body: 请求参数=====: req=${req.runtimeType}=$reqBody'); // 打印请求对象类型，确认是否为AlfredRequest
    if (reqBody is! Map<dynamic, dynamic>) {
      print('Login request body is not a JSON map. Actual type: ${reqBody.runtimeType}'); // 打印请求体的实际类型，确认是否为Map<String, dynamic>
      return ApiResult.fail('请求体必须是JSON对象');
    }
    final bodyAsJsonMap = await req.bodyAsJsonMap; // 触发请求体解析，确保后续调用时已经解析完成
    print('Login request body: 请求参数=====${req.bodyAsJsonMap.runtimeType}=${bodyAsJsonMap}'); // 打印请求体，方便调试
    
  
    // final body = await RequestHelper.safeParseJsonBody(req); // 确保请求体被正确解析为JSON
    final body = bodyAsJsonMap; // 直接使用已经解析好的请求体
    print('Parsed login body请求参数: $body'); // 打印解析后的请求体，方便调试
    final username = body['username']??'';
    final password = body['password']??'';

    print('用户名username: $username, password: ${password != '' ? '***' : ''}'); // 打印解析后的用户名，密码不打印
    if (username.isEmpty) {
      return ApiResult.fail('username不能为空');
    }
    if (password.isEmpty) {
      return ApiResult.fail('password不能为空');
    }

    final conn = await MysqlConfig.getConnection();
    final result = await conn.query(
      'SELECT id, username FROM user WHERE username = ? AND password = ?',
      [username, password],
    );
    await conn.close();

    if (result.isEmpty) {
      return ApiResult.fail('账号或密码错误');
    }

    final row = result.first;
    final userId = row['id'] as int;
    final token = JwtUtil.sign(userId, username);

    // 存到 Redis
    final redis = await RedisConfig.connect();
    await redis.send_object(['SET', 'user:token:$userId', token, 'EX', 86400]);

    return ApiResult.success(data: {'token': token});
  });

  // 需要登录的接口
  app.get('/user/info', (req, res) async {
    // 把鉴权逻辑直接写在处理函数里（更兼容Alfred版本）
    final token = req.headers.value('token');
    if (token == null) {
      return ApiResult.unauthorized();
    }

    final payload = JwtUtil.verify(token);
    if (payload == null) {
      return ApiResult.unauthorized();
    }

    return ApiResult.success(data: {
      'userId': payload['userId'],
      'username': payload['username'],
    });
  });

  // 1. 用户登录改造
app.post('/user/login', (req, res) async {
  // final body = await RequestHelper.safeParseJsonBody(req);
  final body = await req.bodyAsJsonMap;
  final check = Validator.validate(body, ['username', 'password']);
  if (!check['valid']) return ApiResult.params(check['msg']);

  final username = body!['username'];
  final password = body['password'];

  try {
    // 使用连接池执行 SQL（自动管理连接）
    final results = await MysqlConfig.executeSql(
      'SELECT id FROM user WHERE username=? AND password=?',
      [username, password],
    );

    if (results.isEmpty) {
      return ApiResult.fail('账号或密码错误');
    }

    final userId = results.first['id'] as int;
    final token = JwtUtil.sign(userId, username);
    final refreshToken = JwtUtil.signRefresh(userId, username);

    // 记录登录日志
    final ip = req.connectionInfo?.remoteAddress.address ?? 'unknown';
    await LogUtil.saveLoginLog(
      userId: userId,
      username: username,
      ip: ip,
      status: 'success',
    );

    final redis = await RedisConfig.connect();
    await redis.send_object(['SET', 'user:token:$userId', token, 'EX', 7200]);
    await redis.send_object(['SET', 'user:refresh:$userId', refreshToken, 'EX', 604800]);

    return ApiResult.success(data: {
      'token': token,
      'refreshToken': refreshToken,
      'userId': userId,
      'username': username,
    });
  } catch (e) {
    print('❌ 登录失败：$e');
    return ApiResult.fail('服务器内部错误');
  }
});

// 2. 用户列表改造
app.get('/user/list', (req, res) async {
  // 鉴权
  final token = req.headers.value('token');
  if (token == null || JwtUtil.verify(token) == null) {
    return ApiResult.unauthorized();
  }

  // 安全解析GET参数
  final params = RequestHelper.safeParseQueryParams(req);
  final check = Validator.validate(params, ['page', 'size']);
  if (!check['valid']) return ApiResult.params(check['msg']);

  final page = int.tryParse(params['page'] ?? '1') ?? 1;
  final size = int.tryParse(params['size'] ?? '10') ?? 10;
  final crudParams = CrudUtil.pageParams(page, size);

  try {
    // 查询总数
    final totalResults = await MysqlConfig.executeSql(
      'SELECT COUNT(*) AS total FROM user',
    );
    final total = totalResults.first['total'] as int;

    // 查询列表
    final dataResults = await MysqlConfig.executeSql(
      'SELECT id,username,create_time FROM user ORDER BY id DESC LIMIT ? OFFSET ?',
      [crudParams['limit'], crudParams['offset']],
    );

    final pageData = CrudUtil.pageResult(
      page: page,
      size: size,
      total: total,
      list: dataResults,
    );
    return ApiResult.success(data: pageData);
  } catch (e) {
    print('❌ 查询用户列表失败：$e');
    return ApiResult.fail('服务器内部错误');
  }
});
}
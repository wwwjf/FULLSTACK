import 'dart:io';

import 'package:alfred/alfred.dart';
import 'package:dart_backend/utils/crud_util.dart';
import 'package:dart_backend/utils/log_util.dart';
import 'package:dart_backend/utils/request_helper.dart';
import 'package:dart_backend/utils/validator.dart';
import 'package:dart_backend/utils/email_util.dart';
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

    final result = await MysqlConfig.executeSql(
      'SELECT id, username FROM user WHERE username = ? AND password = ?',
      [username, password],
    );

    if (result.isEmpty) {
      return ApiResult.fail('账号或密码错误');
    }

    final row = result.first;
    final userId = int.parse(row['id']);
    final token = JwtUtil.sign(userId, username);

    // 存到 Redis
    if(Platform.isWindows){
      print('当前平台是Windows，跳过Redis存储');
    } else {
      final redis = await RedisConfig.connect();
      await redis.send_object(['SET', 'user:token:$userId', token, 'EX', 86400]);
    }
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

  final username = body['username'];
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

    final userId = int.parse(results.first['id']);
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

    // final redis = await RedisConfig.connect();
    // await redis.send_object(['SET', 'user:token:$userId', token, 'EX', 7200]);
    // await redis.send_object(['SET', 'user:refresh:$userId', refreshToken, 'EX', 604800]);
    // 存到 Redis
    if(Platform.isWindows){
      print('当前平台是Windows，跳过Redis存储');
    } else {
      final redis = await RedisConfig.connect();
      await redis.send_object(['SET', 'user:token:$userId', token, 'EX', 7200]);
      await redis.send_object(['SET', 'user:refresh:$userId', refreshToken, 'EX', 604800]);
    }

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
  final params = req.uri.queryParameters;
  final check = Validator.validate(params, ['page', 'size']);
  if (!check['valid']) return ApiResult.params(check['msg']);

  final page = int.tryParse(params['page'] ?? '1') ?? 1;
  final size = int.tryParse(params['size'] ?? '10') ?? 10;
  final crudParams = CrudUtil.pageParams(page, size);

  try {
    // 查询总数
    final totalResults = await MysqlConfig.executeSql(
      'SELECT COUNT(*) AS total FROM user',[]
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

app.post('/user/login2', (req, res) async {
    final body = await RequestHelper.safeParseJsonBody(req);
    if (!Validator.validate(body, ['username', 'password'])['valid']) {
      return res.json(ApiResult.params('参数错误'));
    }
    final u = await MysqlConfig.executeSql(
      'SELECT id FROM user WHERE username=? AND password=?',
      [body!['username'], body['password']],
    );
    if (u.isEmpty) return res.json(ApiResult.fail('账号或密码错误'));
    final token = JwtUtil.sign(u.first['id'], body['username']);
    return res.json(ApiResult.success(data: {'token': token}));
  });

  // 发送邮箱验证码
  app.post('/user/send-code', (req, res) async {
    final body = await req.bodyAsJsonMap;
    final check = Validator.validate(body, ['email']);
    if (!check['valid']) return ApiResult.params(check['msg']);

    final email = body['email'];

    // 验证邮箱格式
    if (!Validator.isEmail(email)) {
      return ApiResult.fail('邮箱格式不正确');
    }

    try {
      // 检查邮箱是否已被注册
      final emailCheck = await MysqlConfig.executeSql(
        'SELECT id FROM user WHERE email=?',
        [email],
      );
      if (emailCheck.isNotEmpty) {
        return ApiResult.fail('邮箱已被注册');
      }

      // 生成验证码
      final code = EmailUtil.generateVerificationCode();

      // 发送验证码邮件
      final sendSuccess = await EmailUtil.sendVerificationCode(email, code);
      if (!sendSuccess) {
        return ApiResult.fail('发送验证码失败，请稍后重试');
      }

      // 存储验证码到 Redis
      await EmailUtil.storeVerificationCode(email, code);

      return ApiResult.success(msg: '验证码已发送到您的邮箱，有效期5分钟');
    } catch (e) {
      print('❌ 发送验证码失败：$e');
      return ApiResult.fail('服务器内部错误');
    }
  });

  // 邮箱注册
  app.post('/user/register', (req, res) async {
    final body = await req.bodyAsJsonMap;
    final check = Validator.validate(body, ['username', 'password', 'email', 'code']);
    if (!check['valid']) return ApiResult.params(check['msg']);

    final username = body['username'];
    final password = body['password'];
    final email = body['email'];
    final code = body['code'];
    final nickname = body['nickname'] ?? '';

    // 验证邮箱格式
    if (!Validator.isEmail(email)) {
      return ApiResult.fail('邮箱格式不正确');
    }

    try {
      // 验证验证码
      final codeValid = await EmailUtil.verifyCode(email, code);
      if (!codeValid) {
        return ApiResult.fail('验证码错误或已过期');
      }

      // 检查用户名是否已存在
      final usernameCheck = await MysqlConfig.executeSql(
        'SELECT id FROM user WHERE username=?',
        [username],
      );
      if (usernameCheck.isNotEmpty) {
        return ApiResult.fail('用户名已存在');
      }

      // 检查邮箱是否已存在
      final emailCheck = await MysqlConfig.executeSql(
        'SELECT id FROM user WHERE email=?',
        [email],
      );
      if (emailCheck.isNotEmpty) {
        return ApiResult.fail('邮箱已被注册');
      }

      // 插入新用户
      await MysqlConfig.executeSql(
        'INSERT INTO user (username, password, email, nickname) VALUES (?, ?, ?, ?)',
        [username, password, email, nickname],
      );

      // 获取最后插入的用户ID
      final lastIdResult = await MysqlConfig.executeSql(
        'SELECT LAST_INSERT_ID() as id',
        [],
      );
      print('lastIdResult: ${lastIdResult.first['id'].runtimeType}');
      final userId = int.parse(lastIdResult.first['id']);

      // 为新用户分配默认角色（普通用户，ID为2）
      await MysqlConfig.executeSql(
        'INSERT INTO user_role (user_id, role_id) VALUES (?, ?)',
        [userId, 2],
      );

      // 生成token
      final token = JwtUtil.sign(userId, username);
      final refreshToken = JwtUtil.signRefresh(userId, username);

      // 记录注册日志
      final ip = req.connectionInfo?.remoteAddress.address ?? 'unknown';
      await LogUtil.saveLoginLog(
        userId: userId,
        username: username,
        ip: ip,
        status: 'success',
        msg: '用户注册',
      );

      return ApiResult.success(data: {
        'token': token,
        'refreshToken': refreshToken,
        'userId': userId,
        'username': username,
        'email': email,
      });
    } catch (e) {
      print('❌ 注册失败：$e');
      return ApiResult.fail('服务器内部错误');
    }
  });
}
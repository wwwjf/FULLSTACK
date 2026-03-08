import 'package:mysql1/mysql1.dart';
import 'dart:async';

class MysqlConfig {
  // 数据库配置（适配 MySQL 8.0+）
  static final ConnectionSettings _settings = ConnectionSettings(
    host: 'localhost',
    port: 3306,
    user: 'root',
    password: 'mima034901', // 替换为实际密码
    db: 'dart_admin',
    characterSet: CharacterSet.UTF8MB4,
    // 修复 MySQL 8.0+ 认证问题
    useSSL: true,
    timeout: const Duration(seconds: 30), // 延长连接超时
  );

  // 连接池配置
  static final int _poolSize = 10; // 连接池大小
  // 存储可用连接（不再判断isClosed，通过异常处理不可用连接）
  static final List<MySqlConnection> _connectionPool = [];
  static final List<Completer<MySqlConnection>> _pendingRequests = [];
  static bool _isInitializing = false;
  // 标记连接是否正在使用（避免重复释放）
  static final Set<MySqlConnection> _inUseConnections = {};

  // 初始化连接池
  static Future<void> _initPool() async {
    if (_isInitializing || _connectionPool.isNotEmpty) return;
    _isInitializing = true;

    try {
      // 批量创建连接 - 修复类型不匹配问题
      // 1. 先创建可空类型的Future列表
      final List<Future<MySqlConnection?>> nullableFutures = [];
      for (int i = 0; i < _poolSize; i++) {
        nullableFutures.add(_createNewConnection());
      }

      // 2. 等待所有Future完成
      final List<MySqlConnection?> nullableConns = await Future.wait(nullableFutures);

      // 3. 过滤掉null值，只保留有效连接
      for (final conn in nullableConns) {
        if (conn != null) {
          _connectionPool.add(conn);
        }
      }

      print('✅ 连接池初始化完成，可用连接数：${_connectionPool.length}');
    } catch (e) {
      print('❌ 连接池初始化失败：$e');
    } finally {
      _isInitializing = false;
      // 处理等待中的请求
      _processPendingRequests();
    }
  }

  // 创建单个新连接（带异常处理，返回可空类型）
  static Future<MySqlConnection?> _createNewConnection() async {
    try {
      final conn = await MySqlConnection.connect(_settings);
      print('✅ 创建数据库连接成功');
      // 监听连接关闭事件（通过onDone）
      conn.close().then((_) {
        print('🔌 数据库连接已关闭，自动重建');
        // 从池中移除已关闭的连接
        if (_connectionPool.contains(conn)) {
          _connectionPool.remove(conn);
        }
        if (_inUseConnections.contains(conn)) {
          _inUseConnections.remove(conn);
        }
        // 异步重建连接（避免阻塞）
        Future.delayed(const Duration(seconds: 1), () => _createNewConnection().then((newConn) {
          if (newConn != null) {
            _connectionPool.add(newConn);
            _processPendingRequests();
          }
        }));
      });
      return conn;
    } catch (e) {
      print('❌ 创建数据库连接失败：$e');
      // 重试创建（最多重试3次）
      for (int retry = 1; retry <= 3; retry++) {
        print('🔄 第$retry次重试创建连接...');
        await Future.delayed(const Duration(seconds: 1));
        try {
          final conn = await MySqlConnection.connect(_settings);
          print('✅ 重试创建连接成功');
          return conn;
        } catch (retryError) {
          print('❌ 第$retry次重试失败：$retryError');
        }
      }
      return null;
    }
  }

  // 处理等待中的请求
  static void _processPendingRequests() {
    while (_pendingRequests.isNotEmpty && _connectionPool.isNotEmpty) {
      final completer = _pendingRequests.removeAt(0);
      final conn = _connectionPool.removeAt(0);
      _inUseConnections.add(conn); // 标记为使用中
      completer.complete(conn);
    }
  }

  // 获取连接（从连接池）
  static Future<MySqlConnection> getConnection() async {
    // 初始化连接池
    await _initPool();

    // 有可用连接直接返回
    if (_connectionPool.isNotEmpty) {
      final conn = _connectionPool.removeAt(0);
      _inUseConnections.add(conn);
      return conn;
    }

    // 无可用连接，加入等待队列
    final completer = Completer<MySqlConnection>();
    _pendingRequests.add(completer);
    return completer.future;
  }

  // 释放连接（归还到连接池，移除isClosed判断）
  static void releaseConnection(MySqlConnection conn) {
    // 移除使用中标记
    _inUseConnections.remove(conn);
    
    try {
      // 不判断isClosed，直接尝试归还
      // 通过后续SQL执行的异常来处理不可用连接
      _connectionPool.add(conn);
      _processPendingRequests();
    } catch (e) {
      print('❌ 归还连接失败：$e');
      // 连接不可用，重建一个新连接
      _createNewConnection().then((newConn) {
        if (newConn != null) {
          _connectionPool.add(newConn);
          _processPendingRequests();
        }
      });
    }
  }

  // 安全执行 SQL（自动管理连接，移除isClosed依赖）
  static Future<List<Map<String, dynamic>>> executeSql(String sql, [List<Object>? params]) async {
    MySqlConnection? conn;
    try {
      conn = await getConnection();
      
      // 直接执行SQL，不使用PreparedStatement（避免字节解析错误）
      // 捕获连接不可用的异常，自动重试
      final results = await conn.query(sql, params);
      
      // 转换为 Map 列表（适配原有逻辑）
      final List<Map<String, dynamic>> resultList = [];
      for (final row in results) {
        resultList.add(row.fields);
      }
      
      return resultList;
    } catch (e) {
      print('❌ SQL执行失败：$e\nSQL: $sql\nParams: $params');
      
      // 捕获连接相关异常，标记连接不可用
      if (e.toString().contains('Socket') || 
          e.toString().contains('Connection') ||
          e.toString().contains('closed')) {
        // 连接已失效，不归还，直接重建
        if (conn != null) {
          _inUseConnections.remove(conn);
          // 异步重建连接
          _createNewConnection().then((newConn) {
            if (newConn != null) {
              _connectionPool.add(newConn);
              _processPendingRequests();
            }
          });
        }
      }
      
      // 抛出异常，让上层处理
      rethrow;
    } finally {
      if (conn != null && _inUseConnections.contains(conn)) {
        // 归还连接（无论是否异常，都尝试归还）
        releaseConnection(conn);
      }
    }
  }

  // 关闭所有连接
  static Future<void> closeAll() async {
    // 关闭所有可用连接
    for (final conn in _connectionPool) {
      try {
        await conn.close();
      } catch (e) {
        print('❌ 关闭连接失败：$e');
      }
    }
    // 关闭所有使用中的连接
    for (final conn in _inUseConnections) {
      try {
        await conn.close();
      } catch (e) {
        print('❌ 关闭使用中连接失败：$e');
      }
    }
    // 清空池和队列
    _connectionPool.clear();
    _inUseConnections.clear();
    _pendingRequests.clear();
    print('✅ 所有数据库连接已关闭');
  }
}
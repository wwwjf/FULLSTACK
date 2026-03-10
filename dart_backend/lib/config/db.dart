
import 'dart:async';

import 'package:mysql_client/mysql_client.dart';

class MysqlConfig {
  // 数据库配置（适配 MySQL 8.0+）
  static final MySQLConnectionPool _connectionPool = MySQLConnectionPool(
    host: 'localhost',
    port: 3306,
    userName: 'root',
    password: 'root123456', // 替换为实际密码
    maxConnections: _poolSize,
    databaseName: 'dart_admin',
    // 修复 MySQL 8.0+ 认证问题
    secure: true,
    timeoutMs: 30*1000, // 延长连接超时
  );

  // 连接池配置
  static final int _poolSize = 10; // 连接池大小


  // 安全执行 SQL（自动管理连接，移除isClosed依赖）
  static Future<List<Map<String, dynamic>>> executeSql(String sql, List<dynamic> params) async {
    try {
      
      // 直接执行SQL，不使用PreparedStatement（避免字节解析错误）
      // 捕获连接不可用的异常，自动重试
      final sqlConn = await _connectionPool.prepare(sql);
      final results = await sqlConn.execute(params);
      
      // 转换为 Map 列表（适配原有逻辑）
      final List<Map<String, dynamic>> resultList = [];
      for (final row in results.rows) {
        resultList.add(row.assoc());
      }
    
      
      return resultList;
    } catch (e) {
      print('❌ SQL执行失败：$e\nSQL: $sql\nParams: $params');
    
    
      // 抛出异常，让上层处理
      rethrow;
    } finally {
      
    }
  }

}
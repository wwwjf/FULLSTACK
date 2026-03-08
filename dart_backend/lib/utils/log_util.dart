import 'dart:io';
import 'package:intl/intl.dart';

import '../config/db.dart';

class LogUtil {
  static final _dateFormat = DateFormat('yyyy-MM-dd');
  static final _timeFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  static Future<void> info(String msg) async {
    final now = DateTime.now();
    final dateStr = _dateFormat.format(now);
    final timeStr = _timeFormat.format(now);
    final log = '[$timeStr] $msg';

    final file = File('logs/app_$dateStr.log');
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    await file.writeAsString('$log\n', mode: FileMode.append);
  }

  // 保存登录日志
  static Future<void> saveLoginLog({
    required int userId,
    required String username,
    required String ip,
    required String status,
    String msg = '',
  }) async {
    try {
      await MysqlConfig.executeSql(
        '''
        INSERT INTO login_log(user_id, username, ip, status, msg)
        VALUES (?, ?, ?, ?, ?)
        ''',
        [userId, username, ip, status, msg],
      );
    } catch (e) {
      print('❌ 保存登录日志失败：$e');
      // 不抛出异常，避免影响主流程
    }
  }

  // 保存操作日志
  static Future<void> saveOperateLog({
    required int userId,
    required String username,
    required String module,
    required String operation,
    required String method,
    required String url,
    String params = '',
    required String ip,
    required int time,
    int status = 1,
    String errorMsg = '',
  }) async {
    try {
      await MysqlConfig.executeSql(
        '''
        INSERT INTO operation_log(
          user_id, username, module, operation, method, url, 
          params, ip, time, status, error_msg
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''',
        [
          userId, username, module, operation, method, url,
          params, ip, time, status, errorMsg
        ],
      );
    } catch (e) {
      print('❌ 保存操作日志失败：$e');
    }
  }
}
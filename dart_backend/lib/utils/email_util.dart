import 'dart:math';
import '../config/redis.dart';
import '../config/email_config.dart';

class EmailUtil {
  // 生成6位数字验证码
  static String generateVerificationCode() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  // 发送验证码邮件
  static Future<bool> sendVerificationCode(String email, String code) async {
    try {
      print('🚀 发送验证码邮件到: $email');
      print('📧 验证码: $code');
      print('⏰ 验证码有效期: 5分钟');
      
      // 使用SMTP协议发送邮件
      final success = await EmailConfig.sendVerificationCodeEmail(email, code);
      
      return success;
    } catch (e) {
      print('❌ 发送邮件失败: $e');
      return false;
    }
  }

  // 存储验证码到 Redis
  static Future<void> storeVerificationCode(String email, String code) async {
    try {
      final redis = await RedisConfig.connect();
      // 验证码有效期5分钟
      await redis.send_object(['SET', 'email:code:$email', code, 'EX', 300]);
    } catch (e) {
      print('❌ 存储验证码失败: $e');
    }
  }

  // 验证验证码
  static Future<bool> verifyCode(String email, String code) async {
    try {
      final redis = await RedisConfig.connect();
      final storedCode = await redis.send_object(['GET', 'email:code:$email']);
      if (storedCode is String && storedCode == code) {
        // 验证成功后删除验证码
        await redis.send_object(['DEL', 'email:code:$email']);
        return true;
      }
      return false;
    } catch (e) {
      print('❌ 验证验证码失败: $e');
      return false;
    }
  }
}

import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailConfig {
  // SMTP服务器配置
  // 注意：实际项目中应该从环境变量或配置文件中读取这些配置
  static const String smtpHost = 'smtp.qq.com';
  static const int smtpPort = 465;
  static const String smtpUsername = '980060369@qq.com';
  static const String smtpPassword = 'auxmmmzlkkkobeaj';
  static const String senderName = '系统管理员';

  // 创建SMTP服务器配置
  static SmtpServer createSmtpServer() {
    return SmtpServer(
      smtpHost,
      port: smtpPort,
      username: smtpUsername,
      password: smtpPassword,
      ssl: true,
      allowInsecure: false,
    );
  }

  // 创建邮件消息
  static Message createMessage({
    required String toEmail,
    required String subject,
    required String text,
    String? html,
  }) {
    return Message()
      ..from = Address(smtpUsername, senderName)
      ..recipients.add(toEmail)
      ..subject = subject
      ..text = text
      ..html = html;
  }

  // 发送验证码邮件
  static Future<bool> sendVerificationCodeEmail(String toEmail, String code) async {
    try {
      final smtpServer = createSmtpServer();
      final message = createMessage(
        toEmail: toEmail,
        subject: '邮箱验证码',
        text: '您的验证码是：$code，有效期5分钟。请勿将验证码告知他人。',
        html: '''
          <h2>邮箱验证</h2>
          <p>您的验证码是：<strong style="font-size: 24px; color: #007bff;">$code</strong></p>
          <p>验证码有效期5分钟，请尽快使用。</p>
          <p>如非本人操作，请忽略此邮件。</p>
          <hr>
          <p style="color: #999; font-size: 12px;">此邮件由系统自动发送，请勿回复。</p>
        ''',
      );

      final sendReport = await send(message, smtpServer);
      print('📧 邮件发送成功: ${sendReport.toString()}');
      return true;
    } catch (e) {
      print('❌ 邮件发送失败: $e');
      return false;
    }
  }
}

import 'dart:convert';
import 'dart:io';

class RequestHelper {
  static Future<Map<String, dynamic>?> safeParseJsonBody(HttpRequest req) async {
    try {
      return json.decode(await utf8.decodeStream(req));
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> parseUploadFile(HttpRequest req) async {
    // 简单上传示例
    return null;
  }
}
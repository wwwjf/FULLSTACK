/// 安全的请求体解析工具
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:alfred/alfred.dart';

class RequestHelper {
  /// 一次性读取请求体原始数据（仅监听一次流）
  static Future<Uint8List> readRawBody(HttpRequest req) async {
    try {
      final bytes = <int>[];
      final body = await req.body; // 触发请求体解析，确保后续调用时已经解析完成
      print('开始读取请求体原始数据...${req.body}=body=$body'); // 打印开始读取的日志，方便调试
      await for (final chunk in req) {
        print('Received chunk of size: ${chunk.length} bytes'); // 打印每个数据块的大小，方便调试
        bytes.addAll(chunk);
      }
      return Uint8List.fromList(bytes);
    } catch (e) {
      return Uint8List(0);
    }
  }

  /// 从原始数据解析 JSON Map（仅解析一次）
  static Map<String, dynamic>? parseJsonFromRaw(Uint8List rawData) {
    if (rawData.isEmpty) return null;
    try {
      final jsonString = utf8.decode(rawData);
      if (jsonString.isEmpty) return null;
      final dynamic jsonData = json.decode(jsonString);
      if (jsonData is Map<String, dynamic>) {
        return jsonData;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 安全解析 JSON 请求体（仅读取一次流）
  static Future<Map<String, dynamic>?> safeParseJsonBody(HttpRequest req) async {
    final rawData = await readRawBody(req);
    return parseJsonFromRaw(rawData);
  }

  /// 安全解析 GET 请求参数
  static Map<String, dynamic> safeParseQueryParams(HttpRequest req) {
    return Map<String, dynamic>.from(req.uri.queryParameters);
  }

  /// 解析文件上传（不依赖 FormData 类，直接解析 multipart/form-data）
  static Future<Map<String, dynamic>?> parseUploadFile(HttpRequest req) async {
    try {
      // 检查 Content-Type 是否为 multipart/form-data
      final contentType = req.headers.contentType;
      if (contentType == null || !contentType.toString().contains('multipart/form-data')) {
        return null;
      }

      // 获取边界符
      final boundary = contentType.parameters['boundary'];
      if (boundary == null) return null;

      // 读取原始数据
      final rawData = await readRawBody(req);
      if (rawData.isEmpty) return null;

      // 解析 multipart 数据（简化版，仅提取第一个文件）
      final rawString = utf8.decode(rawData);
      final parts = rawString.split('--$boundary');
      
      for (final part in parts) {
        if (part.isEmpty || part.contains('--')) continue;
        
        // 查找文件内容起始位置
        final lines = part.split('\r\n');
        int contentStartIndex = 0;
        String? filename;
        String? contentType;

        // 解析头部信息
        for (int i = 0; i < lines.length; i++) {
          final line = lines[i];
          if (line.isEmpty) {
            contentStartIndex = i + 1;
            break;
          }
          // 提取文件名
          if (line.contains('filename=')) {
            final filenameMatch = RegExp(r'filename="(.*?)"').firstMatch(line);
            if (filenameMatch != null) {
              filename = filenameMatch.group(1);
            }
          }
          // 提取文件类型
          if (line.contains('Content-Type:')) {
            contentType = line.replaceAll('Content-Type:', '').trim();
          }
        }

        // 提取文件内容
        if (contentStartIndex < lines.length && filename != null) {
          final contentLines = lines.sublist(contentStartIndex);
          final contentBytes = utf8.encode(contentLines.join('\r\n'));
          
          return {
            'filename': filename,
            'contentType': contentType ?? 'application/octet-stream',
            'bytes': Uint8List.fromList(contentBytes),
          };
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
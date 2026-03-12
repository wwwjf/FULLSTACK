import 'dart:io';
import 'package:alfred/alfred.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
import '../utils/result.dart';
import '../config/app_config.dart';
import '../utils/request_helper.dart';

void uploadRoutes(Alfred app) {
  app.post('/upload/image', (req, res) async {
    final file = await RequestHelper.parseUploadFile(req);
    if (file == null) return res.json(ApiResult.params('上传失败'));

    final ext = extension(file['filename']);
    if (!AppConfig.allowedExt.contains(ext)) {
      return res.json(ApiResult.fail('不支持的文件类型'));
    }

    final name = '${Uuid().v4()}$ext';
    final path = join('uploads', name);
    await Directory('uploads').create(recursive: true);
    await File(path).writeAsBytes(file['bytes']);

    res.json(ApiResult.success(data: {'url': '/uploads/$name'}));
  });
}
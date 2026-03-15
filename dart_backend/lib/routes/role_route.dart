import 'package:alfred/alfred.dart';
import '../config/db.dart';
import '../utils/result.dart';

void roleRoutes(Alfred app) {
  app.get('/role/list', (req, res) async {
    final list = await MysqlConfig.executeSql('SELECT * FROM role', []);
    res.json(ApiResult.success(data: list));
  });
}
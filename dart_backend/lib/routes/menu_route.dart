import 'package:alfred/alfred.dart';
import '../config/db.dart';
import '../utils/result.dart';

void menuRoutes(Alfred app) {
  app.get('/menu/list', (req, res) async {
    final list = await MysqlConfig.executeSql('SELECT * FROM menu', []);
    res.json(ApiResult.success(data: list));
  });
}
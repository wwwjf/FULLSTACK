import 'package:alfred/alfred.dart';
import '../config/db.dart';
import '../utils/result.dart';

void logRoutes(Alfred app) {
  app.get('/log/loginList', (req, res) async {
    final list = await MysqlConfig.executeSql('SELECT * FROM login_log', []);
    res.json(ApiResult.success(data: list));
  });
}
import 'package:alfred/alfred.dart';
import '../config/db.dart';
import '../utils/result.dart';

void dictRoutes(Alfred app) {
  app.get('/dict/list', (req, res) async {
    final list = await MysqlConfig.executeSql('SELECT * FROM dict_type',[]);
    res.json(ApiResult.success(data: list));
  });
}
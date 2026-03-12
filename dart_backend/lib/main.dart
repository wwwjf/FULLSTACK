import 'package:alfred/alfred.dart';
import 'package:dart_backend/routes/role_route.dart';
import 'routes/user_route.dart';

void main() async {
  final app = Alfred();

  // 路由
  userRoutes(app);
  roleRoutes(app);


  // 404
  app.all('*', (req, res) {
    return {'code': 404, 'msg': '接口不存在'};
  });

  await app.listen(3000);
  print('Server running at http://0.0.0.0:3000');
}
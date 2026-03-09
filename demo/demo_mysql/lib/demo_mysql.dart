import 'package:mysql_client/mysql_client.dart';


void connectMySQL() async {
  try {
    final conn = await MySQLConnection.createConnection(
      host: 'localhost',
      port: 3306,
      userName: 'root',
      password: 'mima034901',
      databaseName: 'dart_admin'
    );
    await conn.connect();
    print('Connected to MySQL successfully!');
    
    final results = await conn.execute("SELECT * FROM user");
    print('Query results: ${results.runtimeType}, length: ${results.rows.length}');
    for (var row in results.rows) {
      print('Row: $row');
      print('ID: ${row.colByName('id')}, Name: ${row.colByName('username')}');
    }
    
    await conn.close();
    print('Connection closed.');
  } catch (e) {
    print('Error: $e');
  }
}

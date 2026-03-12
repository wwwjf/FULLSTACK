class ApiResult {
  static success({msg = 'ok', data}) => {
    'code': 200,
    'msg': msg,
    'data': data
  };

  static fail(msg) => {
    'code': 400,
    'msg': msg,
    'data': null
  };

  static params(msg) => {
    'code': 400,
    'msg': msg,
    'data': null
  };

  static unauthorized() => {
    'code': 401,
    'msg': '未授权',
    'data': null
  };
}
class ApiResult {
  final int code;
  final String msg;
  final dynamic data;

  ApiResult({
    required this.code,
    required this.msg,
    this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'msg': msg,
      'data': data,
    };
  }

  static ApiResult success({dynamic data, String msg = 'success'}) {
    return ApiResult(code: 200, msg: msg, data: data);
  }

  static ApiResult fail(String msg) {
    return ApiResult(code: 500, msg: msg);
  }

  static ApiResult unauthorized() {
    return ApiResult(code: 401, msg: '请先登录');
  }

  static ApiResult params(String msg) {
    return ApiResult(code: 400, msg: msg);
  }
}
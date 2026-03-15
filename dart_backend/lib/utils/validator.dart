/// 通用参数校验工具
class Validator {
  /// 基础必填参数校验
  /// [params] 待校验的参数Map（req.bodyAsJsonMap/req.uri.queryParameters）
  /// [requiredKeys] 必填参数列表，如 ['username', 'password']
  /// 返回：{valid: bool, msg: String}
  static Map<String, dynamic> validate(Map<String, dynamic>? params, List<String> requiredKeys) {
    // 1. 参数为空（完全没传参数）
    if (params == null || params.isEmpty) {
      return {'valid': false, 'msg': '请传入接口所需参数'};
    }

    // 2. 检查必填参数缺失
    for (var key in requiredKeys) {
      if (!params.containsKey(key) || params[key] == null || params[key].toString().trim().isEmpty) {
        return {'valid': false, 'msg': '参数 $key 不能为空'};
      }
    }

    return {'valid': true, 'msg': '校验通过'};
  }

  /// 简化版校验（直接抛异常，配合全局异常捕获）
  static void checkRequired(Map<String, dynamic>? params, List<String> requiredKeys) {
    final result = validate(params, requiredKeys);
    if (!result['valid']) {
      throw ArgumentError(result['msg']);
    }
  }

  /// 校验URL参数（GET请求）
  static Map<String, dynamic> validateQueryParams(Map<String, String> params, List<String> requiredKeys) {
    // 转换为dynamic Map，兼容通用校验逻辑
    final dynamicParams = params.map((k, v) => MapEntry(k, v as dynamic));
    return validate(dynamicParams, requiredKeys);
  }

  /// 验证邮箱格式
  static bool isEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }
}
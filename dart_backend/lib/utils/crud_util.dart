

class CrudUtil {
  // 分页查询
  static Map<String, dynamic> pageParams(int page, int size) {
    page = page < 1 ? 1 : page;
    size = size < 1 ? 10 : size;
    final offset = (page - 1) * size;
    return {'limit': size, 'offset': offset};
  }

  // 组装分页返回
  static Map<String, dynamic> pageResult({
    required int page,
    required int size,
    required int total,
    required dynamic list,
  }) {
    return {
      'page': page,
      'size': size,
      'total': total,
      'pages': (total / size).ceil(),
      'list': list,
    };
  }

  // 结果转List
  // static List<Map<String, dynamic>> toList(Results results) {
  //   return results.map((e) => e.fields).toList();
  // }
}
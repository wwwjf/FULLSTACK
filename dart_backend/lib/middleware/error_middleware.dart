class ErrorMiddleware {
  Future errorMiddleware(req, res) async {
  try {
    await req.next();
  } catch (e) {
    print('Error: $e');
    res.json({
      'code': 500,
      'msg': 'Server error',
      'data': null
    });
  }
}
}

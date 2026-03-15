import 'package:dart_backend/utils/result.dart';
import 'package:test/test.dart';

void main() {
  group('ApiResult', () {
    group('success', () {
      test('should return success result with default message', () {
        final result = ApiResult.success();
        
        expect(result['code'], 200);
        expect(result['msg'], 'ok');
        expect(result['data'], isNull);
      });

      test('should return success result with custom message', () {
        final result = ApiResult.success(msg: '操作成功');
        
        expect(result['code'], 200);
        expect(result['msg'], '操作成功');
        expect(result['data'], isNull);
      });

      test('should return success result with data', () {
        final data = {'id': 1, 'name': 'test'};
        final result = ApiResult.success(data: data);
        
        expect(result['code'], 200);
        expect(result['msg'], 'ok');
        expect(result['data'], equals(data));
      });

      test('should return success result with custom message and data', () {
        final data = {'id': 1, 'name': 'test'};
        final result = ApiResult.success(msg: '创建成功', data: data);
        
        expect(result['code'], 200);
        expect(result['msg'], '创建成功');
        expect(result['data'], equals(data));
      });
    });

    group('fail', () {
      test('should return fail result with message', () {
        final result = ApiResult.fail('操作失败');
        
        expect(result['code'], 400);
        expect(result['msg'], '操作失败');
        expect(result['data'], isNull);
      });

      test('should return fail result with empty message', () {
        final result = ApiResult.fail('');
        
        expect(result['code'], 400);
        expect(result['msg'], '');
        expect(result['data'], isNull);
      });
    });

    group('params', () {
      test('should return params error result with message', () {
        final result = ApiResult.params('参数错误');
        
        expect(result['code'], 400);
        expect(result['msg'], '参数错误');
        expect(result['data'], isNull);
      });

      test('should return params error result with validation message', () {
        final result = ApiResult.params('username 不能为空');
        
        expect(result['code'], 400);
        expect(result['msg'], 'username 不能为空');
        expect(result['data'], isNull);
      });
    });

    group('unauthorized', () {
      test('should return unauthorized result', () {
        final result = ApiResult.unauthorized();
        
        expect(result['code'], 401);
        expect(result['msg'], '未授权');
        expect(result['data'], isNull);
      });

      test('should return consistent unauthorized result on multiple calls', () {
        final result1 = ApiResult.unauthorized();
        final result2 = ApiResult.unauthorized();
        
        expect(result1['code'], result2['code']);
        expect(result1['msg'], result2['msg']);
        expect(result1['data'], result2['data']);
      });
    });

    group('result structure', () {
      test('should return Map with correct keys', () {
        final result = ApiResult.success(data: {'test': 'value'});
        
        expect(result, isA<Map>());
        expect(result.keys, containsAll(['code', 'msg', 'data']));
      });

      test('should have correct value types', () {
        final result = ApiResult.success(data: {'test': 'value'});
        
        expect(result['code'], isA<int>());
        expect(result['msg'], isA<String>());
        expect(result['data'], isA<Map>());
      });
    });
  });
}

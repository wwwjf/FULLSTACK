import 'package:dart_backend/utils/validator.dart';
import 'package:test/test.dart';

void main() {
  group('Validator', () {
    group('validate', () {
      test('should return invalid when params is null', () {
        final result = Validator.validate(null, ['username']);
        
        expect(result['valid'], false);
        expect(result['msg'], '请传入接口所需参数');
      });

      test('should return invalid when params is empty map', () {
        final result = Validator.validate({}, ['username']);
        
        expect(result['valid'], false);
        expect(result['msg'], '请传入接口所需参数');
      });

      test('should return invalid when required key is missing', () {
        final params = {'username': 'test'};
        final result = Validator.validate(params, ['username', 'password']);
        
        expect(result['valid'], false);
        expect(result['msg'], '参数 password 不能为空');
      });

      test('should return invalid when required key is null', () {
        final params = {'username': 'test', 'password': null};
        final result = Validator.validate(params, ['username', 'password']);
        
        expect(result['valid'], false);
        expect(result['msg'], '参数 password 不能为空');
      });

      test('should return invalid when required key is empty string', () {
        final params = {'username': 'test', 'password': ''};
        final result = Validator.validate(params, ['username', 'password']);
        
        expect(result['valid'], false);
        expect(result['msg'], '参数 password 不能为空');
      });

      test('should return invalid when required key is whitespace only', () {
        final params = {'username': 'test', 'password': '   '};
        final result = Validator.validate(params, ['username', 'password']);
        
        expect(result['valid'], false);
        expect(result['msg'], '参数 password 不能为空');
      });

      test('should return valid when all required keys are present and not empty', () {
        final params = {'username': 'test', 'password': '123456'};
        final result = Validator.validate(params, ['username', 'password']);
        
        expect(result['valid'], true);
        expect(result['msg'], '校验通过');
      });

      test('should return valid when params have extra keys', () {
        final params = {'username': 'test', 'password': '123456', 'email': 'test@example.com'};
        final result = Validator.validate(params, ['username', 'password']);
        
        expect(result['valid'], true);
        expect(result['msg'], '校验通过');
      });

      test('should return valid with single required key', () {
        final params = {'username': 'test'};
        final result = Validator.validate(params, ['username']);
        
        expect(result['valid'], true);
        expect(result['msg'], '校验通过');
      });

      test('should return valid with numeric values', () {
        final params = {'id': 123, 'name': 'test'};
        final result = Validator.validate(params, ['id', 'name']);
        
        expect(result['valid'], true);
        expect(result['msg'], '校验通过');
      });

      test('should return valid with boolean values', () {
        final params = {'isActive': true, 'name': 'test'};
        final result = Validator.validate(params, ['isActive', 'name']);
        
        expect(result['valid'], true);
        expect(result['msg'], '校验通过');
      });

      test('should return valid with list values', () {
        final params = {'tags': ['tag1', 'tag2'], 'name': 'test'};
        final result = Validator.validate(params, ['tags', 'name']);
        
        expect(result['valid'], true);
        expect(result['msg'], '校验通过');
      });

      test('should return valid with map values', () {
        final params = {'metadata': {'key': 'value'}, 'name': 'test'};
        final result = Validator.validate(params, ['metadata', 'name']);
        
        expect(result['valid'], true);
        expect(result['msg'], '校验通过');
      });

      test('should return valid with zero as valid value', () {
        final params = {'count': 0, 'name': 'test'};
        final result = Validator.validate(params, ['count', 'name']);
        
        expect(result['valid'], true);
        expect(result['msg'], '校验通过');
      });

      test('should return valid with false as valid value', () {
        final params = {'isActive': false, 'name': 'test'};
        final result = Validator.validate(params, ['isActive', 'name']);
        
        expect(result['valid'], true);
        expect(result['msg'], '校验通过');
      });

      test('should return valid with empty list', () {
        final params = {'tags': [], 'name': 'test'};
        final result = Validator.validate(params, ['tags', 'name']);
        
        expect(result['valid'], true);
        expect(result['msg'], '校验通过');
      });

      test('should return valid with empty map', () {
        final params = {'metadata': {}, 'name': 'test'};
        final result = Validator.validate(params, ['metadata', 'name']);
        
        expect(result['valid'], true);
        expect(result['msg'], '校验通过');
      });
    });

    group('checkRequired', () {
      test('should throw ArgumentError when params is null', () {
        expect(
          () => Validator.checkRequired(null, ['username']),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw ArgumentError when required key is missing', () {
        final params = {'username': 'test'};
        expect(
          () => Validator.checkRequired(params, ['username', 'password']),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw ArgumentError with correct message', () {
        final params = {'username': 'test'};
        expect(
          () => Validator.checkRequired(params, ['username', 'password']),
          throwsA(predicate<ArgumentError>((e) => e.message == '参数 password 不能为空')),
        );
      });

      test('should not throw when all required keys are present', () {
        final params = {'username': 'test', 'password': '123456'};
        expect(
          () => Validator.checkRequired(params, ['username', 'password']),
          returnsNormally,
        );
      });

      test('should not throw when params have extra keys', () {
        final params = {'username': 'test', 'password': '123456', 'email': 'test@example.com'};
        expect(
          () => Validator.checkRequired(params, ['username', 'password']),
          returnsNormally,
        );
      });
    });

    group('validateQueryParams', () {
      test('should return invalid when query params is empty', () {
        final params = <String, String>{};
        final result = Validator.validateQueryParams(params, ['page', 'size']);
        
        expect(result['valid'], false);
        expect(result['msg'], '请传入接口所需参数');
      });

      test('should return invalid when required query param is missing', () {
        final params = {'page': '1'};
        final result = Validator.validateQueryParams(params, ['page', 'size']);
        
        expect(result['valid'], false);
        expect(result['msg'], '参数 size 不能为空');
      });

      test('should return invalid when required query param is empty string', () {
        final params = {'page': '1', 'size': ''};
        final result = Validator.validateQueryParams(params, ['page', 'size']);
        
        expect(result['valid'], false);
        expect(result['msg'], '参数 size 不能为空');
      });

      test('should return valid when all required query params are present', () {
        final params = {'page': '1', 'size': '10'};
        final result = Validator.validateQueryParams(params, ['page', 'size']);
        
        expect(result['valid'], true);
        expect(result['msg'], '校验通过');
      });

      test('should return valid with numeric string values', () {
        final params = {'page': '1', 'size': '10', 'id': '123'};
        final result = Validator.validateQueryParams(params, ['page', 'size']);
        
        expect(result['valid'], true);
        expect(result['msg'], '校验通过');
      });

      test('should return valid with extra query params', () {
        final params = {'page': '1', 'size': '10', 'sort': 'desc', 'filter': 'active'};
        final result = Validator.validateQueryParams(params, ['page', 'size']);
        
        expect(result['valid'], true);
        expect(result['msg'], '校验通过');
      });
    });

    group('edge cases', () {
      test('should handle empty required keys list', () {
        final params = {'username': 'test'};
        final result = Validator.validate(params, []);
        
        expect(result['valid'], true);
        expect(result['msg'], '校验通过');
      });

      test('should handle single character values', () {
        final params = {'a': 'b'};
        final result = Validator.validate(params, ['a']);
        
        expect(result['valid'], true);
        expect(result['msg'], '校验通过');
      });

      test('should handle special characters in values', () {
        final params = {'username': 'test@#\$%', 'password': '!@#%^&*()'};
        final result = Validator.validate(params, ['username', 'password']);
        
        expect(result['valid'], true);
        expect(result['msg'], '校验通过');
      });

      test('should handle unicode characters in values', () {
        final params = {'name': '测试用户', 'description': '这是一个测试'};
        final result = Validator.validate(params, ['name', 'description']);
        
        expect(result['valid'], true);
        expect(result['msg'], '校验通过');
      });

      test('should handle very long values', () {
        final longValue = 'a' * 10000;
        final params = {'content': longValue};
        final result = Validator.validate(params, ['content']);
        
        expect(result['valid'], true);
        expect(result['msg'], '校验通过');
      });
    });
  });
}

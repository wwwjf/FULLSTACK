import 'package:dart_backend/config/jwt.dart';
import 'package:dart_backend/utils/result.dart';
import 'package:test/test.dart';

void main() {
  group('AuthMiddleware', () {
    group('token verification logic', () {
      test('should verify valid token', () {
        final userId = 123;
        final username = 'testuser';
        final token = JwtUtil.sign(userId, username);

        final payload = JwtUtil.verify(token);

        expect(payload, isNotNull);
        expect(payload!['userId'], userId);
        expect(payload['username'], username);
      });

      test('should return null for invalid token', () {
        final payload = JwtUtil.verify('invalid_token');
        expect(payload, isNull);
      });

      test('should return null for empty token', () {
        final payload = JwtUtil.verify('');
        expect(payload, isNull);
      });

      test('should return null for invalid token', () {
        final payload = JwtUtil.verify('invalid_token');
        expect(payload, isNull);
      });
    });

    group('token generation', () {
      test('should generate valid access token', () {
        final userId = 1;
        final username = 'testuser';
        final token = JwtUtil.sign(userId, username);

        expect(token, isNotEmpty);
        expect(token, isA<String>());

        final payload = JwtUtil.verify(token);
        expect(payload, isNotNull);
        expect(payload!['userId'], userId);
        expect(payload['username'], username);
        expect(payload['type'], 'access');
      });

      test('should generate valid refresh token', () {
        final userId = 1;
        final username = 'testuser';
        final token = JwtUtil.signRefresh(userId, username);

        expect(token, isNotEmpty);
        expect(token, isA<String>());

        final payload = JwtUtil.verifyRefresh(token);
        expect(payload, isNotNull);
        expect(payload!['userId'], userId);
        expect(payload['username'], username);
        expect(payload['type'], 'refresh');
      });

      test('should generate different tokens for different users', () {
        final token1 = JwtUtil.sign(1, 'user1');
        final token2 = JwtUtil.sign(2, 'user2');

        expect(token1, isNot(equals(token2)));
      });

      test('should generate different access and refresh tokens for same user', () async {
        final accessToken = JwtUtil.sign(1, 'testuser');
        await Future.delayed(Duration(seconds: 2));
        final refreshToken = JwtUtil.signRefresh(1, 'testuser');

        expect(accessToken, isNot(equals(refreshToken)));
      });
    });

    group('edge cases', () {
      test('should handle token with special characters in username', () {
        final username = 'user@#\$%';
        final token = JwtUtil.sign(1, username);

        final payload = JwtUtil.verify(token);
        expect(payload, isNotNull);
        expect(payload!['username'], username);
      });

      test('should handle token with unicode characters in username', () {
        final username = '测试用户';
        final token = JwtUtil.sign(1, username);

        final payload = JwtUtil.verify(token);
        expect(payload, isNotNull);
        expect(payload!['username'], username);
      });

      test('should handle token with large userId', () {
        final userId = 999999;
        final token = JwtUtil.sign(userId, 'testuser');

        final payload = JwtUtil.verify(token);
        expect(payload, isNotNull);
        expect(payload!['userId'], userId);
      });

      test('should handle token with userId 0', () {
        final token = JwtUtil.sign(0, 'testuser');

        final payload = JwtUtil.verify(token);
        expect(payload, isNotNull);
        expect(payload!['userId'], 0);
      });

      test('should handle token with negative userId', () {
        final token = JwtUtil.sign(-1, 'testuser');

        final payload = JwtUtil.verify(token);
        expect(payload, isNotNull);
        expect(payload!['userId'], -1);
      });

      test('should handle token with empty username', () {
        final token = JwtUtil.sign(1, '');

        final payload = JwtUtil.verify(token);
        expect(payload, isNotNull);
        expect(payload!['username'], '');
      });
    });

    group('token expiration', () {
      test('should include expiration in access token payload', () {
        final token = JwtUtil.sign(1, 'testuser');
        final payload = JwtUtil.verify(token);

        expect(payload, isNotNull);
        expect(payload!.containsKey('exp'), true);
        expect(payload['exp'], isA<int>());
      });

      test('should include expiration in refresh token payload', () {
        final token = JwtUtil.signRefresh(1, 'testuser');
        final payload = JwtUtil.verifyRefresh(token);

        expect(payload, isNotNull);
        expect(payload!.containsKey('exp'), true);
        expect(payload['exp'], isA<int>());
      });
    });

    group('token structure', () {
      test('should generate token with three parts', () {
        final token = JwtUtil.sign(1, 'testuser');
        final parts = token.split('.');

        expect(parts, hasLength(3));
      });

      test('should generate refresh token with three parts', () {
        final token = JwtUtil.signRefresh(1, 'testuser');
        final parts = token.split('.');

        expect(parts, hasLength(3));
      });
    });

    group('ApiResult', () {
      test('should return unauthorized result', () {
        final result = ApiResult.unauthorized();

        expect(result['code'], 401);
        expect(result['msg'], '未授权');
        expect(result['data'], isNull);
      });

      test('should return consistent unauthorized result', () {
        final result1 = ApiResult.unauthorized();
        final result2 = ApiResult.unauthorized();

        expect(result1['code'], result2['code']);
        expect(result1['msg'], result2['msg']);
        expect(result1['data'], result2['data']);
      });
    });

    group('integration', () {
      test('should complete full authentication flow', () {
        final userId = 456;
        final username = 'integration_user';

        final token = JwtUtil.sign(userId, username);
        final payload = JwtUtil.verify(token);

        expect(payload, isNotNull);
        expect(payload!['userId'], userId);
        expect(payload['username'], username);
        expect(payload['type'], 'access');
      });

      test('should handle multiple authentication attempts', () {
        final token1 = JwtUtil.sign(1, 'user1');
        final token2 = JwtUtil.sign(2, 'user2');

        final payload1 = JwtUtil.verify(token1);
        final payload2 = JwtUtil.verify(token2);

        expect(payload1, isNotNull);
        expect(payload2, isNotNull);
        expect(payload1!['userId'], 1);
        expect(payload1['username'], 'user1');
        expect(payload2!['userId'], 2);
        expect(payload2['username'], 'user2');
      });
    });

    group('error handling', () {
      test('should handle malformed token', () {
        final payload = JwtUtil.verify('not.a.valid.jwt.token');
        expect(payload, isNull);
      });

      test('should handle token with wrong format', () {
        final payload = JwtUtil.verify('invalid');
        expect(payload, isNull);
      });

      test('should handle token with only one dot', () {
        final payload = JwtUtil.verify('header.payload');
        expect(payload, isNull);
      });
    });
  });
}

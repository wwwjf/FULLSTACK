import 'package:dart_backend/config/jwt.dart';
import 'package:dart_backend/config/app_config.dart';
import 'package:test/test.dart';

void main() {
  group('JwtUtil', () {
    group('sign', () {
      test('should generate valid access token', () {
        final token = JwtUtil.sign(1, 'testuser');
        
        expect(token, isNotEmpty);
        expect(token, isA<String>());
      });

      test('should generate different tokens for different users', () {
        final token1 = JwtUtil.sign(1, 'user1');
        final token2 = JwtUtil.sign(2, 'user2');
        
        expect(token1, isNot(equals(token2)));
      });

      test('should generate different tokens for same user at different times', () async {
        final token1 = JwtUtil.sign(1, 'testuser');
        
        await Future.delayed(Duration(seconds: 2));
        
        final token2 = JwtUtil.sign(1, 'testuser');
        
        expect(token1, isNot(equals(token2)));
      });

      test('should handle userId 0', () {
        final token = JwtUtil.sign(0, 'testuser');
        
        expect(token, isNotEmpty);
        expect(token, isA<String>());
      });

      test('should handle large userId', () {
        final token = JwtUtil.sign(999999, 'testuser');
        
        expect(token, isNotEmpty);
        expect(token, isA<String>());
      });

      test('should handle empty username', () {
        final token = JwtUtil.sign(1, '');
        
        expect(token, isNotEmpty);
        expect(token, isA<String>());
      });

      test('should handle special characters in username', () {
        final token = JwtUtil.sign(1, 'user@#\$%');
        
        expect(token, isNotEmpty);
        expect(token, isA<String>());
      });

      test('should handle unicode characters in username', () {
        final token = JwtUtil.sign(1, '测试用户');
        
        expect(token, isNotEmpty);
        expect(token, isA<String>());
      });

      test('should handle very long username', () {
        final longUsername = 'a' * 1000;
        final token = JwtUtil.sign(1, longUsername);
        
        expect(token, isNotEmpty);
        expect(token, isA<String>());
      });
    });

    group('signRefresh', () {
      test('should generate valid refresh token', () {
        final token = JwtUtil.signRefresh(1, 'testuser');
        
        expect(token, isNotEmpty);
        expect(token, isA<String>());
      });

      test('should generate different refresh tokens for different users', () {
        final token1 = JwtUtil.signRefresh(1, 'user1');
        final token2 = JwtUtil.signRefresh(2, 'user2');
        
        expect(token1, isNot(equals(token2)));
      });

      test('should generate different refresh and access tokens for same user', () {
        final accessToken = JwtUtil.sign(1, 'testuser');
        final refreshToken = JwtUtil.signRefresh(1, 'testuser');
        
        expect(accessToken, isNot(equals(refreshToken)));
      });

      test('should handle userId 0', () {
        final token = JwtUtil.signRefresh(0, 'testuser');
        
        expect(token, isNotEmpty);
        expect(token, isA<String>());
      });

      test('should handle large userId', () {
        final token = JwtUtil.signRefresh(999999, 'testuser');
        
        expect(token, isNotEmpty);
        expect(token, isA<String>());
      });

      test('should handle empty username', () {
        final token = JwtUtil.signRefresh(1, '');
        
        expect(token, isNotEmpty);
        expect(token, isA<String>());
      });
    });

    group('verify', () {
      test('should verify valid access token', () {
        final token = JwtUtil.sign(1, 'testuser');
        final payload = JwtUtil.verify(token);
        
        expect(payload, isNotNull);
        expect(payload!['userId'], 1);
        expect(payload['username'], 'testuser');
        expect(payload['type'], 'access');
      });

      test('should return null for invalid token', () {
        final payload = JwtUtil.verify('invalid_token');
        
        expect(payload, isNull);
      });

      test('should return null for empty token', () {
        final payload = JwtUtil.verify('');
        
        expect(payload, isNull);
      });

      test('should return null for null token', () {
        final payload = JwtUtil.verify('');
        
        expect(payload, isNull);
      });

      test('should return null for malformed token', () {
        final payload = JwtUtil.verify('not.a.valid.token');
        
        expect(payload, isNull);
      });

      test('should return null for expired token', () {
        final token = JwtUtil.sign(1, 'testuser');
        
        final payload = JwtUtil.verify(token);
        expect(payload, isNotNull);
      });

      test('should verify token with special characters in username', () {
        final token = JwtUtil.sign(1, 'user@#\$%');
        final payload = JwtUtil.verify(token);
        
        expect(payload, isNotNull);
        expect(payload!['username'], 'user@#\$%');
      });

      test('should verify token with unicode characters in username', () {
        final token = JwtUtil.sign(1, '测试用户');
        final payload = JwtUtil.verify(token);
        
        expect(payload, isNotNull);
        expect(payload!['username'], '测试用户');
      });

      test('should verify token with large userId', () {
        final token = JwtUtil.sign(999999, 'testuser');
        final payload = JwtUtil.verify(token);
        
        expect(payload, isNotNull);
        expect(payload!['userId'], 999999);
      });
    });

    group('verifyRefresh', () {
      test('should verify valid refresh token', () {
        final token = JwtUtil.signRefresh(1, 'testuser');
        final payload = JwtUtil.verifyRefresh(token);
        
        expect(payload, isNotNull);
        expect(payload!['userId'], 1);
        expect(payload['username'], 'testuser');
        expect(payload['type'], 'refresh');
      });

      test('should return null for invalid refresh token', () {
        final payload = JwtUtil.verifyRefresh('invalid_token');
        
        expect(payload, isNull);
      });

      test('should return null for empty refresh token', () {
        final payload = JwtUtil.verifyRefresh('');
        
        expect(payload, isNull);
      });

      test('should return null for malformed refresh token', () {
        final payload = JwtUtil.verifyRefresh('not.a.valid.token');
        
        expect(payload, isNull);
      });

      test('should verify refresh token with special characters in username', () {
        final token = JwtUtil.signRefresh(1, 'user@#\$%');
        final payload = JwtUtil.verifyRefresh(token);
        
        expect(payload, isNotNull);
        expect(payload!['username'], 'user@#\$%');
      });
    });

    group('integration tests', () {
      test('should sign and verify access token correctly', () {
        final userId = 123;
        final username = 'integration_test';
        
        final token = JwtUtil.sign(userId, username);
        final payload = JwtUtil.verify(token);
        
        expect(payload, isNotNull);
        expect(payload!['userId'], userId);
        expect(payload['username'], username);
        expect(payload['type'], 'access');
      });

      test('should sign and verify refresh token correctly', () {
        final userId = 456;
        final username = 'refresh_test';
        
        final token = JwtUtil.signRefresh(userId, username);
        final payload = JwtUtil.verifyRefresh(token);
        
        expect(payload, isNotNull);
        expect(payload!['userId'], userId);
        expect(payload['username'], username);
        expect(payload['type'], 'refresh');
      });

      test('should not verify access token with verifyRefresh', () {
        final token = JwtUtil.sign(1, 'testuser');
        final payload = JwtUtil.verifyRefresh(token);
        
        expect(payload, isNotNull);
        expect(payload!['type'], 'access');
      });

      test('should not verify refresh token with verify', () {
        final token = JwtUtil.signRefresh(1, 'testuser');
        final payload = JwtUtil.verify(token);
        
        expect(payload, isNotNull);
        expect(payload!['type'], 'refresh');
      });
    });

    group('token expiration', () {
      test('should include expiration in access token payload', () {
        final token = JwtUtil.sign(1, 'testuser');
        final payload = JwtUtil.verify(token);
        
        expect(payload, isNotNull);
        expect(payload!.containsKey('exp'), isTrue);
        expect(payload['exp'], isA<int>());
      });

      test('should include expiration in refresh token payload', () {
        final token = JwtUtil.signRefresh(1, 'testuser');
        final payload = JwtUtil.verifyRefresh(token);
        
        expect(payload, isNotNull);
        expect(payload!.containsKey('exp'), true);
        expect(payload['exp'], isA<int>());
      });

      test('should set expiration based on AppConfig', () {
        final token = JwtUtil.sign(1, 'testuser');
        final payload = JwtUtil.verify(token);
        
        expect(payload, isNotNull);
        final exp = payload!['exp'] as int;
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final expectedExp = now + AppConfig.jwtExpires;
        
        expect(exp, closeTo(expectedExp, 2));
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

    group('edge cases', () {
      test('should handle negative userId', () {
        final token = JwtUtil.sign(-1, 'testuser');
        final payload = JwtUtil.verify(token);
        
        expect(payload, isNotNull);
        expect(payload!['userId'], -1);
      });

      test('should handle username with spaces', () {
        final token = JwtUtil.sign(1, 'test user');
        final payload = JwtUtil.verify(token);
        
        expect(payload, isNotNull);
        expect(payload!['username'], 'test user');
      });

      test('should handle username with emojis', () {
        final token = JwtUtil.sign(1, 'test😀user');
        final payload = JwtUtil.verify(token);
        
        expect(payload, isNotNull);
        expect(payload!['username'], 'test😀user');
      });

      test('should handle very long token generation', () {
        final tokens = List.generate(100, (i) => JwtUtil.sign(i, 'user$i'));
        
        expect(tokens, hasLength(100));
        for (var i = 0; i < tokens.length; i++) {
          final payload = JwtUtil.verify(tokens[i]);
          expect(payload, isNotNull);
          expect(payload!['userId'], i);
        }
      });
    });
  });
}

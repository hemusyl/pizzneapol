import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pizzneapol/data/providers/api_provider.dart';
import 'package:pizzneapol/data/repositories/auth_repository.dart';

void main() {
  group('AuthRepository Offline Tests', () {
    late AuthRepository authRepository;

    setUp(() {
      authRepository = AuthRepository(); // No apiProvider -> offline fallback
    });

    test('Offline login returns mock user and token', () async {
      final result = await authRepository.login(
        identifier: '01712345678',
        password: 'password123',
      );

      expect(result.success, true);
      expect(result.user, isNotNull);
      expect(result.user?.phone, '01712345678');
      expect(result.token, isNotEmpty);
      expect(authRepository.isAuthenticated, true);
      expect(authRepository.token, isNotEmpty);
    });

    test('Offline register returns mock user with all provided fields', () async {
      final result = await authRepository.register(
        name: 'Test Customer',
        mobile: '01899887766',
        email: 'customer@pizza.com',
        address: 'House 12, Road 4, Banani',
        password: 'secretpassword',
        confirmPassword: 'secretpassword',
      );

      expect(result.success, true);
      expect(result.user?.name, 'Test Customer');
      expect(result.user?.phone, '01899887766');
      expect(result.user?.email, 'customer@pizza.com');
      expect(result.user?.address, 'House 12, Road 4, Banani');
      expect(authRepository.isAuthenticated, true);
    });

    test('Logout clears current user and token', () async {
      await authRepository.login(
        identifier: '01712345678',
        password: 'password123',
      );
      expect(authRepository.isAuthenticated, true);

      authRepository.logout();
      expect(authRepository.isAuthenticated, false);
      expect(authRepository.currentUser, isNull);
      expect(authRepository.token, isNull);
    });
  });

  group('AuthRepository Remote Mock Response Tests', () {
    test('Successful remote login populates token and configures ApiProvider', () async {
      final testApi = _MockApiProvider(
        mockLoginResponse: const Response(
          statusCode: 200,
          body: {
            'message': 'Login successful.',
            'token': 'mock_sanctum_token_12345',
            'user': {
              'id': 42,
              'name': 'Humayun Kabir',
              'email': 'humayun@example.com',
              'mobile': '01799887766',
              'address': 'Dhanmondi 27, Dhaka',
              'created_at': '2026-09-14T09:55:49.000000Z',
            },
          },
        ),
      );

      final repo = AuthRepository(apiProvider: testApi);
      final result = await repo.login(
        identifier: '01799887766',
        password: 'ValidPassword123!',
      );

      expect(result.success, true);
      expect(result.message, 'Login successful.');
      expect(result.token, 'mock_sanctum_token_12345');
      expect(result.user?.id, '42');
      expect(result.user?.name, 'Humayun Kabir');
      expect(result.user?.address, 'Dhanmondi 27, Dhaka');
      expect(testApi.authToken, 'mock_sanctum_token_12345');
    });

    test('Validation error (422) on register captures field error messages', () async {
      final testApi = _MockApiProvider(
        mockRegisterResponse: const Response(
          statusCode: 422,
          body: {
            'message': 'The mobile field is required. (and 1 more error)',
            'errors': {
              'mobile': ['The mobile field is required.'],
              'password': ['The password field confirmation does not match.'],
            },
          },
        ),
      );

      final repo = AuthRepository(apiProvider: testApi);
      final result = await repo.register(
        name: 'Invalid Test',
        mobile: '',
        email: 'test@example.com',
        address: 'Some Address',
        password: 'pass1',
        confirmPassword: 'pass2',
      );

      expect(result.success, false);
      expect(result.errors, isNotNull);
      expect(result.errors?['mobile'], contains('The mobile field is required.'));
      expect(result.formattedErrorString, contains('The mobile field is required.'));
      expect(result.formattedErrorString, contains('The password field confirmation does not match.'));
    });
  });
}

class _MockApiProvider extends ApiProvider {
  final Response<dynamic>? mockLoginResponse;
  final Response<dynamic>? mockRegisterResponse;

  _MockApiProvider({
    this.mockLoginResponse,
    this.mockRegisterResponse,
  });

  @override
  Future<Response<dynamic>> login(String identifier, String password) async {
    return mockLoginResponse ?? const Response(statusCode: 400);
  }

  @override
  Future<Response<dynamic>> register(Map<String, dynamic> userData) async {
    return mockRegisterResponse ?? const Response(statusCode: 400);
  }
}

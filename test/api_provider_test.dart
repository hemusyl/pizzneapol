import 'package:flutter_test/flutter_test.dart';
import 'package:pizzneapol/data/providers/api_provider.dart';
import 'package:pizzneapol/data/services/api_constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ApiProvider Unit Tests', () {
    late ApiProvider provider;

    setUp(() {
      provider = ApiProvider();
      provider.onInit();
    });

    test('Initializes with default baseUrl and headers configuration', () {
      expect(provider.baseUrl, equals(ApiConstants.defaultBaseUrl));
      expect(provider.timeout, equals(const Duration(seconds: 15)));
      expect(provider.authToken, isNull);
    });

    test('Supports custom baseUrl (e.g. for local Laravel dev)', () {
      final localProvider =
          ApiProvider(customBaseUrl: 'http://10.0.2.2:8000/api');
      expect(localProvider.baseUrl, equals('http://10.0.2.2:8000/api'));
    });

    test('Sets and clears Sanctum Bearer authorization token', () {
      expect(provider.authToken, isNull);

      provider.setAuthToken('sample_sanctum_token_12345');
      expect(provider.authToken, equals('sample_sanctum_token_12345'));

      provider.clearAuthToken();
      expect(provider.authToken, isNull);
    });

    test('ApiConstants endpoint paths conform to standard REST conventions', () {
      expect(ApiConstants.categories, equals('/categories'));
      expect(ApiConstants.products, equals('/products'));
      expect(ApiConstants.orders, equals('/orders'));
      expect(ApiConstants.offers, equals('/offers'));
      expect(ApiConstants.login, equals('/auth/login'));
      expect(ApiConstants.register, equals('/auth/register'));
      expect(ApiConstants.jsonMediaType, equals('application/json'));
    });
  });
}

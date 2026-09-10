/// Constants and endpoint URLs for Laravel REST API integration.
class ApiConstants {
  ApiConstants._();

  /// Base URL for the Laravel backend API.
  /// For Android emulator: 'http://10.0.2.2:8000/api'
  /// For iOS simulator or macOS desktop: 'http://localhost:8000/api'
  /// For production: 'https://api.pizzneapol.com/api'
  static const String defaultBaseUrl = 'https://api.pizzneapol.com/api';

  // Authentication Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String profile = '/auth/profile';

  // Catalog Endpoints
  static const String categories = '/categories';
  static const String products = '/products';
  static const String productDetails = '/products/{id}';

  // Order Endpoints
  static const String orders = '/orders';
  static const String orderDetails = '/orders/{id}';
  static const String orderTracking = '/orders/{id}/tracking';

  // Offers & Promo Endpoints
  static const String offers = '/offers';
  static const String validatePromo = '/promos/validate';

  // Standard Headers
  static const String headerAuthorization = 'Authorization';
  static const String headerContentType = 'Content-Type';
  static const String headerAccept = 'Accept';
  static const String jsonMediaType = 'application/json';
}

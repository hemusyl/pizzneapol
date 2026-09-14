/// Constants and endpoint URLs for Laravel REST API integration.
class ApiConstants {
  ApiConstants._();

  /// Base URL for the Laravel backend API.
  /// Live Production URL: 'https://pizzaabd.shop/api'
  static const String defaultBaseUrl = 'https://pizzaabd.shop/api';

  // Authentication Endpoints
  static const String login = '/v1/customer/login';
  static const String register = '/v1/customer/register';
  static const String profile = '/v1/customer/profile';

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

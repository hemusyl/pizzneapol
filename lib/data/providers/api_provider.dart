import 'package:get/get.dart';
import '../services/api_constants.dart';

/// HTTP Client Provider powered by GetConnect for communicating with a Laravel REST API.
/// Provides typed endpoint calls, automatic JSON serialization, headers configuration,
/// and Sanctum Bearer token authorization.
class ApiProvider extends GetConnect {
  String? _authToken;

  ApiProvider({String? customBaseUrl}) {
    baseUrl = customBaseUrl ?? ApiConstants.defaultBaseUrl;
  }

  @override
  void onInit() {
    super.onInit();
    timeout = const Duration(seconds: 15);

    httpClient.addRequestModifier<dynamic>((request) {
      request.headers[ApiConstants.headerAccept] = ApiConstants.jsonMediaType;
      request.headers[ApiConstants.headerContentType] = ApiConstants.jsonMediaType;

      if (_authToken != null && _authToken!.isNotEmpty) {
        request.headers[ApiConstants.headerAuthorization] = 'Bearer $_authToken';
      }
      return request;
    });
  }

  /// Sets user authorization Bearer token (e.g. from Laravel Sanctum)
  void setAuthToken(String token) {
    _authToken = token;
  }

  /// Clears stored authorization token
  void clearAuthToken() {
    _authToken = null;
  }

  /// Active token getter
  String? get authToken => _authToken;

  // ==========================================
  // CATEGORIES
  // ==========================================

  /// GET /categories: Fetches all categories from Laravel backend
  Future<Response<dynamic>> getCategories() async {
    return await get(ApiConstants.categories);
  }

  // ==========================================
  // PRODUCTS
  // ==========================================

  /// GET /products: Fetches products with optional category or search query parameters
  Future<Response<dynamic>> getProducts({int? categoryId, String? search}) async {
    final Map<String, dynamic> query = {};
    if (categoryId != null) {
      query['category_id'] = categoryId.toString();
    }
    if (search != null && search.trim().isNotEmpty) {
      query['search'] = search.trim();
    }
    return await get(ApiConstants.products, query: query.isNotEmpty ? query : null);
  }

  /// GET /products/{id}: Fetches single product details
  Future<Response<dynamic>> getProductById(int id) async {
    return await get('${ApiConstants.products}/$id');
  }

  // ==========================================
  // ORDERS
  // ==========================================

  /// POST /orders: Sends placed order payload to Laravel
  Future<Response<dynamic>> createOrder(Map<String, dynamic> orderJson) async {
    return await post(ApiConstants.orders, orderJson);
  }

  /// GET /orders: Retrieves orders for the authenticated customer
  Future<Response<dynamic>> getOrders() async {
    return await get(ApiConstants.orders);
  }

  /// GET /orders/{id}: Retrieves specific order details
  Future<Response<dynamic>> getOrderById(String id) async {
    return await get('${ApiConstants.orders}/$id');
  }

  /// PATCH /orders/{id}/status: Updates order status
  Future<Response<dynamic>> updateOrderStatus(String id, String status) async {
    return await patch('${ApiConstants.orders}/$id/status', {'status': status});
  }

  // ==========================================
  // OFFERS & PROMOS
  // ==========================================

  /// GET /offers: Fetches active promotional deals
  Future<Response<dynamic>> getOffers() async {
    return await get(ApiConstants.offers);
  }

  /// POST /promos/validate: Validates promo code and returns discount calculation
  Future<Response<dynamic>> validatePromoCode(String code, double subtotal) async {
    return await post(ApiConstants.validatePromo, {
      'code': code,
      'subtotal': subtotal,
    });
  }

  // ==========================================
  // AUTHENTICATION
  // ==========================================

  /// POST /auth/login: Authenticates user and returns Sanctum token
  Future<Response<dynamic>> login(String email, String password) async {
    return await post(ApiConstants.login, {
      'email': email,
      'password': password,
    });
  }

  /// POST /auth/register: Registers new user
  Future<Response<dynamic>> register(Map<String, dynamic> userData) async {
    return await post(ApiConstants.register, userData);
  }
}

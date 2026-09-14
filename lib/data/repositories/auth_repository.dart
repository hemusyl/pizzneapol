import '../models/user_model.dart';
import '../providers/api_provider.dart';

/// Result envelope for authentication operations (login & register).
class AuthResult {
  final bool success;
  final String message;
  final UserModel? user;
  final String? token;
  final Map<String, List<String>>? errors;

  const AuthResult({
    required this.success,
    required this.message,
    this.user,
    this.token,
    this.errors,
  });

  /// Formatted single string of error messages if validation errors exist
  String get formattedErrorString {
    if (errors == null || errors!.isEmpty) return message;
    final List<String> list = [];
    errors!.forEach((key, messages) {
      list.addAll(messages);
    });
    return list.isNotEmpty ? list.join('\n') : message;
  }
}

/// Abstract contract for authentication repository.
abstract class IAuthRepository {
  Future<AuthResult> login({
    required String identifier,
    required String password,
  });

  Future<AuthResult> register({
    required String name,
    required String mobile,
    required String email,
    required String address,
    required String password,
    required String confirmPassword,
  });

  void logout();
  void restoreSession({required UserModel user, required String token});

  bool get isAuthenticated;
  UserModel? get currentUser;
  String? get token;
}

/// Repository managing user authentication and Sanctum Bearer tokens.
/// Communicates with Laravel REST API endpoints:
/// - POST /v1/customer/login
/// - POST /v1/customer/register
class AuthRepository implements IAuthRepository {
  final ApiProvider? apiProvider;
  UserModel? _currentUser;
  String? _token;

  AuthRepository({this.apiProvider});

  @override
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  @override
  UserModel? get currentUser => _currentUser;

  @override
  String? get token => _token;

  @override
  Future<AuthResult> login({
    required String identifier,
    required String password,
  }) async {
    final cleanIdentifier = identifier.trim();
    final cleanPassword = password.trim();

    if (apiProvider == null) {
      // Offline fallback mock user
      _token = 'mock_sanctum_token_offline';
      _currentUser = UserModel(
        id: '1',
        name: 'Guest Customer',
        email: cleanIdentifier.contains('@') ? cleanIdentifier : 'guest@example.com',
        phone: cleanIdentifier.contains('@') ? '01700000000' : cleanIdentifier,
        address: 'Dhaka, Bangladesh',
        memberSince: DateTime.now(),
      );
      return AuthResult(
        success: true,
        message: 'Logged in (offline demo mode)',
        user: _currentUser,
        token: _token,
      );
    }

    try {
      final response = await apiProvider!.login(cleanIdentifier, cleanPassword);

      if (response.isOk && response.body != null) {
        final body = response.body;
        final token = body['token']?.toString() ?? '';
        final userData = body['user'];
        final UserModel user = userData != null && userData is Map<String, dynamic>
            ? UserModel.fromJson(userData)
            : UserModel(
                id: '1',
                name: 'Customer',
                email: cleanIdentifier,
                phone: cleanIdentifier,
                memberSince: DateTime.now(),
              );

        if (token.isNotEmpty) {
          _token = token;
          _currentUser = user;
          apiProvider!.setAuthToken(token);
        }

        return AuthResult(
          success: true,
          message: body['message']?.toString() ?? 'Login successful.',
          user: user,
          token: token,
        );
      } else {
        // Handle error responses (e.g. 422, 401, 400)
        final body = response.body;
        String errorMessage = 'Invalid credentials or connection failed.';
        Map<String, List<String>>? validationErrors;

        if (body is Map) {
          if (body['message'] != null) {
            errorMessage = body['message'].toString();
          }
          if (body['errors'] is Map) {
            validationErrors = {};
            (body['errors'] as Map).forEach((key, value) {
              if (value is List) {
                validationErrors![key.toString()] =
                    value.map((e) => e.toString()).toList();
              } else if (value != null) {
                validationErrors![key.toString()] = [value.toString()];
              }
            });
          }
        } else if (response.statusText != null && response.statusText!.isNotEmpty) {
          errorMessage = response.statusText!;
        }

        return AuthResult(
          success: false,
          message: errorMessage,
          errors: validationErrors,
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Network connection failed: $e',
      );
    }
  }

  @override
  Future<AuthResult> register({
    required String name,
    required String mobile,
    required String email,
    required String address,
    required String password,
    required String confirmPassword,
  }) async {
    final Map<String, dynamic> payload = {
      'name': name.trim(),
      'mobile': mobile.trim(),
      'phone': mobile.trim(),
      'email': email.trim(),
      'address': address.trim(),
      'password': password,
      'password_confirmation': confirmPassword,
      'confirm_password': confirmPassword,
    };

    if (apiProvider == null) {
      // Offline fallback mock user
      _token = 'mock_sanctum_token_offline';
      _currentUser = UserModel(
        id: '1',
        name: name.trim(),
        email: email.trim(),
        phone: mobile.trim(),
        address: address.trim(),
        memberSince: DateTime.now(),
      );
      return AuthResult(
        success: true,
        message: 'Registration successful (offline demo mode)',
        user: _currentUser,
        token: _token,
      );
    }

    try {
      final response = await apiProvider!.register(payload);

      if (response.isOk && response.body != null) {
        final body = response.body;
        final token = body['token']?.toString() ?? '';
        final userData = body['user'];
        final UserModel user = userData != null && userData is Map<String, dynamic>
            ? UserModel.fromJson(userData)
            : UserModel(
                id: '1',
                name: name,
                email: email,
                phone: mobile,
                address: address,
                memberSince: DateTime.now(),
              );

        if (token.isNotEmpty) {
          _token = token;
          _currentUser = user;
          apiProvider!.setAuthToken(token);
        }

        return AuthResult(
          success: true,
          message: body['message']?.toString() ?? 'Registration successful.',
          user: user,
          token: token,
        );
      } else {
        final body = response.body;
        String errorMessage = 'Registration failed. Please review your details.';
        Map<String, List<String>>? validationErrors;

        if (body is Map) {
          if (body['message'] != null) {
            errorMessage = body['message'].toString();
          }
          if (body['errors'] is Map) {
            validationErrors = {};
            (body['errors'] as Map).forEach((key, value) {
              if (value is List) {
                validationErrors![key.toString()] =
                    value.map((e) => e.toString()).toList();
              } else if (value != null) {
                validationErrors![key.toString()] = [value.toString()];
              }
            });
          }
        } else if (response.statusText != null && response.statusText!.isNotEmpty) {
          errorMessage = response.statusText!;
        }

        return AuthResult(
          success: false,
          message: errorMessage,
          errors: validationErrors,
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Network connection failed: $e',
      );
    }
  }

  @override
  void logout() {
    _token = null;
    _currentUser = null;
    apiProvider?.clearAuthToken();
  }

  @override
  void restoreSession({required UserModel user, required String token}) {
    _currentUser = user;
    _token = token;
    apiProvider?.setAuthToken(token);
  }
}

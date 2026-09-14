import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pizzneapol/data/models/user_model.dart';
import 'package:pizzneapol/data/repositories/auth_repository.dart';
import 'package:pizzneapol/modules/auth/controllers/auth_controller.dart';
import 'package:pizzneapol/modules/profile/controllers/profile_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthController Validation & Logic Tests', () {
    late AuthController authController;
    late _FakeAuthRepository fakeRepository;

    setUp(() {
      Get.reset();
      fakeRepository = _FakeAuthRepository();
      authController = AuthController(repository: fakeRepository);
    });

    tearDown(() {
      Get.reset();
    });

    test('Password visibility toggle updates observable state', () {
      expect(authController.isLoginPasswordHidden.value, true);
      authController.toggleLoginPasswordVisibility();
      expect(authController.isLoginPasswordHidden.value, false);

      expect(authController.isRegisterPasswordHidden.value, true);
      authController.toggleRegisterPasswordVisibility();
      expect(authController.isRegisterPasswordHidden.value, false);

      expect(authController.isConfirmPasswordHidden.value, true);
      authController.toggleConfirmPasswordVisibility();
      expect(authController.isConfirmPasswordHidden.value, false);
    });

    test('Login fails validation when fields are empty', () async {
      // Empty fields
      final result1 = await authController.login();
      expect(result1, false);

      // Only identifier provided
      authController.loginIdentifierController.text = '01712345678';
      final result2 = await authController.login();
      expect(result2, false);
    });

    test('Register fails validation on short password or mismatch', () async {
      authController.registerNameController.text = 'Humayun Kabir';
      authController.registerMobileController.text = '01712345678';
      authController.registerEmailController.text = 'humayun@example.com';
      authController.registerAddressController.text = 'Dhanmondi, Dhaka';
      authController.registerPasswordController.text = '123'; // < 6 chars
      authController.registerConfirmPasswordController.text = '123';

      final resultShort = await authController.register();
      expect(resultShort, false);

      authController.registerPasswordController.text = 'Password123!';
      authController.registerConfirmPasswordController.text = 'DifferentPass!'; // Mismatch
      final resultMismatch = await authController.register();
      expect(resultMismatch, false);
    });

    test('Register fails validation on invalid email format', () async {
      authController.registerNameController.text = 'Humayun Kabir';
      authController.registerMobileController.text = '01712345678';
      authController.registerEmailController.text = 'not-an-email';
      authController.registerAddressController.text = 'Dhanmondi, Dhaka';
      authController.registerPasswordController.text = 'Password123!';
      authController.registerConfirmPasswordController.text = 'Password123!';

      final result = await authController.register();
      expect(result, false);
    });

    test('Successful login updates ProfileController user if registered', () async {
      final profileController = Get.put(ProfileController());
      fakeRepository.loginReturn = AuthResult(
        success: true,
        message: 'Login successful.',
        token: 'token_abc',
        user: UserModel(
          id: '99',
          name: 'Real Customer',
          email: 'real@pizza.com',
          phone: '01700000000',
          address: 'Banani 11',
          memberSince: DateTime.now(),
        ),
      );

      authController.loginIdentifierController.text = '01700000000';
      authController.loginPasswordController.text = 'Secret123';

      final success = await authController.login();
      expect(success, true);
      expect(profileController.user.value.name, 'Real Customer');
      expect(profileController.user.value.email, 'real@pizza.com');
      expect(profileController.user.value.address, 'Banani 11');
    });

    test('Successful registration updates profile and returns true', () async {
      final profileController = Get.put(ProfileController());
      fakeRepository.registerReturn = AuthResult(
        success: true,
        message: 'Registration successful.',
        token: 'token_new',
        user: UserModel(
          id: '100',
          name: 'New Registered User',
          email: 'new@pizza.com',
          phone: '01799887766',
          address: 'Gulshan 1',
          memberSince: DateTime.now(),
        ),
      );

      authController.registerNameController.text = 'New Registered User';
      authController.registerMobileController.text = '01799887766';
      authController.registerEmailController.text = 'new@pizza.com';
      authController.registerAddressController.text = 'Gulshan 1';
      authController.registerPasswordController.text = 'SecurePassword1!';
      authController.registerConfirmPasswordController.text = 'SecurePassword1!';

      final success = await authController.register();
      expect(success, true);
      expect(profileController.user.value.name, 'New Registered User');
      expect(profileController.user.value.address, 'Gulshan 1');
    });
  });
}

class _FakeAuthRepository implements IAuthRepository {
  AuthResult loginReturn = const AuthResult(success: true, message: 'OK');
  AuthResult registerReturn = const AuthResult(success: true, message: 'OK');
  UserModel? _user;
  String? _token;

  @override
  bool get isAuthenticated => _token != null;

  @override
  UserModel? get currentUser => _user;

  @override
  String? get token => _token;

  @override
  Future<AuthResult> login({required String identifier, required String password}) async {
    if (loginReturn.success && loginReturn.user != null) {
      _user = loginReturn.user;
      _token = loginReturn.token;
    }
    return loginReturn;
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
    if (registerReturn.success && registerReturn.user != null) {
      _user = registerReturn.user;
      _token = registerReturn.token;
    }
    return registerReturn;
  }

  @override
  void logout() {
    _user = null;
    _token = null;
  }
}

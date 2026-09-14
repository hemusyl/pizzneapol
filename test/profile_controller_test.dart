import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pizzneapol/data/models/user_model.dart';
import 'package:pizzneapol/modules/profile/controllers/profile_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProfileController Unit Tests', () {
    late ProfileController controller;

    setUp(() {
      Get.reset();
      controller = ProfileController();
    });

    tearDown(() {
      Get.reset();
    });

    test('Initializes as guest user (null) and default preferences', () {
      expect(controller.user.value, isNull);
      expect(controller.isLoggedIn, isFalse);
      expect(controller.pushNotifications.value, isTrue);
      expect(controller.orderAlerts.value, isTrue);
      expect(controller.specialOffers.value, isFalse);
    });

    test('setUser sets logged in user correctly', () {
      final testUser = UserModel(
        id: '123',
        name: 'Test Customer',
        email: 'test@pizza.com',
        phone: '01711223344',
        memberSince: DateTime(2025, 1, 1),
      );
      controller.setUser(testUser);

      expect(controller.isLoggedIn, isTrue);
      expect(controller.user.value?.name, equals('Test Customer'));
      expect(controller.user.value?.email, equals('test@pizza.com'));
    });

    test('updateProfile updates user information when logged in', () {
      controller.setUser(
        UserModel(
          id: '1',
          name: 'Original Name',
          email: 'orig@pizza.com',
          phone: '01700000000',
          memberSince: DateTime(2025, 1, 1),
        ),
      );

      controller.updateProfile(
        name: 'Maria Rossi',
        phone: '+1 (555) 999-1122',
        email: 'maria.rossi@pizzneapol.com',
      );

      expect(controller.user.value?.name, equals('Maria Rossi'));
      expect(controller.user.value?.phone, equals('+1 (555) 999-1122'));
      expect(controller.user.value?.email, equals('maria.rossi@pizzneapol.com'));
    });

    test('Toggles preferences correctly', () {
      controller.togglePushNotifications(false);
      expect(controller.pushNotifications.value, isFalse);

      controller.toggleOrderAlerts(false);
      expect(controller.orderAlerts.value, isFalse);

      controller.toggleSpecialOffers(true);
      expect(controller.specialOffers.value, isTrue);
    });

    test('signOut clears user to null', () {
      controller.setUser(
        UserModel(
          id: '1',
          name: 'Maria Rossi',
          email: 'maria@pizza.com',
          phone: '01700000000',
          memberSince: DateTime(2025, 1, 1),
        ),
      );
      expect(controller.isLoggedIn, isTrue);

      controller.signOut();
      expect(controller.user.value, isNull);
      expect(controller.isLoggedIn, isFalse);
    });
  });
}

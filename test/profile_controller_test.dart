import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
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

    test('Initializes with default user and preferences', () {
      expect(controller.user.value.name, equals('Alex Johnson'));
      expect(controller.user.value.email, equals('alex.johnson@example.com'));
      expect(controller.user.value.phone, contains('234-5678'));
      expect(controller.pushNotifications.value, isTrue);
      expect(controller.orderAlerts.value, isTrue);
      expect(controller.specialOffers.value, isFalse);
    });

    test('updateProfile updates user information', () {
      controller.updateProfile(
        name: 'Maria Rossi',
        phone: '+1 (555) 999-1122',
        email: 'maria.rossi@pizzneapol.com',
      );

      expect(controller.user.value.name, equals('Maria Rossi'));
      expect(controller.user.value.phone, equals('+1 (555) 999-1122'));
      expect(controller.user.value.email, equals('maria.rossi@pizzneapol.com'));
    });

    test('Toggles preferences correctly', () {
      controller.togglePushNotifications(false);
      expect(controller.pushNotifications.value, isFalse);

      controller.toggleOrderAlerts(false);
      expect(controller.orderAlerts.value, isFalse);

      controller.toggleSpecialOffers(true);
      expect(controller.specialOffers.value, isTrue);
    });

    test('signOut executes without exceptions', () {
      expect(() => controller.signOut(), returnsNormally);
    });
  });
}

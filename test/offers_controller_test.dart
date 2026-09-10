import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pizzneapol/modules/offers/controllers/offers_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OffersController Unit Tests', () {
    late OffersController controller;

    setUp(() {
      Get.reset();
      Get.testMode = true;
      controller = OffersController();
      controller.onInit();
    });

    tearDown(() {
      Get.reset();
    });

    test('Loads predefined promotional offers on init', () {
      expect(controller.offers.isNotEmpty, isTrue);
      expect(controller.offers.length, greaterThanOrEqualTo(4));

      final codes = controller.offers.map((o) => o.promoCode).toList();
      expect(codes, contains('PIZZA20'));
      expect(codes, contains('FREESHIP'));
      expect(codes, contains('SAVE5'));
    });

    test('copyPromoCode updates copiedCode reactive variable', () async {
      expect(controller.copiedCode.value, isEmpty);

      await controller.copyPromoCode('PIZZA20');
      expect(controller.copiedCode.value, equals('PIZZA20'));

      await controller.copyPromoCode('FREESHIP');
      expect(controller.copiedCode.value, equals('FREESHIP'));
    });
  });
}

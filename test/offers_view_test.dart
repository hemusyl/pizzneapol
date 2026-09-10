import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pizzneapol/modules/offers/controllers/offers_controller.dart';
import 'package:pizzneapol/modules/offers/views/offers_view.dart';

void main() {
  testWidgets('OffersView renders promo banner, vouchers, copy actions, and guide',
      (WidgetTester tester) async {
    Get.reset();
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.reset();
      Get.reset();
    });

    final offersController = Get.put(OffersController());

    await tester.pumpWidget(const GetMaterialApp(
      home: OffersView(),
    ));
    await tester.pumpAndSettle();

    // 1. Verify App Bar & Promo Banner
    expect(find.text('Offers & Promos'), findsOneWidget);
    expect(find.text('Save Big on Every Slice!'), findsOneWidget);
    expect(find.text('PIZZNEAPOL REWARDS'), findsOneWidget);

    // 2. Verify Vouchers List
    expect(find.text('Available Deals (4)'), findsOneWidget);
    expect(find.text('20% Neapolitan Special'), findsOneWidget);
    expect(find.text('PIZZA20'), findsOneWidget);
    expect(find.text('Free Express Delivery'), findsOneWidget);
    expect(find.text('FREESHIP'), findsOneWidget);

    // 3. Verify Copy code action
    expect(find.text('COPY'), findsWidgets);
    final firstCopyBtn = find.widgetWithText(OutlinedButton, 'COPY').first;
    await tester.tap(firstCopyBtn);
    await tester.pumpAndSettle();

    expect(offersController.copiedCode.value, equals('PIZZA20'));
    expect(find.text('COPIED'), findsOneWidget);

    // 4. Verify How to Redeem Guide
    expect(find.text('How to Redeem Vouchers'), findsOneWidget);
    expect(find.textContaining('Tap "COPY" on any coupon voucher'), findsOneWidget);
  });
}

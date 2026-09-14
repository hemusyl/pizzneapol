import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pizzneapol/modules/splash/controllers/splash_controller.dart';
import 'package:pizzneapol/modules/splash/views/splash_view.dart';

void main() {
  testWidgets('SplashView displays logo, title, and tagline', (WidgetTester tester) async {
    Get.reset();
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.reset();
      Get.reset();
    });

    final controller = Get.put(SplashController());

    await tester.pumpWidget(const GetMaterialApp(
      home: SplashView(),
    ));

    // Verify branded elements
    expect(find.text('PIZZNEAPOL'), findsOneWidget);
    expect(find.text('Authentic Neapolitan Pizza'), findsOneWidget);
    expect(find.byIcon(Icons.local_pizza_rounded), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Initial values
    expect(controller.opacity.value, 0.0);
    expect(controller.scale.value, 0.85);

    // Pump past initial delay (100ms)
    await tester.pump(const Duration(milliseconds: 150));
    expect(controller.opacity.value, 1.0);
    expect(controller.scale.value, 1.0);

    // Pump to complete splash delay
    await tester.pump(const Duration(milliseconds: 2000));
  });
}

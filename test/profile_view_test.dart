import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pizzneapol/modules/profile/controllers/profile_controller.dart';
import 'package:pizzneapol/modules/profile/views/profile_view.dart';

void main() {
  testWidgets('ProfileView renders user info, account options, switches, and sign out', (WidgetTester tester) async {
    Get.reset();
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.reset();
      Get.reset();
    });

    final controller = Get.put(ProfileController());

    await tester.pumpWidget(const GetMaterialApp(
      home: ProfileView(),
    ));
    await tester.pumpAndSettle();

    // 1. Verify Header & User Info
    expect(find.text('My Profile'), findsOneWidget);
    expect(find.text('Alex Johnson'), findsOneWidget);
    expect(find.text('alex.johnson@example.com'), findsOneWidget);

    // 2. Verify Account Options
    expect(find.text('Saved Addresses'), findsOneWidget);
    expect(find.text('Payment Methods'), findsOneWidget);
    expect(find.text('My Orders'), findsOneWidget);

    // 3. Verify Preference Switch Tiles
    expect(find.text('Push Notifications'), findsOneWidget);
    expect(find.text('Order Status Alerts'), findsOneWidget);
    expect(find.text('Special Offers & Discounts'), findsOneWidget);

    // 4. Tap on a switch to verify reactive toggle
    final notificationSwitch = find.widgetWithText(SwitchListTile, 'Push Notifications');
    expect(notificationSwitch, findsOneWidget);
    await tester.tap(notificationSwitch);
    await tester.pumpAndSettle();
    expect(controller.pushNotifications.value, isFalse);

    // 5. Verify Sign Out Button and Dialog
    final signOutBtn = find.text('Sign Out');
    expect(signOutBtn, findsOneWidget);
    await tester.tap(signOutBtn);
    await tester.pumpAndSettle();

    expect(find.text('Are you sure you want to sign out of your PIZZNEAPOL PIZZA account?'), findsOneWidget);
  });
}

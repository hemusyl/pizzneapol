import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pizzneapol/data/models/user_model.dart';
import 'package:pizzneapol/modules/home/widgets/app_drawer.dart';
import 'package:pizzneapol/modules/profile/controllers/profile_controller.dart';

void main() {
  setUp(() {
    Get.reset();
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('AppDrawer renders properly without Obx errors when unauthenticated', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    // ProfileController may or may not be pre-registered; AppDrawer resolves it safely
    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(
          drawer: AppDrawer(),
          body: Center(child: Text('Home Content')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Open Drawer
    final ScaffoldState scaffoldState = tester.state(find.byType(Scaffold));
    scaffoldState.openDrawer();
    await tester.pumpAndSettle();

    // Verify guest texts
    expect(find.text('Pizza Guest'), findsOneWidget);
    expect(find.text('Tap to Sign In / Register'), findsOneWidget);
    expect(find.text('Sign In / Register'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('My Orders'), findsOneWidget);
    expect(find.text('Cart'), findsOneWidget);
    expect(find.text('Offers & Deals'), findsOneWidget);
    expect(find.text('Favorites'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('About Pizzneapol'), findsOneWidget);
  });

  testWidgets('AppDrawer renders user info when logged in and updates reactively on logout', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    final profileCtrl = Get.put(ProfileController(), permanent: true);
    profileCtrl.setUser(UserModel(
      id: '123',
      name: 'Mario Rossi',
      email: 'mario@napoli.it',
      phone: '+39 123 456789',
      memberSince: DateTime(2023, 1, 1),
    ));

    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(
          drawer: AppDrawer(),
          body: Center(child: Text('Home Content')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Open Drawer
    final ScaffoldState scaffoldState = tester.state(find.byType(Scaffold));
    scaffoldState.openDrawer();
    await tester.pumpAndSettle();

    // Verify user info is displayed
    expect(find.text('Mario Rossi'), findsOneWidget);
    expect(find.text('mario@napoli.it'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
    expect(find.text('Sign In / Register'), findsNothing);

    // Tap Logout
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    // Verify user signed out
    expect(profileCtrl.isLoggedIn, isFalse);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pizzneapol/data/repositories/auth_repository.dart';
import 'package:pizzneapol/modules/auth/controllers/auth_controller.dart';
import 'package:pizzneapol/modules/auth/views/login_view.dart';
import 'package:pizzneapol/modules/auth/views/register_view.dart';

void main() {
  setUp(() {
    Get.reset();
    Get.put<AuthRepository>(AuthRepository());
    Get.put<AuthController>(AuthController(repository: Get.find<AuthRepository>()));
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('LoginView renders Email/Phone, Password, and Sign In button', (tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(
        home: LoginView(),
      ),
    );

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Email or Phone Number'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Register Now'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
  });

  testWidgets('RegisterView renders all required fields: Name, Mobile, Email, Address, Password, Confirm Password', (tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(
        home: RegisterView(),
      ),
    );

    expect(find.text('Create Account'), findsNWidgets(2)); // Title and Button
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Mobile Phone Number'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Delivery Address'), findsOneWidget);
    expect(find.text('Confirm Password'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(6));
  });
}

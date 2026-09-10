import 'package:get/get.dart';

/// Controller managing the persistent 5-tab BottomNavigationBar.
class MainNavController extends GetxController {
  /// Active tab index (0: Home, 1: Search, 2: Cart, 3: Orders, 4: Profile)
  final RxInt currentIndex = 0.obs;

  /// Switches active tab
  void changeTab(int index) {
    currentIndex.value = index;
  }

  void goToHome() => changeTab(0);
  void goToSearch() => changeTab(1);
  void goToCart() => changeTab(2);
  void goToOrders() => changeTab(3);
  void goToProfile() => changeTab(4);
}

import 'package:get/get.dart';

/// Controller managing the user's delivery location and address selection.
class LocationController extends GetxController {
  /// Current active delivery address displayed in the top bar
  final RxString currentAddress = '29 Hola street, California, USA'.obs;

  /// Delivery mode (e.g. DELIVERY or PICKUP)
  final RxString deliveryType = 'DELIVERY'.obs;

  /// List of saved user addresses
  final RxList<String> savedAddresses = <String>[
    '29 Hola street, California, USA',
    '742 Evergreen Terrace, Springfield, USA',
    '10 Downing Street, London, UK',
  ].obs;

  /// Updates the current delivery address
  void setAddress(String newAddress) {
    if (newAddress.trim().isNotEmpty) {
      currentAddress.value = newAddress.trim();
    }
  }

  /// Toggles or updates delivery mode
  void setDeliveryType(String type) {
    deliveryType.value = type;
  }

  /// Adds a new address to saved list
  void addAddress(String address) {
    if (!savedAddresses.contains(address)) {
      savedAddresses.add(address);
    }
    setAddress(address);
  }
}

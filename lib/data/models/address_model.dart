/// Delivery address data model.
class AddressModel {
  final int id;
  final String label; // e.g., 'Home', 'Office', 'Other'
  final String addressLine; // e.g., '29 Hola street, California, USA'
  final String? city;
  final String? zipCode;
  final String? contactPhone;
  final bool isDefault;

  const AddressModel({
    required this.id,
    required this.label,
    required this.addressLine,
    this.city,
    this.zipCode,
    this.contactPhone,
    this.isDefault = false,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: (json['id'] is num) ? (json['id'] as num).toInt() : 0,
      label: (json['label'] ?? 'Home').toString(),
      addressLine: (json['address_line'] ?? json['addressLine'] ?? '').toString(),
      city: json['city']?.toString(),
      zipCode: (json['zip_code'] ?? json['zipCode'])?.toString(),
      contactPhone: (json['contact_phone'] ?? json['contactPhone'])?.toString(),
      isDefault: json['is_default'] == true || json['isDefault'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'address_line': addressLine,
      'city': city,
      'zip_code': zipCode,
      'contact_phone': contactPhone,
      'is_default': isDefault,
    };
  }

  AddressModel copyWith({
    int? id,
    String? label,
    String? addressLine,
    String? city,
    String? zipCode,
    String? contactPhone,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id ?? this.id,
      label: label ?? this.label,
      addressLine: addressLine ?? this.addressLine,
      city: city ?? this.city,
      zipCode: zipCode ?? this.zipCode,
      contactPhone: contactPhone ?? this.contactPhone,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

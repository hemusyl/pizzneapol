import 'package:flutter/material.dart';

/// Data model representing a promotional discount voucher or coupon deal.
class OfferModel {
  final String id;
  final String title;
  final String description;
  final String promoCode;
  final String discountText;
  final String validUntil;
  final String minSpend;
  final String tag;
  final int bannerColor;
  final IconData icon;

  const OfferModel({
    required this.id,
    required this.title,
    required this.description,
    required this.promoCode,
    required this.discountText,
    required this.validUntil,
    required this.minSpend,
    required this.tag,
    this.bannerColor = 0xFFF36C0A,
    this.icon = Icons.local_pizza_rounded,
  });

  /// Factory parser supporting JSON
  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return OfferModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      promoCode: json['promo_code'] ?? json['promoCode'] ?? '',
      discountText: json['discount_text'] ?? json['discountText'] ?? '',
      validUntil: json['valid_until'] ?? json['validUntil'] ?? '',
      minSpend: json['min_spend'] ?? json['minSpend'] ?? '',
      tag: json['tag']?.toString() ?? 'DEAL',
      bannerColor: json['banner_color'] is int
          ? json['banner_color'] as int
          : (json['bannerColor'] is int ? json['bannerColor'] as int : 0xFFF36C0A),
    );
  }

  /// Serializes to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'promo_code': promoCode,
      'discount_text': discountText,
      'valid_until': validUntil,
      'min_spend': minSpend,
      'tag': tag,
      'banner_color': bannerColor,
    };
  }

  /// Creates a modified copy
  OfferModel copyWith({
    String? id,
    String? title,
    String? description,
    String? promoCode,
    String? discountText,
    String? validUntil,
    String? minSpend,
    String? tag,
    int? bannerColor,
    IconData? icon,
  }) {
    return OfferModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      promoCode: promoCode ?? this.promoCode,
      discountText: discountText ?? this.discountText,
      validUntil: validUntil ?? this.validUntil,
      minSpend: minSpend ?? this.minSpend,
      tag: tag ?? this.tag,
      bannerColor: bannerColor ?? this.bannerColor,
      icon: icon ?? this.icon,
    );
  }

  /// Predefined promotional deals matching checkout promo engine codes
  static List<OfferModel> get defaultOffers => [
        const OfferModel(
          id: 'offer_1',
          title: '20% Neapolitan Special',
          description:
              'Get 20% off all handcrafted wood-fired Neapolitan pizzas on your entire order.',
          promoCode: 'PIZZA20',
          discountText: '20% OFF',
          minSpend: 'Min. spend \$20',
          validUntil: 'Valid until 31 Dec 2026',
          tag: 'HOT DEAL',
          bannerColor: 0xFFF36C0A,
          icon: Icons.local_pizza_rounded,
        ),
        const OfferModel(
          id: 'offer_2',
          title: 'Free Express Delivery',
          description:
              'Enjoy zero delivery fee on all artisan pizzas brought piping hot to your door.',
          promoCode: 'FREESHIP',
          discountText: 'FREE DELIVERY',
          minSpend: 'Min. spend \$15',
          validUntil: 'Valid this weekend',
          tag: 'FREE SHIP',
          bannerColor: 0xFF2E7D32,
          icon: Icons.delivery_dining_rounded,
        ),
        const OfferModel(
          id: 'offer_3',
          title: 'Super Saver \$5 Off',
          description:
              'Instant \$5 flat discount on combo boxes, gourmet sides, and family size pizzas.',
          promoCode: 'SAVE5',
          discountText: '\$5 FLAT OFF',
          minSpend: 'Min. spend \$25',
          validUntil: 'Valid all month',
          tag: 'POPULAR',
          bannerColor: 0xFFE65100,
          icon: Icons.savings_rounded,
        ),
        const OfferModel(
          id: 'offer_4',
          title: 'Neapolitan BOGO 50%',
          description:
              'Buy any large signature Neapolitan pizza and get 50% off your second pizza.',
          promoCode: 'BOGO50',
          discountText: '50% OFF 2ND',
          minSpend: 'Min. 2 Pizzas',
          validUntil: 'Limited time promotion',
          tag: 'COMBO DEAL',
          bannerColor: 0xFF6A1B9A,
          icon: Icons.celebration_rounded,
        ),
      ];
}

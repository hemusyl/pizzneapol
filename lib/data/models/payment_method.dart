import 'package:flutter/material.dart';

/// Supported payment methods in the checkout process.
enum PaymentMethodType {
  cashOnDelivery,
  creditCard,
  digitalWallet,
  onlinePayment,
}

/// Metadata and UI representation for each payment method option.
class PaymentMethodOption {
  final PaymentMethodType type;
  final String title;
  final String subtitle;
  final IconData icon;

  const PaymentMethodOption({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  static const List<PaymentMethodOption> availableMethods = [
    PaymentMethodOption(
      type: PaymentMethodType.cashOnDelivery,
      title: 'Cash on Delivery',
      subtitle: 'Pay in cash when your order arrives',
      icon: Icons.payments_rounded,
    ),
    PaymentMethodOption(
      type: PaymentMethodType.creditCard,
      title: 'Credit / Debit Card',
      subtitle: 'Visa, Mastercard, Amex supported',
      icon: Icons.credit_card_rounded,
    ),
    PaymentMethodOption(
      type: PaymentMethodType.digitalWallet,
      title: 'Apple Pay / Google Pay',
      subtitle: 'Instant secure 1-tap checkout',
      icon: Icons.account_balance_wallet_rounded,
    ),
    PaymentMethodOption(
      type: PaymentMethodType.onlinePayment,
      title: 'Online Banking / Mobile Pay',
      subtitle: 'Fast bank transfer & gateway',
      icon: Icons.account_balance_rounded,
    ),
  ];
}

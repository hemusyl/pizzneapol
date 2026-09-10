import 'package:flutter/material.dart';

/// Renders appetizing food imagery with smooth fallback graphics matching the screenshot.
class FoodImageView extends StatelessWidget {
  final String imagePath;
  final double size;
  final String categoryName;
  final String productName;
  final bool isCircular;

  const FoodImageView({
    super.key,
    required this.imagePath,
    this.size = 100,
    this.categoryName = 'Pizza',
    this.productName = '',
    this.isCircular = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircular ? null : BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isCircular ? size / 2 : 16),
        child: Image.asset(
          imagePath,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackFoodGraphic();
          },
        ),
      ),
    );
  }

  /// High-fidelity custom illustrated food graphics matching the screenshot visual style
  Widget _buildFallbackFoodGraphic() {
    final cat = categoryName.toLowerCase();
    final prod = productName.toLowerCase();

    if (cat.contains('salad')) {
      return _buildSaladGraphic();
    } else if (cat.contains('dessert')) {
      return _buildDessertGraphic();
    } else if (cat.contains('side')) {
      return _buildSidesGraphic();
    } else if (cat.contains('drink')) {
      return _buildDrinkGraphic();
    }

    // Default to Pizza Graphic matching the screenshot
    return _buildPizzaGraphic(prod);
  }

  Widget _buildPizzaGraphic(String prod) {
    // Determine topping colors based on pizza type
    final isPepperoni = prod.contains('pepp') || prod.contains('margarita') || prod.contains('margherita');
    final isChicken = prod.contains('chicken');
    final isVeg = prod.contains('veg');

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Color(0xFFE89344), // Baked crust edge
            Color(0xFFCC7226),
          ],
        ),
      ),
      padding: EdgeInsets.all(size * 0.08),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              Color(0xFFFFD56B), // Melted mozzarella center
              Color(0xFFFFAE34),
              Color(0xFFD63031), // Tomato puree base
            ],
            stops: [0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Pizza slice cut lines
            CustomPaint(
              size: Size(size, size),
              painter: _PizzaCutterPainter(),
            ),
            // Toppings: Pepperonis or veggies or chicken
            if (isPepperoni) ...[
              _topping(0.2, 0.25, const Color(0xFFC0392B), size * 0.22),
              _topping(0.65, 0.2, const Color(0xFFC0392B), size * 0.22),
              _topping(0.42, 0.45, const Color(0xFFB03A2E), size * 0.24),
              _topping(0.22, 0.65, const Color(0xFFC0392B), size * 0.22),
              _topping(0.68, 0.62, const Color(0xFFC0392B), size * 0.22),
              // Basil leaf specks
              _topping(0.48, 0.22, const Color(0xFF27AE60), size * 0.1),
              _topping(0.35, 0.72, const Color(0xFF27AE60), size * 0.1),
            ] else if (isChicken) ...[
              _topping(0.25, 0.3, const Color(0xFFF5B041), size * 0.2),
              _topping(0.6, 0.25, const Color(0xFF2C3E50), size * 0.16), // Olives
              _topping(0.45, 0.5, const Color(0xFFF5B041), size * 0.22),
              _topping(0.25, 0.65, const Color(0xFF2C3E50), size * 0.16),
              _topping(0.65, 0.65, const Color(0xFF884EA0), size * 0.18), // Onion
              _topping(0.5, 0.25, const Color(0xFF27AE60), size * 0.1),
            ] else if (isVeg) ...[
              _topping(0.25, 0.3, const Color(0xFFE74C3C), size * 0.2), // Tomato
              _topping(0.6, 0.25, const Color(0xFF27AE60), size * 0.18), // Capsicum
              _topping(0.45, 0.5, const Color(0xFF7F8C8D), size * 0.2), // Mushroom
              _topping(0.25, 0.65, const Color(0xFF2C3E50), size * 0.16), // Olive
              _topping(0.65, 0.65, const Color(0xFFE74C3C), size * 0.2),
            ] else ...[
              _topping(0.3, 0.3, const Color(0xFFC0392B), size * 0.2),
              _topping(0.6, 0.6, const Color(0xFFC0392B), size * 0.2),
              _topping(0.5, 0.45, const Color(0xFFF39C12), size * 0.22),
            ],
          ],
        ),
      ),
    );
  }

  Widget _topping(double leftFraction, double topFraction, Color color, double toppingSize) {
    return Positioned(
      left: size * leftFraction,
      top: size * topFraction,
      child: Container(
        width: toppingSize,
        height: toppingSize,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaladGraphic() {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFE8F5E9),
      ),
      child: const Center(
        child: Icon(Icons.eco_rounded, color: Color(0xFF2E7D32), size: 40),
      ),
    );
  }

  Widget _buildDessertGraphic() {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFFFF0F5),
      ),
      child: const Center(
        child: Icon(Icons.cake_rounded, color: Color(0xFFE91E63), size: 40),
      ),
    );
  }

  Widget _buildSidesGraphic() {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFFFF8E1),
      ),
      child: const Center(
        child: Icon(Icons.fastfood_rounded, color: Color(0xFFF57F17), size: 40),
      ),
    );
  }

  Widget _buildDrinkGraphic() {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFE1F5FE),
      ),
      child: const Center(
        child: Icon(Icons.local_drink_rounded, color: Color(0xFF0288D1), size: 40),
      ),
    );
  }
}

class _PizzaCutterPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x33B76E1E)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.drawLine(Offset(center.dx - radius, center.dy), Offset(center.dx + radius, center.dy), paint);
    canvas.drawLine(Offset(center.dx, center.dy - radius), Offset(center.dx, center.dy + radius), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

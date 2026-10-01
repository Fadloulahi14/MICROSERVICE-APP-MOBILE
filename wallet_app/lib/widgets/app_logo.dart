import 'package:flutter/material.dart';
import '../config/theme.dart';

class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.orange.withOpacity(0.35),
            blurRadius: 28,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.8, size * 0.8),
          painter: _ShieldLogoPainter(),
        ),
      ),
    );
  }
}

class _ShieldLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..color = AppColors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.12
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    // Shield Hexagon Outer contour
    path.moveTo(w * 0.5, h * 0.05);
    path.lineTo(w * 0.9, h * 0.25);
    path.lineTo(w * 0.9, h * 0.65);
    path.lineTo(w * 0.5, h * 0.95);
    path.lineTo(w * 0.1, h * 0.65);
    path.lineTo(w * 0.1, h * 0.25);
    path.close();

    // Inner wallet/E shape
    path.moveTo(w * 0.35, h * 0.40);
    path.lineTo(w * 0.68, h * 0.40);
    path.moveTo(w * 0.35, h * 0.52);
    path.lineTo(w * 0.60, h * 0.52);
    path.moveTo(w * 0.35, h * 0.64);
    path.lineTo(w * 0.68, h * 0.64);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

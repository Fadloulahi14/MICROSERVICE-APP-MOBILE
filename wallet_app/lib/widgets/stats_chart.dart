import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../models/prestation.dart';

/// Simple bar-chart-style widget showing paid prestation totals grouped by service name.
class StatsChart extends StatelessWidget {
  final List<PrestationModel> prestations;
  const StatsChart({super.key, required this.prestations});

  @override
  Widget build(BuildContext context) {
    // Build service → total spending map
    final Map<String, double> byService = {};
    for (final p in prestations) {
      if (p.services.isEmpty) {
        byService['Autres'] = (byService['Autres'] ?? 0) + p.prix;
      } else {
        for (final s in p.services) {
          byService[s.nom] = (byService[s.nom] ?? 0) + p.prix;
        }
      }
    }

    if (byService.isEmpty) return const SizedBox.shrink();

    final maxVal = byService.values.reduce((a, b) => a > b ? a : b);
    final entries = byService.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        children: entries.map((e) {
          final ratio = maxVal > 0 ? e.value / maxVal : 0.0;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                SizedBox(
                  width: 90,
                  child: Text(
                    e.key,
                    style: GoogleFonts.outfit(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 12,
                      backgroundColor: AppColors.surfaceLight,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.orange,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${e.value.toStringAsFixed(0)} F',
                  style: GoogleFonts.outfit(
                    color: AppColors.orange,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class StatsChartCard extends StatefulWidget {
  const StatsChartCard({super.key});

  @override
  State<StatsChartCard> createState() => _StatsChartCardState();
}

class _StatsChartCardState extends State<StatsChartCard> {
  int _selectedTab = 1; // 0: Weekly, 1: Monthly, 2: Annually

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Cost Charts
          Center(
            child: Text(
              'Dépenses',
              style: GoogleFonts.outfit(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Period Pills (Weekly, Monthly, Annually)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                _buildPeriodTab('Hebdo', 0),
                _buildPeriodTab('Mensuel', 1),
                _buildPeriodTab('Annuel', 2),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Interactive Chart Canvas
          SizedBox(
            height: 150,
            width: double.infinity,
            child: CustomPaint(
              painter: _CostSplineChartPainter(selectedTab: _selectedTab),
            ),
          ),
          const SizedBox(height: 12),

          // Days row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam']
                .map(
                  (day) => Text(
                    day,
                    style: GoogleFonts.outfit(
                      color: day == 'Ven'
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
                      fontSize: 12,
                      fontWeight: day == 'Ven'
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodTab(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.orange : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.orange.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.outfit(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CostSplineChartPainter extends CustomPainter {
  final int selectedTab;

  _CostSplineChartPainter({required this.selectedTab});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Horizontal subtle grid lines
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1;
    for (int i = 1; i <= 3; i++) {
      final y = h * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // Coordinates points
    final points = [
      Offset(0, h * 0.70),
      Offset(w * 0.16, h * 0.85),
      Offset(w * 0.32, h * 0.45),
      Offset(w * 0.48, h * 0.60),
      Offset(w * 0.64, h * 0.75),
      Offset(w * 0.80, h * 0.25), // Marker position (Ven)
      Offset(w, h * 0.55),
    ];

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final cx = (p0.dx + p1.dx) / 2;
      path.cubicTo(cx, p0.dy, cx, p1.dy, p1.dx, p1.dy);
    }

    // Glow effect behind line
    final glowPaint = Paint()
      ..color = AppColors.orange.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawPath(path, glowPaint);

    // Main orange line
    final linePaint = Paint()
      ..color = AppColors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, linePaint);

    // Marker vertical dashed/solid line on Friday (point index 5)
    final markerX = points[5].dx;
    final markerY = points[5].dy;

    final markerLinePaint = Paint()
      ..color = AppColors.orange.withOpacity(0.4)
      ..strokeWidth = 1.2;
    canvas.drawLine(
      Offset(markerX, markerY),
      Offset(markerX, h),
      markerLinePaint,
    );

    // Glowing Dot on active point
    final dotOuterPaint = Paint()
      ..color = AppColors.orange.withOpacity(0.4)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(markerX, markerY), 7, dotOuterPaint);

    final dotInnerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(markerX, markerY), 3.5, dotInnerPaint);

    // Tooltip pill "$ 780" or "78 000 F"
    final pillRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(markerX, markerY - 24),
        width: 68,
        height: 26,
      ),
      const Radius.circular(13),
    );

    final pillBgPaint = Paint()
      ..color = AppColors.orange
      ..style = PaintingStyle.fill;
    canvas.drawRRect(pillRect, pillBgPaint);

    // Text inside tooltip
    final textPainter = TextPainter(
      text: TextSpan(
        text: '78 000 F',
        style: GoogleFonts.outfit(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        markerX - textPainter.width / 2,
        markerY - 24 - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _CostSplineChartPainter oldDelegate) =>
      oldDelegate.selectedTab != selectedTab;
}

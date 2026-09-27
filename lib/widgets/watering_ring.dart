import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../l10n/l10n_extensions.dart';
import '../theme/app_theme.dart';

/// Кольцевой индикатор полива — аналог кольца на карточке растения в
/// Python-версии (там оно рисовалось через Pillow с ручным супersэмплингом
/// для сглаживания краёв). Здесь сглаживание — забота Flutter, не наша:
/// CustomPainter рисует дугу с антиалиасингом "из коробки".
///
/// [daysUntilWatering] — сколько дней осталось до полива (отрицательное или
/// 0 — полив просрочен/нужен сегодня). [frequency] — общая периодичность
/// полива этого растения, нужна, чтобы посчитать, какую долю дуги закрасить
/// (аналог "прогресса" между поливами).
class WateringRing extends StatelessWidget {
  final int daysUntilWatering;
  final int frequency;
  final double size;

  const WateringRing({
    super.key,
    required this.daysUntilWatering,
    required this.frequency,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    final color = context.floraqua.wateringStatusColor(daysUntilWatering);
    final progress = frequency > 0
        ? (1 - (daysUntilWatering.clamp(0, frequency) / frequency))
        : 1.0;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          progress: progress,
          color: color,
          trackColor: context.floraqua.divider,
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(daysUntilWatering <= 0 ? 2 : 4),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                daysUntilWatering <= 0
                    ? context.l10n.waterNow
                    : context.l10n.wateringDaysShort(daysUntilWatering),
                textAlign: TextAlign.center,
                maxLines: 1,
                style: TextStyle(
                  fontSize: daysUntilWatering <= 0 ? 9 : 12,
                  fontWeight: FontWeight.bold,
                  color: context.floraqua.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress; // 0..1
  final Color color;
  final Color trackColor;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - _strokeWidth) / 2;

    final backgroundPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round;

    // Фоновое кольцо (полный круг — "трек", по которому идёт прогресс)
    canvas.drawCircle(center, radius, backgroundPaint);

    // Дуга прогресса — начинаем с "12 часов" (-90°, т.е. -pi/2)
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  static const _strokeWidth = 5.0;

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.trackColor != trackColor;
}

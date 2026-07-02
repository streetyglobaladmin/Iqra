import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/state/app_state.dart';
import '../../../services/qibla_calculator.dart';

/// Real Qibla compass. On Android, uses the device magnetometer via
/// sensors_plus to derive heading; on Web (no magnetometer), falls back
/// to a manual drag-to-rotate compass so the feature is still fully
/// interactive and functional rather than a static mockup.
class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double _heading = 0; // device heading, degrees from north
  bool _sensorAvailable = false;
  StreamSubscription<MagnetometerEvent>? _magSub;
  double? _manualHeading;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      try {
        _magSub = magnetometerEventStream().listen((event) {
          final heading = math.atan2(event.y, event.x) * (180 / math.pi);
          if (mounted) {
            setState(() {
              _heading = (heading + 360) % 360;
              _sensorAvailable = true;
            });
          }
        }, onError: (_) {
          setState(() => _sensorAvailable = false);
        });
      } catch (_) {
        _sensorAvailable = false;
      }
    }
  }

  @override
  void dispose() {
    _magSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final loc = appState.prayerSettings.location;
    final s = context.surface;
    final text = IqraText(s);

    final qiblaBearing = QiblaCalculator.bearingTo(loc.lat, loc.lng);
    final distanceKm = QiblaCalculator.distanceKm(loc.lat, loc.lng);
    final deviceHeading = _sensorAvailable ? _heading : (_manualHeading ?? 0);
    // needle rotation relative to device heading
    final needleAngle = (qiblaBearing - deviceHeading) * math.pi / 180;

    return Scaffold(
      backgroundColor: IqraTokens.appBgDark,
      appBar: AppBar(title: const Text('Qibla')),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text('القبلة',
                style: TextStyle(fontFamily: IqraFonts.arabic, fontSize: 18, color: IqraTokens.goldLt)),
            const SizedBox(height: 24),
            GestureDetector(
              onPanUpdate: _sensorAvailable
                  ? null
                  : (details) {
                      setState(() {
                        final dx = details.delta.dx;
                        _manualHeading = ((_manualHeading ?? 0) - dx) % 360;
                        if (_manualHeading! < 0) _manualHeading = _manualHeading! + 360;
                      });
                    },
              child: SizedBox(
                width: 320,
                height: 320,
                child: CustomPaint(
                  painter: _CompassPainter(
                    deviceHeading: deviceHeading,
                    needleAngle: needleAngle,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${qiblaBearing.toStringAsFixed(0)}° NE',
                      style: const TextStyle(
                          fontFamily: IqraFonts.numeric, fontSize: 20, fontWeight: FontWeight.w600, color: IqraTokens.appTextDark)),
                  Text('${distanceKm.toStringAsFixed(0)} km to Makkah',
                      style: TextStyle(fontSize: 13, color: IqraTokens.appTextDimDark)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: IqraTokens.appCardDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: IqraTokens.appBorderDark),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _sensorAvailable ? IqraTokens.stateSuccess : IqraTokens.stateWarn,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _sensorAvailable
                          ? 'Compass calibrated via device sensor'
                          : 'No magnetometer detected — drag the compass to rotate manually',
                      style: TextStyle(fontSize: 11.5, color: IqraTokens.appTextDimDark),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  final double deviceHeading;
  final double needleAngle;

  _CompassPainter({required this.deviceHeading, required this.needleAngle});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    // outer glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [IqraTokens.lapis.withValues(alpha: 0.25), Colors.transparent],
      ).createShader(Rect.fromCircle(center: center, radius: radius + 20));
    canvas.drawCircle(center, radius + 20, glowPaint);

    // outer ring
    final ringPaint = Paint()
      ..color = IqraTokens.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius, ringPaint);
    canvas.drawCircle(center, radius - 20, ringPaint..color = IqraTokens.gold.withValues(alpha: 0.5));

    // tick marks (72 total, every 9th long)
    for (int i = 0; i < 72; i++) {
      final angle = (i * 5 - deviceHeading) * math.pi / 180;
      final isLong = i % 9 == 0;
      final outerR = radius;
      final innerR = isLong ? radius - 14 : radius - 7;
      final p1 = Offset(center.dx + outerR * math.sin(angle), center.dy - outerR * math.cos(angle));
      final p2 = Offset(center.dx + innerR * math.sin(angle), center.dy - innerR * math.cos(angle));
      canvas.drawLine(
        p1,
        p2,
        Paint()
          ..color = IqraTokens.gold.withValues(alpha: isLong ? 0.8 : 0.4)
          ..strokeWidth = isLong ? 1.5 : 1,
      );
    }

    // cardinal letters
    const cardinals = [('N', 0, true), ('E', 90, false), ('S', 180, false), ('W', 270, false)];
    for (final c in cardinals) {
      final angle = (c.$2 - deviceHeading) * math.pi / 180;
      final pos = Offset(
        center.dx + (radius - 32) * math.sin(angle),
        center.dy - (radius - 32) * math.cos(angle),
      );
      final tp = TextPainter(
        text: TextSpan(
          text: c.$1 as String,
          style: TextStyle(
            color: c.$3 as bool ? IqraTokens.ruby : IqraTokens.appTextDark,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
    }

    // needle
    final needleLength = radius - 24;
    final tip = Offset(
      center.dx + needleLength * math.sin(needleAngle),
      center.dy - needleLength * math.cos(needleAngle),
    );
    final tail = Offset(
      center.dx - (needleLength * 0.3) * math.sin(needleAngle),
      center.dy + (needleLength * 0.3) * math.cos(needleAngle),
    );
    final needlePaint = Paint()
      ..shader = LinearGradient(colors: [IqraTokens.gold, IqraTokens.saffron])
          .createShader(Rect.fromPoints(tail, tip))
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(tail, tip, needlePaint);

    // Kaaba marker at tip
    final kaabaRect = Rect.fromCenter(center: tip, width: 14, height: 10);
    canvas.drawRect(kaabaRect, Paint()..color = IqraTokens.ink);
    canvas.drawRect(kaabaRect, Paint()..color = IqraTokens.gold..style = PaintingStyle.stroke..strokeWidth = 1.2);

    // center label
    final centerLabel = TextPainter(
      text: const TextSpan(
        text: 'القبلة',
        style: TextStyle(fontFamily: IqraFonts.arabic, color: IqraTokens.goldLt, fontSize: 14),
      ),
      textDirection: TextDirection.rtl,
    );
    centerLabel.layout();
    centerLabel.paint(canvas, center - Offset(centerLabel.width / 2, centerLabel.height / 2));
  }

  @override
  bool shouldRepaint(covariant _CompassPainter oldDelegate) =>
      oldDelegate.deviceHeading != deviceHeading || oldDelegate.needleAngle != needleAngle;
}

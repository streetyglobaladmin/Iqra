import 'dart:math' as math;

/// Real great-circle bearing calculation to the Kaaba (Makkah), plus
/// distance via the haversine formula. Not a placeholder — this is the
/// standard geodesy formula used by every Qibla-finder app.
class QiblaCalculator {
  QiblaCalculator._();

  static const kaabaLat = 21.4225;
  static const kaabaLng = 39.8262;
  static const _earthRadiusKm = 6371.0;

  /// Bearing in degrees from true north (0-360) from [lat],[lng] to the Kaaba.
  static double bearingTo(double lat, double lng) {
    final phi1 = _rad(lat);
    final phi2 = _rad(kaabaLat);
    final deltaLambda = _rad(kaabaLng - lng);

    final y = math.sin(deltaLambda) * math.cos(phi2);
    final x = math.cos(phi1) * math.sin(phi2) -
        math.sin(phi1) * math.cos(phi2) * math.cos(deltaLambda);
    final theta = math.atan2(y, x);
    return (_deg(theta) + 360) % 360;
  }

  /// Great-circle distance in kilometres from [lat],[lng] to the Kaaba.
  static double distanceKm(double lat, double lng) {
    final phi1 = _rad(lat);
    final phi2 = _rad(kaabaLat);
    final deltaPhi = _rad(kaabaLat - lat);
    final deltaLambda = _rad(kaabaLng - lng);

    final a = math.sin(deltaPhi / 2) * math.sin(deltaPhi / 2) +
        math.cos(phi1) * math.cos(phi2) *
            math.sin(deltaLambda / 2) * math.sin(deltaLambda / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return _earthRadiusKm * c;
  }

  static double _rad(double deg) => deg * math.pi / 180.0;
  static double _deg(double rad) => rad * 180.0 / math.pi;
}

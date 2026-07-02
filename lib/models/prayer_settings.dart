enum Madhab { hanafi, shafii, maliki, hanbali }

enum CalcMethod { isna, mwl, egyptian, ummAlQura, karachi, custom }

extension MadhabX on Madhab {
  String get label {
    switch (this) {
      case Madhab.hanafi:
        return 'Ḥanafī';
      case Madhab.shafii:
        return 'Shāfiʿī';
      case Madhab.maliki:
        return 'Mālikī';
      case Madhab.hanbali:
        return 'Ḥanbalī';
    }
  }

  /// Asr shadow-length multiplier: Hanafi uses 2x shadow, others use 1x.
  int get asrShadowFactor => this == Madhab.hanafi ? 2 : 1;
}

extension CalcMethodX on CalcMethod {
  String get label {
    switch (this) {
      case CalcMethod.isna:
        return 'ISNA (North America)';
      case CalcMethod.mwl:
        return 'Muslim World League';
      case CalcMethod.egyptian:
        return 'Egyptian General Authority';
      case CalcMethod.ummAlQura:
        return 'Umm al-Qura (Makkah)';
      case CalcMethod.karachi:
        return 'University of Islamic Sciences, Karachi';
      case CalcMethod.custom:
        return 'Custom angles';
    }
  }

  /// (fajrAngle, ishaAngle) in degrees below horizon.
  (double, double) get angles {
    switch (this) {
      case CalcMethod.isna:
        return (15.0, 15.0);
      case CalcMethod.mwl:
        return (18.0, 17.0);
      case CalcMethod.egyptian:
        return (19.5, 17.5);
      case CalcMethod.ummAlQura:
        return (18.5, 19.0); // Isha fixed 90 min after Maghrib in reality
      case CalcMethod.karachi:
        return (18.0, 18.0);
      case CalcMethod.custom:
        return (15.0, 15.0);
    }
  }
}

class Location {
  final double lat;
  final double lng;
  final String city;
  final String countryCode;
  final double tzOffsetHours;

  Location({
    required this.lat,
    required this.lng,
    required this.city,
    required this.countryCode,
    required this.tzOffsetHours,
  });

  Map<String, dynamic> toMap() => {
        'lat': lat,
        'lng': lng,
        'city': city,
        'countryCode': countryCode,
        'tzOffsetHours': tzOffsetHours,
      };

  factory Location.fromMap(Map map) => Location(
        lat: (map['lat'] as num).toDouble(),
        lng: (map['lng'] as num).toDouble(),
        city: map['city'] as String,
        countryCode: map['countryCode'] as String,
        tzOffsetHours: (map['tzOffsetHours'] as num).toDouble(),
      );

  static Location defaultLocation() => Location(
        lat: 41.0082,
        lng: 28.9784,
        city: 'Istanbul',
        countryCode: 'TR',
        tzOffsetHours: 3,
      );
}

class PrayerSettings {
  final Location location;
  final Madhab madhab;
  final CalcMethod calcMethod;
  final bool useArabicNumerals;
  final bool notificationsEnabled;
  final Map<String, bool> perPrayerNotification;
  final String adhanSound;

  PrayerSettings({
    required this.location,
    this.madhab = Madhab.hanafi,
    this.calcMethod = CalcMethod.isna,
    this.useArabicNumerals = false,
    this.notificationsEnabled = true,
    this.perPrayerNotification = const {
      'fajr': true,
      'dhuhr': true,
      'asr': true,
      'maghrib': true,
      'isha': true,
    },
    this.adhanSound = 'Makkah (Default)',
  });

  PrayerSettings copyWith({
    Location? location,
    Madhab? madhab,
    CalcMethod? calcMethod,
    bool? useArabicNumerals,
    bool? notificationsEnabled,
    Map<String, bool>? perPrayerNotification,
    String? adhanSound,
  }) {
    return PrayerSettings(
      location: location ?? this.location,
      madhab: madhab ?? this.madhab,
      calcMethod: calcMethod ?? this.calcMethod,
      useArabicNumerals: useArabicNumerals ?? this.useArabicNumerals,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      perPrayerNotification:
          perPrayerNotification ?? this.perPrayerNotification,
      adhanSound: adhanSound ?? this.adhanSound,
    );
  }

  Map<String, dynamic> toMap() => {
        'location': location.toMap(),
        'madhab': madhab.name,
        'calcMethod': calcMethod.name,
        'useArabicNumerals': useArabicNumerals,
        'notificationsEnabled': notificationsEnabled,
        'perPrayerNotification': perPrayerNotification,
        'adhanSound': adhanSound,
      };

  factory PrayerSettings.fromMap(Map map) => PrayerSettings(
        location: Location.fromMap(map['location'] as Map),
        madhab: Madhab.values.firstWhere(
          (m) => m.name == map['madhab'],
          orElse: () => Madhab.hanafi,
        ),
        calcMethod: CalcMethod.values.firstWhere(
          (m) => m.name == map['calcMethod'],
          orElse: () => CalcMethod.isna,
        ),
        useArabicNumerals: map['useArabicNumerals'] as bool? ?? false,
        notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
        perPrayerNotification: Map<String, bool>.from(
            map['perPrayerNotification'] as Map? ??
                {
                  'fajr': true,
                  'dhuhr': true,
                  'asr': true,
                  'maghrib': true,
                  'isha': true
                }),
        adhanSound: map['adhanSound'] as String? ?? 'Makkah (Default)',
      );

  static PrayerSettings initial() =>
      PrayerSettings(location: Location.defaultLocation());
}

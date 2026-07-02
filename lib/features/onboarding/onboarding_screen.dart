import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/iqra_logo.dart';
import '../../core/state/app_state.dart';
import '../../models/prayer_settings.dart';
import '../hub/hub_shell.dart';

/// Real first-run flow: welcome -> location -> madhab -> calculation
/// method -> begin. Persists a working [PrayerSettings] object that the
/// rest of the app (prayer times, Qibla) actually uses.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;
  Location _location = Location.defaultLocation();
  Madhab _madhab = Madhab.hanafi;
  CalcMethod _calcMethod = CalcMethod.isna;

  static const _cities = [
    ('Istanbul, Turkey', 41.0082, 28.9784, 'TR', 3.0),
    ('Karachi, Pakistan', 24.8607, 67.0011, 'PK', 5.0),
    ('Delhi, India', 28.6139, 77.2090, 'IN', 5.5),
    ('Dhaka, Bangladesh', 23.8103, 90.4125, 'BD', 6.0),
    ('London, UK', 51.5072, -0.1276, 'GB', 0.0),
    ('New York, USA', 40.7128, -74.0060, 'US', -5.0),
    ('Jakarta, Indonesia', -6.2088, 106.8456, 'ID', 7.0),
    ('Cairo, Egypt', 30.0444, 31.2357, 'EG', 2.0),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IqraTokens.emeraldDeep,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            children: [
              _buildProgress(),
              const SizedBox(height: 24),
              Expanded(child: _buildStep()),
              _buildNav(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgress() {
    return Row(
      children: List.generate(4, (i) {
        final active = i <= _step;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
            height: 3,
            decoration: BoxDecoration(
              color: active ? IqraTokens.gold : IqraTokens.gold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _welcomeStep();
      case 1:
        return _locationStep();
      case 2:
        return _madhabStep();
      case 3:
        return _calcMethodStep();
      default:
        return const SizedBox();
    }
  }

  Widget _welcomeStep() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          const IqraLogoMark(size: 96),
          const SizedBox(height: 24),
          Text(
            'Assalāmu ʿAlaykum',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: IqraFonts.display,
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: IqraTokens.appTextDark,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'IQRA is your daily companion for prayer times, Qibla, Qur\'ān, remembrance, and guided learning.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: IqraFonts.sans,
              fontSize: 14,
              color: IqraTokens.appTextDimDark,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'KNOWLEDGE TODAY · GUIDANCE FOREVER',
            style: TextStyle(
              fontFamily: IqraFonts.sans,
              fontSize: 9.5,
              letterSpacing: 3,
              fontWeight: FontWeight.w700,
              color: IqraTokens.gold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _locationStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepTitle('Where are you?', 'We use your location to calculate accurate prayer times and Qibla direction.'),
          const SizedBox(height: 20),
          ..._cities.map((c) {
            final selected = _location.city == c.$1.split(',').first;
            return _choiceCard(
              title: c.$1,
              selected: selected,
              onTap: () => setState(() => _location = Location(
                    lat: c.$2,
                    lng: c.$3,
                    city: c.$1.split(',').first,
                    countryCode: c.$4,
                    tzOffsetHours: c.$5,
                  )),
            );
          }),
        ],
      ),
    );
  }

  Widget _madhabStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepTitle('Which madhab do you follow?', 'This affects the Asr prayer time calculation (shadow length method).'),
          const SizedBox(height: 20),
          ...Madhab.values.map((m) => _choiceCard(
                title: m.label,
                selected: _madhab == m,
                onTap: () => setState(() => _madhab = m),
              )),
        ],
      ),
    );
  }

  Widget _calcMethodStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepTitle('Calculation method', 'Choose the convention used by scholars in your region.'),
          const SizedBox(height: 20),
          ...CalcMethod.values.map((m) => _choiceCard(
                title: m.label,
                selected: _calcMethod == m,
                onTap: () => setState(() => _calcMethod = m),
              )),
        ],
      ),
    );
  }

  Widget _stepTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: IqraFonts.display,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: IqraTokens.appTextDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            fontFamily: IqraFonts.sans,
            fontSize: 13,
            color: IqraTokens.appTextDimDark,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _choiceCard({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: selected
                ? IqraTokens.gold.withValues(alpha: 0.12)
                : IqraTokens.appCardDark,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? IqraTokens.gold : IqraTokens.appBorderDark,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: IqraFonts.sans,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: IqraTokens.appTextDark,
                  ),
                ),
              ),
              if (selected)
                const Icon(Icons.check_circle, color: IqraTokens.gold, size: 20)
              else
                Icon(Icons.circle_outlined,
                    color: IqraTokens.appTextMutedDark, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNav() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          if (_step > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _step--),
                style: OutlinedButton.styleFrom(
                  foregroundColor: IqraTokens.appTextDark,
                  side: BorderSide(color: IqraTokens.appBorderDark),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Back'),
              ),
            ),
          if (_step > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _step == 3 ? _finish : () => setState(() => _step++),
              child: Text(_step == 3 ? 'Begin' : 'Continue'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _finish() async {
    final appState = context.read<AppState>();
    final settings = PrayerSettings(
      location: _location,
      madhab: _madhab,
      calcMethod: _calcMethod,
    );
    await appState.completeOnboarding(settings);
    if (mounted) {
      // Guest-first: finishing onboarding lands on the Hub directly,
      // never a forced login screen.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HubShell()),
      );
    }
  }
}

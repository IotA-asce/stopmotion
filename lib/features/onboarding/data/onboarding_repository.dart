import 'package:shared_preferences/shared_preferences.dart';

abstract interface class OnboardingRepository {
  Future<bool> isComplete();
  Future<void> markComplete();
}

class SharedPreferencesOnboardingRepository implements OnboardingRepository {
  SharedPreferencesOnboardingRepository({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const String _completedKey = 'onboarding.completed';
  final SharedPreferencesAsync _preferences;

  @override
  Future<bool> isComplete() async =>
      await _preferences.getBool(_completedKey) ?? false;

  @override
  Future<void> markComplete() => _preferences.setBool(_completedKey, true);
}

class MemoryOnboardingRepository implements OnboardingRepository {
  MemoryOnboardingRepository({this.complete = true});

  bool complete;

  @override
  Future<bool> isComplete() async => complete;

  @override
  Future<void> markComplete() async {
    complete = true;
  }
}

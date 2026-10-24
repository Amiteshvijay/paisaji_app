import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeokash/features/onboarding/data/onboarding_local_data_source.dart';

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return OnboardingRepository(OnboardingLocalDataSource());
});

class OnboardingRepository {
  final OnboardingLocalDataSource _dataSource;

  OnboardingRepository(this._dataSource);

  Future<bool> isOnboardingCompleted() async {
    return await _dataSource.isOnboardingCompleted();
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    await _dataSource.setOnboardingCompleted(completed);
  }
}

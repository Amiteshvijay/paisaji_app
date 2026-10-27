import 'package:zeokash/core/services/notification_service.dart';
import 'package:zeokash/core/services/fingerprint_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeokash/core/storage/secure_storage.dart';
import 'package:zeokash/features/auth/data/auth_repository.dart';

enum AuthLockState {
  initializing,
  unauthenticated,
  authenticatedLocked,
  authenticatedUnlocked,
  mpinEnrollmentRequired,
  mpinRecoveryRequired,
  deviceRecoveryRequired,
  sessionRecoveryRequired,
  sessionRevoked,
}

enum AuthStatus {
  initial,
  unauthenticated,
  authenticated,
  deviceRecoveryRequired,
  needsEmailVerification,
  needsProfileSetup,
}

class AuthState {
  final AuthLockState lockState;
  final AuthStatus status;
  final String? mobileNumber;
  final String? email;
  final String? fullName;
  final String? devOtp;
  final String? resetToken;
  final bool isMpinSet;
  final bool isLoading;
  final String? errorMessage;

  // Device recovery state
  final bool recoveryRequired;
  final bool isSameHardware;
  final String? recoveryId;
  final String? recoveryToken;
  final Map<String, dynamic>? recoveryChallenge;
  final bool isFingerprintEnabled;
  final bool isFingerprintAvailable;

  AuthState({
    this.lockState = AuthLockState.initializing,
    this.status = AuthStatus.initial,
    this.mobileNumber,
    this.email,
    this.fullName,
    this.devOtp,
    this.resetToken,
    this.isMpinSet = false,
    this.isLoading = false,
    this.errorMessage,
    this.recoveryRequired = false,
    this.isSameHardware = false,
    this.recoveryId,
    this.recoveryToken,
    this.recoveryChallenge,
    this.isFingerprintEnabled = false,
    this.isFingerprintAvailable = false,
  });

  bool get isLocked => lockState == AuthLockState.authenticatedLocked;
  bool get isAuthenticated =>
      lockState == AuthLockState.authenticatedUnlocked ||
      lockState == AuthLockState.authenticatedLocked ||
      lockState == AuthLockState.mpinEnrollmentRequired;

  AuthState copyWith({
    AuthLockState? lockState,
    AuthStatus? status,
    String? mobileNumber,
    String? email,
    String? fullName,
    String? devOtp,
    String? resetToken,
    bool? isMpinSet,
    bool? isLoading,
    String? errorMessage,
    bool? recoveryRequired,
    bool? isSameHardware,
    String? recoveryId,
    String? recoveryToken,
    Map<String, dynamic>? recoveryChallenge,
    bool? isFingerprintEnabled,
    bool? isFingerprintAvailable,
    bool clearRecovery = false,
    bool clearError = false,
  }) {
    return AuthState(
      lockState: lockState ?? this.lockState,
      status: status ?? this.status,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      devOtp: devOtp ?? this.devOtp,
      resetToken: resetToken ?? this.resetToken,
      isMpinSet: isMpinSet ?? this.isMpinSet,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      recoveryRequired: clearRecovery ? false : (recoveryRequired ?? this.recoveryRequired),
      isSameHardware: clearRecovery ? false : (isSameHardware ?? this.isSameHardware),
      recoveryId: clearRecovery ? null : (recoveryId ?? this.recoveryId),
      recoveryToken: clearRecovery ? null : (recoveryToken ?? this.recoveryToken),
      recoveryChallenge: clearRecovery ? null : (recoveryChallenge ?? this.recoveryChallenge),
      isFingerprintEnabled: isFingerprintEnabled ?? this.isFingerprintEnabled,
      isFingerprintAvailable: isFingerprintAvailable ?? this.isFingerprintAvailable,
    );
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(() {
  return AuthController();
});

class AuthController extends Notifier<AuthState> {
  late final AuthRepository _authRepo;
  late final SecureStorageService _storage;
  late final FingerprintService _fingerprintService;

  @override
  AuthState build() {
    _authRepo = ref.read(authRepositoryProvider);
    _storage = ref.read(secureStorageProvider);
    _fingerprintService = ref.read(fingerprintServiceProvider);
    return AuthState(lockState: AuthLockState.initializing);
  }

  void setAuthenticated() {
    state = state.copyWith(
      lockState: AuthLockState.authenticatedUnlocked,
      status: AuthStatus.authenticated,
      isMpinSet: true,
      isLoading: false,
    );
  }

  void setLocked() {
    state = state.copyWith(lockState: AuthLockState.authenticatedLocked);
  }

  /// Bootstrap authentication and resolve startup app-lock state.
  Future<AuthLockState> bootstrap() async {
    state = state.copyWith(lockState: AuthLockState.initializing, isLoading: true, clearError: true);
    try {
      final refreshToken = await _storage.getRefreshToken();
      final lastMobile = await _storage.getLastMobileNumber();

      if (refreshToken == null || refreshToken.isEmpty) {
        state = state.copyWith(
          lockState: AuthLockState.unauthenticated,
          status: AuthStatus.unauthenticated,
          mobileNumber: lastMobile,
          isLoading: false,
        );
        return AuthLockState.unauthenticated;
      }

      // Check session with backend
      final session = await _authRepo.restoreSession();

      if (!session.isValid) {
        // Token revoked or definitively expired
        await _storage.deleteTokens();
        state = state.copyWith(
          lockState: AuthLockState.sessionRevoked,
          status: AuthStatus.unauthenticated,
          mobileNumber: lastMobile,
          isLoading: false,
        );
        return AuthLockState.sessionRevoked;
      }

      if (session.deviceRecoveryRequired) {
        state = state.copyWith(
          lockState: AuthLockState.deviceRecoveryRequired,
          status: AuthStatus.deviceRecoveryRequired,
          mobileNumber: lastMobile,
          isLoading: false,
        );
        return AuthLockState.deviceRecoveryRequired;
      }

      if (session.sessionRecoveryRequired) {
        state = state.copyWith(
          lockState: AuthLockState.sessionRecoveryRequired,
          status: AuthStatus.unauthenticated,
          mobileNumber: lastMobile,
          isLoading: false,
        );
        return AuthLockState.sessionRecoveryRequired;
      }

      if (!session.isMpinSet) {
        state = state.copyWith(
          lockState: AuthLockState.mpinEnrollmentRequired,
          status: AuthStatus.authenticated,
          isMpinSet: false,
          mobileNumber: lastMobile,
          isLoading: false,
        );
        return AuthLockState.mpinEnrollmentRequired;
      }

      // Check fingerprint hardware and settings
      final isFpAvail = await _fingerprintService.isFingerprintAvailable();
      final isFpEnabled = await _storage.getFingerprintEnabled();
      // Valid session + enrolled MPIN -> COLD START MUST BE LOCKED!
      state = state.copyWith(
        lockState: AuthLockState.authenticatedLocked,
        status: AuthStatus.authenticated,
        isMpinSet: true,
        isFingerprintAvailable: isFpAvail,
        isFingerprintEnabled: isFpEnabled && isFpAvail,
        mobileNumber: lastMobile,
        isLoading: false,
      );
      return AuthLockState.authenticatedLocked;
    } catch (e) {
      final refreshToken = await _storage.getRefreshToken();
      final lastMobile = await _storage.getLastMobileNumber();
      final isMpinSet = await _storage.getIsMpinSet() ?? true;

      if (refreshToken != null && refreshToken.isNotEmpty) {
        final nextState = isMpinSet
            ? AuthLockState.authenticatedLocked
            : AuthLockState.mpinEnrollmentRequired;
        state = state.copyWith(
          lockState: nextState,
          status: AuthStatus.authenticated,
          isMpinSet: isMpinSet,
          mobileNumber: lastMobile,
          isLoading: false,
        );
        return nextState;
      }

      state = state.copyWith(
        lockState: AuthLockState.unauthenticated,
        status: AuthStatus.unauthenticated,
        mobileNumber: lastMobile,
        isLoading: false,
      );
      return AuthLockState.unauthenticated;
    }
  }

  /// Unlock app using verified MPIN

  /// Unlock app using biometric fingerprint prompt + server challenge verification
  Future<bool> unlockWithFingerprint([String? mobileNumber]) async {
    final mobile = mobileNumber ?? state.mobileNumber ?? await _storage.getLastMobileNumber();
    if (mobile == null || mobile.isEmpty) {
      state = state.copyWith(errorMessage: 'Account session expired. Please enter MPIN.');
      return false;
    }

    final isAvail = await _fingerprintService.isFingerprintAvailable();
    if (!isAvail) {
      state = state.copyWith(isFingerprintAvailable: false, errorMessage: 'Fingerprint hardware or enrolled prints unavailable.');
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final didAuth = await _fingerprintService.authenticate(
        reason: 'Scan your fingerprint to unlock Paisaजी',
      );
      if (!didAuth) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Fingerprint not recognized. Use MPIN instead.',
        );
        return false;
      }

      // Cryptographic verification & session issuance with backend
      await _authRepo.verifyBiometricUnlock(mobile);
      await _storage.saveLastActiveTimestamp(DateTime.now().millisecondsSinceEpoch);

      state = state.copyWith(
        lockState: AuthLockState.authenticatedUnlocked,
        status: AuthStatus.authenticated,
        isMpinSet: true,
        isLoading: false,
        clearError: true,
      );
      return true;
    } catch (e) {
      final errStr = e.toString();
      state = state.copyWith(
        isLoading: false,
        errorMessage: errStr.contains('DEVICE_MISMATCH')
            ? 'Registered device mismatch. Recovery required.'
            : 'Fingerprint verification failed. Use MPIN instead.',
      );
      return false;
    }
  }

  /// Enable fingerprint unlock by verifying MPIN, capturing fingerprint, and registering device key
  Future<void> enableFingerprint(String mpin) async {
    final isAvail = await _fingerprintService.isFingerprintAvailable();
    if (!isAvail) {
      throw Exception('Fingerprint authentication is not supported or enrolled on this device');
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      // Prompt native fingerprint sensor
      final didAuth = await _fingerprintService.authenticate(
        reason: 'Scan your fingerprint to enable Fingerprint Unlock',
      );
      if (!didAuth) {
        throw Exception('Fingerprint scan cancelled or unverified');
      }

      await _authRepo.enableBiometric(mpin);
      state = state.copyWith(
        isFingerprintEnabled: true,
        isFingerprintAvailable: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  /// Disable fingerprint unlock
  Future<void> disableFingerprint(String mpin) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _authRepo.disableBiometric(mpin);
      state = state.copyWith(
        isFingerprintEnabled: false,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> unlockWithMpin(String mpin) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _authRepo.verifyMpin(mpin);
      await _storage.saveLastActiveTimestamp(DateTime.now().millisecondsSinceEpoch);
      PushNotificationService().registerDeviceToken();
      state = state.copyWith(
        lockState: AuthLockState.authenticatedUnlocked,
        status: AuthStatus.authenticated,
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// Record timestamp when app transitions to background
  void onAppBackgrounded() {
    final now = DateTime.now().millisecondsSinceEpoch;
    _storage.saveLastActiveTimestamp(now);
  }

  /// Evaluate inactivity timeout when app resumes from background
  Future<void> onAppResumed({Duration gracePeriod = const Duration(seconds: 30)}) async {
    if (state.lockState == AuthLockState.authenticatedUnlocked) {
      final lastActive = await _storage.getLastActiveTimestamp();
      if (lastActive != null) {
        final elapsed = DateTime.now().millisecondsSinceEpoch - lastActive;
        if (elapsed > gracePeriod.inMilliseconds) {
          state = state.copyWith(lockState: AuthLockState.authenticatedLocked);
        }
      }
    }
  }

  Future<void> sendOtp(String mobileNumber) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final data = await _authRepo.sendOtp(mobileNumber);
      state = state.copyWith(
        isLoading: false,
        mobileNumber: mobileNumber,
        devOtp: data['dev_otp'] as String?,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<Map<String, dynamic>> checkDevice(String mobileNumber) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final res = await _authRepo.checkDevice(mobileNumber);
      final registered = res['registered'] == true;
      final isSameHardware = res['is_same_hardware'] == true;

      state = state.copyWith(
        isLoading: false,
        mobileNumber: mobileNumber,
        recoveryRequired: !registered,
        isSameHardware: isSameHardware,
      );
      return res;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String mobileNumber, String otp) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final data = await _authRepo.verifyOtp(mobileNumber, otp);
      // When verifying with OTP on a fresh login / install, MPIN setup is mandatory
      state = state.copyWith(
        lockState: AuthLockState.mpinEnrollmentRequired,
        status: AuthStatus.authenticated,
        isMpinSet: false,
        mobileNumber: mobileNumber,
        isLoading: false,
        clearRecovery: true,
      );
      return data;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Invalid OTP or verification error.');
      rethrow;
    }
  }

  // --- Device Recovery Actions ---

  Future<Map<String, dynamic>> startDeviceRecovery(String mobileNumber) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final res = await _authRepo.startRecovery(mobileNumber);
      state = state.copyWith(
        isLoading: false,
        mobileNumber: mobileNumber,
        recoveryId: res['recovery_id'] as String?,
        devOtp: res['dev_otp'] as String?,
        recoveryChallenge: res['challenge'] as Map<String, dynamic>?,
        isSameHardware: res['is_same_hardware'] == true,
      );
      return res;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<String> verifyRecoveryOtp(String recoveryId, String otp) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final token = await _authRepo.verifyRecoveryOtp(recoveryId, otp);
      state = state.copyWith(
        isLoading: false,
        recoveryToken: token,
      );
      return token;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<Map<String, dynamic>> completeDeviceRecovery() async {
    final token = state.recoveryToken;
    if (token == null) {
      throw Exception('Recovery token missing');
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final data = await _authRepo.completeRecovery(
        recoveryToken: token,
        challenge: state.recoveryChallenge,
      );
      final isMpinSet = data['is_mpin_set'] == true;
      final nextState = isMpinSet
          ? AuthLockState.authenticatedUnlocked
          : AuthLockState.mpinEnrollmentRequired;
      PushNotificationService().registerDeviceToken();
      state = state.copyWith(
        lockState: nextState,
        status: AuthStatus.authenticated,
        isMpinSet: isMpinSet,
        isLoading: false,
        clearRecovery: true,
      );
      return data;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<Map<String, dynamic>> loginWithMpin(String mobileNumber, String mpin) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final data = await _authRepo.loginWithMpin(mobileNumber, mpin);
      await _storage.saveLastActiveTimestamp(DateTime.now().millisecondsSinceEpoch);
      PushNotificationService().registerDeviceToken();
      state = state.copyWith(
        lockState: AuthLockState.authenticatedUnlocked,
        status: AuthStatus.authenticated,
        isMpinSet: true,
        mobileNumber: mobileNumber,
        isLoading: false,
      );
      return data;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<Map<String, dynamic>> forgotDevice(String mobileNumber, String email) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final res = await _authRepo.forgotDevice(mobileNumber, email);
      state = state.copyWith(isLoading: false);
      return res;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> verifyForgotDevice(String mobileNumber, String mobileOtp, String emailOtp) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _authRepo.verifyForgotDevice(mobileNumber, mobileOtp, emailOtp);
      state = state.copyWith(
        lockState: AuthLockState.authenticatedUnlocked,
        status: AuthStatus.authenticated,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> createMpin(String mpin, String confirmMpin) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _authRepo.createMpin(mpin, confirmMpin);
      await _storage.saveLastActiveTimestamp(DateTime.now().millisecondsSinceEpoch);
      PushNotificationService().registerDeviceToken();
      state = state.copyWith(
        lockState: AuthLockState.authenticatedUnlocked,
        status: AuthStatus.authenticated,
        isMpinSet: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> changeMpin(String currentMpin, String newMpin, String confirmMpin) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _authRepo.changeMpin(currentMpin, newMpin, confirmMpin);
      state = state.copyWith(isLoading: false, isMpinSet: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> sendMpinResetOtp(String mobileNumber) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final devOtp = await _authRepo.sendMpinResetOtp(mobileNumber);
      state = state.copyWith(
        isLoading: false,
        mobileNumber: mobileNumber,
        devOtp: devOtp,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<String> verifyMpinResetOtp(String mobileNumber, String otp) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final resetToken = await _authRepo.verifyMpinResetOtp(mobileNumber, otp);
      state = state.copyWith(isLoading: false, resetToken: resetToken);
      return resetToken;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Invalid OTP.');
      rethrow;
    }
  }

  Future<void> confirmMpinReset(String resetToken, String newMpin, String confirmMpin) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _authRepo.confirmMpinReset(resetToken, newMpin, confirmMpin);
      await _storage.saveLastActiveTimestamp(DateTime.now().millisecondsSinceEpoch);
      PushNotificationService().registerDeviceToken();
      state = state.copyWith(
        lockState: AuthLockState.authenticatedUnlocked,
        status: AuthStatus.authenticated,
        isLoading: false,
        isMpinSet: true,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> signup(String fullName, String mobileNumber, String email) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _authRepo.signup(fullName, mobileNumber, email);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> sendEmailVerification(String? email) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _authRepo.sendEmailVerification(email);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> verifyEmail(String token) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _authRepo.verifyEmail(token);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await _authRepo.logout();
    } catch (_) {}
    final lastMobile = await _storage.getLastMobileNumber();
    state = AuthState(
      lockState: AuthLockState.unauthenticated,
      status: AuthStatus.unauthenticated,
      mobileNumber: lastMobile,
    );
  }
}


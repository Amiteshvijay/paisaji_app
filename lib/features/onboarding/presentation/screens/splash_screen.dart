import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zeokash/core/storage/secure_storage.dart';
import 'package:zeokash/core/theme/paisaji_brand.dart';
import 'package:zeokash/features/auth/providers/auth_provider.dart';
import 'package:zeokash/features/onboarding/domain/onboarding_repository.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
    _bootstrapApp();
  }

  Future<void> _bootstrapApp() async {
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    try {
      final lockState = await ref.read(authControllerProvider.notifier).bootstrap();
      if (!mounted) return;

      switch (lockState) {
        case AuthLockState.authenticatedLocked:
          context.go('/auth/mpin-unlock');
          break;
        case AuthLockState.authenticatedUnlocked:
          context.go('/home');
          break;
        case AuthLockState.mpinEnrollmentRequired:
          context.go('/auth/setup-mpin');
          break;
        case AuthLockState.deviceRecoveryRequired:
          final mobile = ref.read(authControllerProvider).mobileNumber ?? '';
          context.go('/auth/device-recovery', extra: mobile);
          break;
        case AuthLockState.mpinRecoveryRequired:
          final mobile = ref.read(authControllerProvider).mobileNumber ?? '';
          context.go('/auth/mpin-reset-otp', extra: mobile);
          break;
        case AuthLockState.sessionRecoveryRequired:
        case AuthLockState.sessionRevoked:
        case AuthLockState.unauthenticated:
        case AuthLockState.initializing:
          await _routeUnauthenticated();
          break;
      }
    } catch (_) {
      if (mounted) {
        await _routeUnauthenticated();
      }
    }
  }

  Future<void> _routeUnauthenticated() async {
    final storage = ref.read(secureStorageProvider);
    final lastMobile = await storage.getLastMobileNumber();
    final isMpinSet = await storage.getIsMpinSet();

    if (!mounted) return;

    if (lastMobile != null && lastMobile.isNotEmpty && isMpinSet == true) {
      context.go('/auth/mpin-login', extra: lastMobile);
      return;
    }

    final onboardingRepo = ref.read(onboardingRepositoryProvider);
    final isCompleted = await onboardingRepo.isOnboardingCompleted();

    if (!mounted) return;

    if (isCompleted) {
      context.go('/auth/login');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [PaisaJiColors.navy, Color(0xFF1E3A8A), PaisaJiColors.primary],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/branding/paisaji_monogram.png',
                        width: 72,
                        height: 72,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Image.asset(
                      'assets/branding/paisaji_wordmark.png',
                      height: 42,
                      color: Colors.white,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Simple. Secure. Smart.',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF93C5FD),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

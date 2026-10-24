import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zeokash/core/theme/paisaji_brand.dart';
import 'package:zeokash/features/onboarding/domain/onboarding_repository.dart';
import 'package:zeokash/shared/widgets/buttons/primary_button.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Everything you pay.\nIn one place.',
      'subtitle': 'Recharge, bills, FASTag, cards, and brand vouchers seamlessly managed.',
      'icon': Icons.payments_rounded,
      'accent': PaisaJiColors.primary,
    },
    {
      'title': 'Secure by design.',
      'subtitle': 'Your payments, sessions, and account data stay fully protected with bank-grade encryption.',
      'icon': Icons.security_rounded,
      'accent': PaisaJiColors.success,
    },
    {
      'title': 'Smarter with PaisaAI.',
      'subtitle': 'Ask, understand, and manage your everyday financial transactions instantly.',
      'icon': Icons.auto_awesome_rounded,
      'accent': PaisaJiColors.warning,
    },
  ];

  Future<void> _finishOnboarding() async {
    final repo = ref.read(onboardingRepositoryProvider);
    await repo.setOnboardingCompleted(true);
    if (mounted) {
      context.go('/auth/signup');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PaisaJiColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top Bar: Logo & Skip
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset(
                            'assets/images/paisaji_wordmark.png',
                            height: 24,
                            fit: BoxFit.contain,
                          ),
                          if (_currentPage < _pages.length - 1)
                            TextButton(
                              onPressed: _finishOnboarding,
                              child: Text(
                                'Skip',
                                style: GoogleFonts.inter(
                                  color: PaisaJiColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // PageView wrapped in SizedBox
                      SizedBox(
                        height: constraints.maxHeight * 0.55,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: _pages.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            final page = _pages[index];
                            final accentColor = page['accent'] as Color;
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: accentColor.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: accentColor.withValues(alpha: 0.15),
                                        blurRadius: 20,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Icon(
                                      page['icon'] as IconData,
                                      size: 52,
                                      color: accentColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 36),
                                Text(
                                  page['title'] as String,
                                  style: GoogleFonts.outfit(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: PaisaJiColors.textPrimary,
                                    letterSpacing: -0.5,
                                    height: 1.2,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 14),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Text(
                                    page['subtitle'] as String,
                                    style: GoogleFonts.inter(
                                      color: PaisaJiColors.textSecondary,
                                      fontSize: 14,
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                      // Bottom Controls: Dots + Button
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _pages.length,
                              (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: _currentPage == index ? 28 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _currentPage == index ? PaisaJiColors.primary : PaisaJiColors.border,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          PrimaryButton(
                            text: _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                            onPressed: () {
                              if (_currentPage < _pages.length - 1) {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              } else {
                                _finishOnboarding();
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

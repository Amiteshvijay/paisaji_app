import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zeokash/core/storage/secure_storage.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/features/profile/presentation/screens/profile_screen.dart';
import 'package:zeokash/features/zeocoins/presentation/providers/zeocoin_provider.dart';

class HomeHeader extends ConsumerStatefulWidget {
  final String greeting;
  final VoidCallback onNotificationTap;

  const HomeHeader({
    super.key,
    required this.greeting,
    required this.onNotificationTap,
  });

  @override
  ConsumerState<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends ConsumerState<HomeHeader> {
  String _cachedFirstName = 'User';

  @override
  void initState() {
    super.initState();
    _loadCachedName();
  }

  Future<void> _loadCachedName() async {
    try {
      final storage = ref.read(secureStorageProvider);
      final name = await storage.getFullName();
      if (name != null && name.isNotEmpty && name != 'Valued Customer') {
        if (mounted) {
          setState(() {
            _cachedFirstName = name.split(' ').first;
          });
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileDataProvider);
    final profileData = profileAsync.asData?.value ?? {};
    final fullName = profileData['profile']?['full_name'] ?? profileData['full_name'] ?? '';
    final firstName = fullName.isNotEmpty ? fullName.split(' ').first : _cachedFirstName;
    final photoUrl = profileData['profile']?['profile_photo'] ?? profileData['profile_photo'];

    final walletAsync = ref.watch(zeocoinWalletProvider);
    final availableCoins = walletAsync.asData?.value.availableBalance.toInt() ?? 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 14, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.push('/profile'),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primaryBlue, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: AppTheme.primaryNavy,
                      backgroundImage: photoUrl != null && photoUrl.toString().isNotEmpty
                          ? (photoUrl.toString().startsWith('http')
                              ? NetworkImage(photoUrl)
                              : FileImage(File(photoUrl)) as ImageProvider)
                          : null,
                      child: (photoUrl == null || photoUrl.toString().isEmpty)
                          ? const Icon(Icons.person, color: Colors.white, size: 22)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.greeting}, $firstName',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),

          // Available ZeoCoins Pill Badge (Redirects to My Rewards screen)
          InkWell(
            onTap: () => context.push('/rewards/my-rewards'),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFF59E0B), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD97706).withValues(alpha: 0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/rewards/g_coins/64/g_coin_01.png',
                    width: 22,
                    height: 22,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [Color(0xFFFFE082), Color(0xFFFFB300), Color(0xFFE65100)],
                          stops: [0.3, 0.7, 1.0],
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'G',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '$availableCoins',
                    style: const TextStyle(
                      color: Color(0xFF92400E),
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),

          IconButton(
            onPressed: widget.onNotificationTap,
            icon: const Icon(Icons.notifications_outlined, size: 28),
            color: AppTheme.primaryText,
          ),
        ],
      ),
    );
  }
}

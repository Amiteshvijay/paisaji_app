import 'package:zeokash/core/storage/secure_storage.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/features/auth/providers/auth_provider.dart';
import 'package:zeokash/features/profile/data/profile_repository.dart';
import 'package:geolocator/geolocator.dart';
import 'package:zeokash/core/services/location_service.dart';


final profileDataProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final repo = ref.read(profileRepositoryProvider);
  final profileData = await repo.getProfile();
  final profileObj = profileData['profile'] ?? profileData;
  final name = profileObj['full_name'] ?? profileData['full_name'];
  if (name != null && name.toString().isNotEmpty) {
    ref.read(secureStorageProvider).saveFullName(name.toString());
  }
  return profileData;
});

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String _appVersion = '1.0.0';
  bool _isUploadingPhoto = false;
  String? _localityName;
  bool _isLocationCached = false;
  bool _isDetectingLocation = false;


  @override
  void initState() {
    super.initState();
    _loadVersion();
    _loadCachedLocation();
    _autoDetectIfPermitted();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = info.version;
        });
      }
    } catch (_) {}
  }


  Future<void> _loadCachedLocation() async {
    final locationService = ref.read(locationServiceProvider);
    final cached = await locationService.getCachedLocality();
    if (mounted && cached != null && cached.isNotEmpty) {
      setState(() {
        _localityName = cached;
        _isLocationCached = true;
      });
    }
  }

  Future<void> _autoDetectIfPermitted() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (serviceEnabled) {
          _detectLocation(silent: true);
        }
      }
    } catch (_) {}
  }

  Future<void> _detectLocation({bool silent = false}) async {
    if (_isDetectingLocation) return;
    setState(() => _isDetectingLocation = true);

    try {
      final locationService = ref.read(locationServiceProvider);
      final res = await locationService.detectCurrentLocality();

      if (mounted) {
        setState(() {
          if (res.localityName != null) {
            _localityName = res.localityName;
            _isLocationCached = res.isCached;
          }
          _isDetectingLocation = false;
        });

        if (!silent) {
          if (res.errorMessage != null && res.localityName == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(res.errorMessage!)),
            );
          } else if (res.localityName != null && !res.isCached) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Location updated to ${res.localityName}'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      }
    } catch (_) {
      if (mounted) setState(() => _isDetectingLocation = false);
    }
  }

  Widget _buildLocationRow() {
    final bool hasLocation = _localityName != null && _localityName!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(top: 6.0),
      child: InkWell(
        onTap: _isDetectingLocation ? null : () => _detectLocation(silent: false),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.location_on,
                size: 16,
                color: AppTheme.primaryBlue,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  hasLocation ? _localityName! : 'Set Location',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: hasLocation ? AppTheme.primaryNavy : AppTheme.primaryBlue,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (hasLocation && _isLocationCached) ...[
                const SizedBox(width: 4),
                const Text(
                  '(Last known)',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.secondaryText,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              const SizedBox(width: 6),
              if (_isDetectingLocation)
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 1.5, color: AppTheme.primaryBlue),
                )
              else
                const Icon(
                  Icons.refresh,
                  size: 15,
                  color: AppTheme.secondaryText,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImage(WidgetRef ref) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      
      if (pickedFile != null) {
        setState(() => _isUploadingPhoto = true);
        final repo = ref.read(profileRepositoryProvider);
        await repo.uploadProfilePhoto(pickedFile.path);
        ref.invalidate(profileDataProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture uploaded successfully to server!'),
              backgroundColor: AppTheme.success,
            ),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile picture')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Log out of Paisaजी?', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              const Text("You'll need to verify your account again to continue.", style: TextStyle(color: AppTheme.secondaryText)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        final storage = ref.read(secureStorageProvider);
                        final lastMobile = await storage.getLastMobileNumber();
                        final isMpinSet = await storage.getIsMpinSet();
                        await ref.read(authControllerProvider.notifier).logout();
                        if (context.mounted) {
                          if (lastMobile != null && lastMobile.isNotEmpty && isMpinSet == true) {
                            context.go('/auth/mpin-login', extra: lastMobile);
                          } else {
                            context.go('/auth/welcome');
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
                      child: const Text('Log Out'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const double horizontalPadding = 20.0;
    const double cardMargin = 16.0;

    final profileAsync = ref.watch(profileDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue)),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("We couldn't load your profile."),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(profileDataProvider),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
        data: (profileData) {
          final profileObj = profileData['profile'] ?? {};
          final rawFullName = profileObj['full_name'] ?? profileData['full_name'] ?? '';
          final userMobile = profileData['mobile_number'] ?? profileObj['mobile_number'] ?? '';
          final fullName = (rawFullName.toString().trim().isNotEmpty && rawFullName != 'User' && rawFullName != 'Paisaजी User')
              ? rawFullName.toString().trim()
              : (userMobile.toString().trim().isNotEmpty ? userMobile.toString().trim() : 'Paisaजी User');
          final photoUrl = profileObj['profile_photo'];

          final initial = fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U';

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header Profile Info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: cardMargin),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => _pickAndUploadImage(ref),
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: AppTheme.primaryNavy,
                              backgroundImage: photoUrl != null && photoUrl.toString().isNotEmpty
                                  ? (photoUrl.toString().startsWith('http')
                                      ? NetworkImage(photoUrl)
                                      : FileImage(File(photoUrl)) as ImageProvider)
                                  : null,
                              child: (photoUrl == null || photoUrl.toString().isEmpty)
                                  ? Text(
                                      initial,
                                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white),
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppTheme.primaryBlue,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt, color: Colors.white, size: 12),
                              ),
                            ),
                            if (_isUploadingPhoto)
                              const Positioned.fill(
                                child: CircularProgressIndicator(color: AppTheme.primaryBlue, strokeWidth: 2),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(fullName, style: Theme.of(context).textTheme.headlineMedium),
                            _buildLocationRow(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                _buildSection(
                  context,
                  title: 'Account & Settings',
                  items: [
                    _ProfileItem(
                      icon: Icons.account_balance_wallet,
                      title: 'Paisaजी Wallet',
                      onTap: () => context.push('/wallet'),
                    ),
                    _ProfileItem(
                      icon: Icons.person_outline,
                      title: 'Personal Details',
                      onTap: () => context.push('/profile/personal-details'),
                    ),
                    _ProfileItem(
                      icon: Icons.verified_user_outlined,
                      title: 'E-KYC Verification',
                      onTap: () => context.push('/profile/ekyc'),
                    ),
                    _ProfileItem(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'Payment Methods',
                      onTap: () => context.push('/profile/payment-methods'),
                    ),
                    _ProfileItem(
                      icon: Icons.bookmark_border,
                      title: 'Saved Billers',
                      onTap: () => context.push('/profile/saved-billers'),
                    ),
                  ],
                ),
                
                _buildSection(
                  context,
                  title: 'Rewards & Referrals',
                  items: [
                    _ProfileItem(
                      icon: Icons.card_giftcard,
                      title: 'Invite & Earn',
                      subtitle: 'Earn up to 100 G Coins per friend',
                      onTap: () => context.push('/referral-dashboard'),
                    ),

                  ],
                ),
                
                _buildSection(
                  context,
                  title: 'Preferences',
                  items: [
                    _ProfileItem(
                      icon: Icons.security,
                      title: 'Security',
                      onTap: () => context.push('/profile/security'),
                    ),
                    _ProfileItem(
                      icon: Icons.notifications_none,
                      title: 'Notifications',
                      onTap: () => context.push('/profile/notifications'),
                    ),
                    _ProfileItem(
                      icon: Icons.language,
                      title: 'Language',
                      subtitle: profileData['preferred_language'] == 'hi' ? 'हिन्दी' : 'English',
                      onTap: () => context.push('/profile/language'),
                    ),
                  ],
                ),
                
                _buildSection(
                  context,
                  title: 'Support',
                  items: [
                    _ProfileItem(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      onTap: () => context.push('/profile/help-support'),
                    ),
                    _ProfileItem(
                      icon: Icons.report_problem_outlined,
                      title: 'Complaints',
                      onTap: () => context.push('/profile/complaints'),
                    ),
                  ],
                ),
                
                _buildSection(
                  context,
                  title: 'About',
                  items: [
                    _ProfileItem(
                      icon: Icons.description_outlined,
                      title: 'Legal',
                      onTap: () => context.push('/profile/legal'),
                    ),
                    _ProfileItem(
                      icon: Icons.logout,
                      title: 'Logout',
                      isDestructive: true,
                      onTap: () => _showLogoutDialog(context, ref),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                Text('Version $_appVersion', style: const TextStyle(color: AppTheme.secondaryText, fontSize: 12)),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required List<_ProfileItem> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: Text(
            title,
            style: const TextStyle(
              color: AppTheme.secondaryText,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == items.length - 1;

              return Column(
                children: [
                  ListTile(
                    leading: Icon(
                      item.icon,
                      color: item.isDestructive ? AppTheme.error : AppTheme.primaryNavy,
                    ),
                    title: Text(
                      item.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: item.isDestructive ? AppTheme.error : AppTheme.primaryText,
                      ),
                    ),
                    subtitle: item.subtitle != null
                        ? Text(
                            item.subtitle!,
                            style: const TextStyle(color: AppTheme.secondaryText, fontSize: 12),
                          )
                        : null,
                    trailing: const Icon(Icons.chevron_right, color: AppTheme.secondaryText),
                    onTap: item.onTap,
                  ),
                  if (!isLast) const Divider(color: AppTheme.border, height: 1, indent: 56),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _ProfileItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool isDestructive;
  final VoidCallback onTap;

  const _ProfileItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.isDestructive = false,
    required this.onTap,
  });
}


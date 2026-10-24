import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeokash/core/network/api_client.dart';
import 'package:zeokash/core/theme/app_theme.dart';

final notificationPrefsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final dio = ref.read(dioProvider);
  try {
    final response = await dio.get('profile/notification-preferences/');
    return response.data['data'] ?? {};
  } catch (_) {
    return {
      'email_notifications': true,
      'sms_notifications': true,
      'push_notifications': true,
      'in_app_notifications': true,
    };
  }
});

class NotificationsSettingsScreen extends ConsumerStatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  ConsumerState<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends ConsumerState<NotificationsSettingsScreen> {
  bool _isSaving = false;

  Future<void> _updatePref(WidgetRef ref, BuildContext context, Map<String, dynamic> data) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isSaving = true);
    final dio = ref.read(dioProvider);
    try {
      await dio.patch('profile/notification-preferences/', data: data);
      ref.invalidate(notificationPrefsProvider);
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Notification preferences updated successfully')),
        );
      }
    } catch (_) {
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Failed to update notification preferences')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const double horizontalPadding = 20.0;
    const double cardMargin = 8.0;

    final prefsAsync = ref.watch(notificationPrefsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Alert & Message Channels', style: TextStyle(color: AppTheme.secondaryText, fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: cardMargin),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: prefsAsync.when(
                loading: () => const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue))),
                error: (e, s) => Padding(padding: const EdgeInsets.all(16), child: Text('Failed to load notification preferences: $e')),
                data: (prefs) {
                  return Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Push Notifications', style: TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: const Text('Receive payment alerts on device', style: TextStyle(color: AppTheme.secondaryText, fontSize: 13)),
                        value: prefs['push_notifications'] ?? true,
                        activeThumbColor: AppTheme.primaryBlue,
                        onChanged: _isSaving ? null : (val) async {
                          await _updatePref(ref, context, {'push_notifications': val});
                        },
                      ),
                      const Divider(color: AppTheme.border, height: 1, indent: 16),
                      SwitchListTile(
                        title: const Text('SMS Alerts', style: TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: const Text('Critical transaction updates via SMS', style: TextStyle(color: AppTheme.secondaryText, fontSize: 13)),
                        value: prefs['sms_notifications'] ?? true,
                        activeThumbColor: AppTheme.primaryBlue,
                        onChanged: _isSaving ? null : (val) async {
                          await _updatePref(ref, context, {'sms_notifications': val});
                        },
                      ),
                      const Divider(color: AppTheme.border, height: 1, indent: 16),
                      SwitchListTile(
                        title: const Text('Email Updates', style: TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: const Text('Receipts and monthly statements', style: TextStyle(color: AppTheme.secondaryText, fontSize: 13)),
                        value: prefs['email_notifications'] ?? true,
                        activeThumbColor: AppTheme.primaryBlue,
                        onChanged: _isSaving ? null : (val) async {
                          await _updatePref(ref, context, {'email_notifications': val});
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

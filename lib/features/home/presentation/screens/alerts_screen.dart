import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/features/home/data/notification_model.dart';
import 'package:zeokash/features/home/presentation/providers/notification_provider.dart';

class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({super.key});

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen> {
  final List<Map<String, String>> _categories = [
    {'label': 'All', 'key': 'ALL'},
    {'label': 'Transactions', 'key': 'RECHARGE_SUCCESS'},
    {'label': 'Rewards', 'key': 'G_COIN_EARNED'},
    {'label': 'Reminders', 'key': 'RECHARGE_EXPIRY_REMINDER'},
    {'label': 'Support', 'key': 'SUPPORT_TICKET'},
  ];

  @override
  Widget build(BuildContext context) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final notificationsAsync = ref.watch(notificationsListProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Notification Center',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryNavy),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          TextButton.icon(
            onPressed: () {
              ref.read(notificationsListProvider.notifier).markAllAsRead();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All notifications marked as read'), duration: Duration(seconds: 1)),
              );
            },
            icon: const Icon(Icons.done_all, size: 18, color: AppTheme.primaryBlue),
            label: const Text(
              'Read All',
              style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          IconButton(
            tooltip: 'Close',
            icon: const Icon(Icons.close, color: AppTheme.primaryNavy),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filter Categories Tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((cat) {
                  final isSelected = selectedCategory == cat['key'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(
                        cat['label']!,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.primaryNavy,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      selectedColor: AppTheme.primaryNavy,
                      backgroundColor: const Color(0xFFF1F5F9),
                      checkmarkColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      side: BorderSide.none,
                      onSelected: (val) {
                        ref.read(selectedCategoryProvider.notifier).setCategory(cat['key']!);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppTheme.border),

          // Main Notifications List
          Expanded(
            child: notificationsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue)),
              error: (err, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
                    const SizedBox(height: 12),
                    const Text('Failed to load notifications', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => ref.read(notificationsListProvider.notifier).fetchNotifications(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (notifications) {
                if (notifications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryNavy.withValues(alpha: 0.05),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.notifications_none_rounded, size: 54, color: AppTheme.secondaryText),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No Notifications Yet',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'You will receive real-time updates regarding\nrecharges, rewards, and offers here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppTheme.secondaryText, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppTheme.primaryBlue,
                  onRefresh: () async {
                    await ref.read(notificationsListProvider.notifier).fetchNotifications();
                    await ref.read(unreadNotificationsCountProvider.notifier).refresh();
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: notifications.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = notifications[index];
                      return _buildNotificationCard(context, item);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, NotificationItem item) {
    final style = _getNotificationStyle(item.type);

    return InkWell(
      onTap: () {
        if (!item.isRead) {
          ref.read(notificationsListProvider.notifier).markAsRead(item.id);
        }
        if (item.deepLink != null && item.deepLink!.isNotEmpty) {
          try {
            context.push(item.deepLink!);
          } catch (_) {}
        }
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: item.isRead ? Colors.white : const Color(0xFFF0F7FF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: item.isRead ? AppTheme.border : AppTheme.primaryBlue.withValues(alpha: 0.4),
            width: item.isRead ? 1 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryNavy.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: style.color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(style.icon, color: style.color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
                            fontSize: 14.5,
                            color: AppTheme.primaryNavy,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(item.createdAt),
                        style: const TextStyle(color: AppTheme.secondaryText, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.message,
                    style: TextStyle(
                      color: item.isRead ? AppTheme.secondaryText : const Color(0xFF334155),
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            if (!item.isRead) ...[
              const SizedBox(width: 6),
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryBlue,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  _NotificationTypeStyle _getNotificationStyle(String type) {
    switch (type.toUpperCase()) {
      case 'RECHARGE_SUCCESS':
      case 'PAYMENT_SUCCESS':
        return _NotificationTypeStyle(Icons.check_circle_rounded, AppTheme.success);
      case 'RECHARGE_FAILED':
      case 'PAYMENT_PENDING':
        return _NotificationTypeStyle(Icons.error_rounded, AppTheme.error);
      case 'G_COIN_EARNED':
      case 'REFERRAL_REWARD':
        return _NotificationTypeStyle(Icons.stars_rounded, const Color(0xFFD97706));
      case 'RECHARGE_EXPIRY_REMINDER':
      case 'POST_EXPIRY_REMINDER':
        return _NotificationTypeStyle(Icons.alarm_rounded, const Color(0xFFEA580C));
      case 'WITHDRAWAL_UPDATE':
        return _NotificationTypeStyle(Icons.account_balance_wallet_rounded, AppTheme.primaryBlue);
      case 'SECURITY_ALERT':
        return _NotificationTypeStyle(Icons.shield_rounded, AppTheme.error);
      case 'SUPPORT_TICKET':
        return _NotificationTypeStyle(Icons.support_agent_rounded, AppTheme.primaryNavy);
      default:
        return _NotificationTypeStyle(Icons.notifications_active_rounded, AppTheme.primaryBlue);
    }
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}';
  }
}

class _NotificationTypeStyle {
  final IconData icon;
  final Color color;
  _NotificationTypeStyle(this.icon, this.color);
}


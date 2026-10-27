import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:zeokash/core/routing/app_router.dart';
import 'package:zeokash/core/services/notification_service.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/features/auth/providers/auth_provider.dart';
import 'package:zeokash/features/home/data/notification_repository.dart';
import 'package:zeokash/features/home/presentation/providers/notification_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization exception: $e');
  }
  runApp(const ProviderScope(child: ZeoKashApp()));
}

class ZeoKashApp extends ConsumerStatefulWidget {
  const ZeoKashApp({super.key});

  @override
  ConsumerState<ZeoKashApp> createState() => _ZeoKashAppState();
}

class _ZeoKashAppState extends ConsumerState<ZeoKashApp> with WidgetsBindingObserver {
  /// Centrally configurable background inactivity lock grace period (30s default)
  static const Duration _inactivityGracePeriod = Duration(seconds: 30);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize Push Notifications
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initPushNotifications();
    });
  }

  void _initPushNotifications() {
    try {
      final repo = ref.read(notificationRepositoryProvider);
      PushNotificationService().initialize(
        repository: repo,
        navigateCallback: (route) {
          if (route != null && route.isNotEmpty) {
            try {
              final router = ref.read(routerProvider);
              router.push(route);
            } catch (_) {}
          }
        },
        refreshCallback: () {
          ref.read(unreadNotificationsCountProvider.notifier).refresh();
          ref.read(notificationsListProvider.notifier).fetchNotifications();
        },
      );
    } catch (e) {
      debugPrint('PushNotificationService init error: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final authNotifier = ref.read(authControllerProvider.notifier);

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        authNotifier.onAppBackgrounded();
        break;
      case AppLifecycleState.resumed:
        authNotifier.onAppResumed(gracePeriod: _inactivityGracePeriod);
        ref.read(unreadNotificationsCountProvider.notifier).refresh();
        break;
      case AppLifecycleState.detached:
        authNotifier.onAppBackgrounded();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Paisaजी',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}

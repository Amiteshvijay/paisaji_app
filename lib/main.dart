import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeokash/core/routing/app_router.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/features/auth/providers/auth_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
        break;
      case AppLifecycleState.detached:
        // Background transition: never treat process termination or detachment as user logout
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

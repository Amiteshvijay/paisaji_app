import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zeokash/features/home/data/notification_model.dart';
import 'package:zeokash/features/home/data/notification_repository.dart';

final selectedCategoryProvider = NotifierProvider<SelectedCategoryNotifier, String>(() {
  return SelectedCategoryNotifier();
});

class SelectedCategoryNotifier extends Notifier<String> {
  @override
  String build() => 'ALL';

  void setCategory(String category) {
    state = category;
  }
}

final unreadNotificationsCountProvider = NotifierProvider<UnreadCountNotifier, int>(() {
  return UnreadCountNotifier();
});

class UnreadCountNotifier extends Notifier<int> {
  late final NotificationRepository _repo;

  @override
  int build() {
    _repo = ref.watch(notificationRepositoryProvider);
    Future.microtask(() => refresh());
    return 0;
  }

  Future<void> refresh() async {
    final count = await _repo.getUnreadCount();
    state = count;
  }

  void decrement() {
    if (state > 0) state = state - 1;
  }

  void reset() {
    state = 0;
  }
}

final notificationsListProvider = NotifierProvider<NotificationsNotifier, AsyncValue<List<NotificationItem>>>(() {
  return NotificationsNotifier();
});

class NotificationsNotifier extends Notifier<AsyncValue<List<NotificationItem>>> {
  late final NotificationRepository _repo;

  @override
  AsyncValue<List<NotificationItem>> build() {
    _repo = ref.watch(notificationRepositoryProvider);
    ref.watch(selectedCategoryProvider);
    Future.microtask(() => fetchNotifications());
    return const AsyncValue.loading();
  }

  Future<void> fetchNotifications() async {
    try {
      state = const AsyncValue.loading();
      final category = ref.read(selectedCategoryProvider);
      final items = await _repo.getNotifications(type: category);
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAsRead(String id) async {
    final current = state.value ?? [];
    state = AsyncValue.data(current.map((item) {
      if (item.id == id) {
        return item.copyWith(isRead: true);
      }
      return item;
    }).toList());

    ref.read(unreadNotificationsCountProvider.notifier).decrement();
    await _repo.markAsRead(id);
  }

  Future<void> markAllAsRead() async {
    final current = state.value ?? [];
    state = AsyncValue.data(current.map((item) => item.copyWith(isRead: true)).toList());
    ref.read(unreadNotificationsCountProvider.notifier).reset();
    await _repo.markAllAsRead();
  }
}

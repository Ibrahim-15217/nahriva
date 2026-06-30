import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahriva/features/auth/presentation/providers/auth_provider.dart';
import 'package:nahriva/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:nahriva/features/notifications/domain/entities/app_notification.dart';

final notificationDataSourceProvider = Provider<NotificationRemoteDataSource>((ref) {
  return NotificationRemoteDataSource();
});

final notificationsStreamProvider = StreamProvider<List<AppNotification>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  final dataSource = ref.watch(notificationDataSourceProvider);
  return dataSource.getNotifications(user.uid).map((list) => list.map((d) => AppNotification(
    id: d['id'] as String,
    title: d['title'] as String? ?? '',
    body: d['body'] as String? ?? '',
    type: d['type'] as String? ?? 'general',
    isRead: d['isRead'] as bool? ?? false,
    createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    relatedId: d['relatedId'] as String?,
  )).toList());
});

final unreadCountProvider = FutureProvider<int>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return 0;
  final dataSource = ref.watch(notificationDataSourceProvider);
  return dataSource.getUnreadCount(user.uid);
});

final markNotificationReadProvider = FutureProvider.family<void, String>((ref, id) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return;
  final dataSource = ref.watch(notificationDataSourceProvider);
  await dataSource.markAsRead(user.uid, id);
  ref.invalidate(unreadCountProvider);
});

final markAllNotificationsReadProvider = FutureProvider<void>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return;
  final dataSource = ref.watch(notificationDataSourceProvider);
  await dataSource.markAllAsRead(user.uid);
  ref.invalidate(unreadCountProvider);
});

class NotificationService {
  static Future<void> createNotification({
    required String uid,
    required String title,
    required String body,
    required String type,
    String? relatedId,
  }) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).collection('notifications').add({
      'title': title,
      'body': body,
      'type': type,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
      'relatedId': relatedId,
    });
  }
}

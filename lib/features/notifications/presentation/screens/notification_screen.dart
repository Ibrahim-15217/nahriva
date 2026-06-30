import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahriva/core/theme/app_colors.dart';
import 'package:nahriva/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:nahriva/features/notifications/presentation/providers/notification_providers.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notificationsAsync = ref.watch(notificationsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () => ref.read(markAllNotificationsReadProvider),
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text('No notifications yet', style: TextStyle(fontSize: 16, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                  const SizedBox(height: 8),
                  Text('Your notifications will appear here', style: TextStyle(fontSize: 13, color: isDark ? Colors.grey.shade500 : Colors.grey.shade500)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return _buildNotificationTile(context, isDark, notif, ref);
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationTile(BuildContext context, bool isDark, dynamic notif, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        if (!notif.isRead) {
          ref.read(markNotificationReadProvider(notif.id));
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notif.isRead
              ? (isDark ? Colors.grey.shade800 : Colors.white)
              : (isDark ? AppColors.primaryDark.withValues(alpha: 0.1) : AppColors.primaryLight.withValues(alpha: 0.05)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notif.isRead
                ? (isDark ? Colors.grey.shade700 : Colors.grey.shade200)
                : (isDark ? AppColors.primaryDark.withValues(alpha: 0.3) : AppColors.primaryLight.withValues(alpha: 0.2)),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(NotificationRemoteDataSource.typeIcon(notif.type), style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: notif.isRead ? FontWeight.normal : FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      if (!notif.isRead)
                        Container(
                          width: 8, height: 8,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.body,
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _timeAgo(notif.createdAt),
                    style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade500 : Colors.grey.shade400),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.month}/${date.day}';
  }
}

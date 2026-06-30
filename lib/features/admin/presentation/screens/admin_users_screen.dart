import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahriva/core/theme/app_colors.dart';
import 'package:nahriva/features/auth/presentation/providers/auth_provider.dart';

final adminUsersProvider = StreamProvider<List<DocumentSnapshot>>((ref) {
  return FirebaseFirestore.instance.collection('users').orderBy('points', descending: true).snapshots().map((s) => s.docs);
});

class AdminUsersScreen extends ConsumerWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final usersAsync = ref.watch(adminUsersProvider);
    final user = ref.watch(currentUserProvider);

    if (user == null || user.role != 'admin') {
      return Scaffold(
        appBar: AppBar(title: const Text('Users')),
        body: const Center(child: Text('Access denied')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: usersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (docs) {
          if (docs.isEmpty) {
            return const Center(child: Text('No users'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              return _buildUserTile(context, isDark, doc.id, data);
            },
          );
        },
      ),
    );
  }

  Widget _buildUserTile(BuildContext context, bool isDark, String uid, Map<String, dynamic> data) {
    final displayName = data['displayName'] as String? ?? 'Unknown';
    final email = data['email'] as String? ?? '';
    final role = data['role'] as String? ?? 'user';
    final points = data['points'] as int? ?? 0;
    final reportsCount = data['reportsCount'] as int? ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: role == 'admin' ? Colors.orange : AppColors.primary,
            child: Text(displayName.isNotEmpty ? displayName[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(displayName, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
                    const SizedBox(width: 6),
                    if (role == 'admin')
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                        child: const Text('Admin', style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.w600)),
                      ),
                  ],
                ),
                Text(email, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.eco, size: 14, color: AppColors.primary), const SizedBox(width: 4), Text('$points', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary))]),
              Text('$reportsCount reports', style: TextStyle(fontSize: 10, color: isDark ? Colors.grey.shade500 : Colors.grey.shade500)),
            ],
          ),
        ],
      ),
    );
  }
}

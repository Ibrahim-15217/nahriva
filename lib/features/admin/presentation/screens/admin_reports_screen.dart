import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahriva/core/theme/app_colors.dart';
import 'package:nahriva/features/auth/presentation/providers/auth_provider.dart';

final adminReportsProvider = StreamProvider<List<DocumentSnapshot>>((ref) {
  return FirebaseFirestore.instance.collection('reports').orderBy('timestamp', descending: true).snapshots().map((s) => s.docs);
});

class AdminReportsScreen extends ConsumerWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reportsAsync = ref.watch(adminReportsProvider);
    final user = ref.watch(currentUserProvider);

    if (user == null || user.role != 'admin') {
      return Scaffold(
        appBar: AppBar(title: const Text('Reports')),
        body: const Center(child: Text('Access denied')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Reports')),
      body: reportsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (docs) {
          if (docs.isEmpty) {
            return const Center(child: Text('No reports'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              return _buildReportTile(context, isDark, doc.id, data, ref);
            },
          );
        },
      ),
    );
  }

  Widget _buildReportTile(BuildContext context, bool isDark, String id, Map<String, dynamic> data, WidgetRef ref) {
    final status = data['status'] as String? ?? 'pending';
    final statusColors = {'pending': Colors.orange, 'verified': Colors.green, 'resolved': AppColors.primary};
    final color = statusColors[status] ?? Colors.grey;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(status, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(data['wasteType'] as String? ?? '', style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
              ),
              const Spacer(),
              Text('${data['trustScore'] as int? ?? 0}', style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
            ],
          ),
          const SizedBox(height: 8),
          Text(data['description'] as String? ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: isDark ? Colors.grey.shade300 : Colors.grey.shade700)),
          if (data['address'] != null && (data['address'] as String).isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(children: [Icon(Icons.location_on, size: 12, color: Colors.grey), const SizedBox(width: 4), Text(data['address'] as String, style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade500 : Colors.grey.shade500))]),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              if (status != 'verified') ...[
                Expanded(child: _buildActionButton('Verify', Colors.green, () => _updateStatus(context, id, 'verified', ref))),
                const SizedBox(width: 8),
              ],
              if (status != 'resolved')
                Expanded(child: _buildActionButton('Resolve', AppColors.primary, () => _updateStatus(context, id, 'resolved', ref))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onPressed) {
    return SizedBox(
      height: 36,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        child: Text(label, style: const TextStyle(fontSize: 12)),
      ),
    );
  }

  Future<void> _updateStatus(BuildContext context, String reportId, String newStatus, WidgetRef ref) async {
    await FirebaseFirestore.instance.collection('reports').doc(reportId).update({'status': newStatus});
    ref.invalidate(adminReportsProvider);
  }
}

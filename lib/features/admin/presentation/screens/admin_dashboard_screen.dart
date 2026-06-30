import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahriva/core/theme/app_colors.dart';
import 'package:nahriva/features/admin/presentation/screens/admin_broadcast_screen.dart';
import 'package:nahriva/features/admin/presentation/screens/admin_reports_screen.dart';
import 'package:nahriva/features/admin/presentation/screens/admin_users_screen.dart';
import 'package:nahriva/features/analytics/data/services/analytics_service.dart';
import 'package:nahriva/features/auth/presentation/providers/auth_provider.dart';

final adminStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = AnalyticsService();
  return service.getPlatformStats();
});

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statsAsync = ref.watch(adminStatsProvider);
    final user = ref.watch(currentUserProvider);

    if (user == null || user.role != 'admin') {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin')),
        body: const Center(child: Text('Access denied. Admin only.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(adminStatsProvider),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, isDark),
              const SizedBox(height: 20),
              _buildSectionHeader(context, 'Platform Overview'),
              const SizedBox(height: 12),
              statsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e'),
                data: (stats) => _buildStatsGrid(context, isDark, stats),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Management'),
              const SizedBox(height: 12),
              _buildManagementCard(context, isDark, Icons.report_problem, 'Reports', 'View and manage all reports', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminReportsScreen()))),
              const SizedBox(height: 8),
              _buildManagementCard(context, isDark, Icons.people, 'Users', 'View all registered users', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminUsersScreen()))),
              const SizedBox(height: 8),
              _buildManagementCard(context, isDark, Icons.campaign, 'Broadcast', 'Send notification to all users', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminBroadcastScreen()))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark ? [Colors.grey.shade800, Colors.grey.shade900] : [Colors.grey.shade200, Colors.grey.shade100],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: isDark ? Colors.orange.shade800 : Colors.orange,
            child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          const Expanded(child: Text('Admin Dashboard', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87));
  }

  Widget _buildStatsGrid(BuildContext context, bool isDark, Map<String, dynamic> stats) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatCard(context, isDark, 'Total Users', '${stats['totalUsers'] ?? 0}', Icons.people, Colors.blue)),
            const SizedBox(width: 8),
            Expanded(child: _buildStatCard(context, isDark, 'Total Reports', '${stats['totalReports'] ?? 0}', Icons.report, AppColors.warning)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildStatCard(context, isDark, 'Verified', '${stats['verifiedReports'] ?? 0}', Icons.verified, Colors.green)),
            const SizedBox(width: 8),
            Expanded(child: _buildStatCard(context, isDark, 'Resolved', '${stats['resolvedReports'] ?? 0}', Icons.check_circle, AppColors.primary)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, bool isDark, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
          Text(label, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildManagementCard(BuildContext context, bool isDark, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
                Text(subtitle, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
              ],
            )),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

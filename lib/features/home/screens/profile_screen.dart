import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahriva/core/theme/app_colors.dart';
import 'package:nahriva/features/auth/presentation/providers/auth_provider.dart';
import 'package:nahriva/features/gamification/presentation/providers/gamification_providers.dart';
import 'package:nahriva/features/gamification/presentation/widgets/badge_card.dart';
import 'package:nahriva/features/home/screens/edit_profile_screen.dart';
import 'package:nahriva/features/report/presentation/providers/report_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userAsync = ref.watch(userProfileProvider);
    final badgesAsync = ref.watch(badgesProvider);
    final reportsAsync = ref.watch(reportsStreamProvider);
    final logout = ref.watch(logoutProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EditProfileScreen())),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(userProfileProvider);
          ref.invalidate(badgesProvider);
          ref.invalidate(reportsStreamProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              userAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e'),
                data: (user) => _buildProfileHeader(context, isDark, user),
              ),
              const SizedBox(height: 20),
              _buildSectionHeader(context, 'Badges', Icons.emoji_events),
              const SizedBox(height: 8),
              badgesAsync.when(
                loading: () => const SizedBox(height: 150, child: Center(child: CircularProgressIndicator())),
                error: (e, _) => Text('Error: $e'),
                data: (badges) {
                  final unlocked = badges.where((b) => b.isUnlocked).toList();
                  if (unlocked.isEmpty) {
                    return _buildEmptySection(context, 'No badges yet. Complete actions to earn badges!');
                  }
                  return SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: badges.length,
                      itemBuilder: (context, index) => BadgeCard(badge: badges[index]),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildSectionHeader(context, 'Recent Reports', Icons.report_problem),
              const SizedBox(height: 8),
              reportsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e'),
                data: (reports) {
                  final currentUid = userAsync.asData?.value?.uid;
                  final userReports = currentUid != null
                      ? reports.where((r) => r.userId == currentUid).take(5).toList()
                      : <dynamic>[];
                  if (userReports.isEmpty) {
                    return _buildEmptySection(context, 'No reports yet. Submit your first report!');
                  }
                  return Column(
                    children: userReports.map((r) => _buildReportTile(context, isDark, r)).toList(),
                  );
                },
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Settings', Icons.settings),
              const SizedBox(height: 8),
              _buildSettingsSection(context, isDark),
              const SizedBox(height: 24),
              _buildLogoutButton(context, logout),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, bool isDark, dynamic user) {
    if (user == null) return const SizedBox.shrink();
    final joinDate = user.createdAt;
    final joinStr = '${joinDate.month}/${joinDate.year}';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.primaryDark.withValues(alpha: 0.8), Colors.grey.shade900]
              : [AppColors.primary, AppColors.primaryLight],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white24,
            child: Text(
              user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?',
              style: const TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            user.displayName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: const TextStyle(fontSize: 13, color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            'Joined $joinStr',
            style: const TextStyle(fontSize: 12, color: Colors.white60),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStat(context, '${user.points}', 'Points'),
              _buildStat(context, '${user.reportsCount}', 'Reports'),
              _buildStat(context, '${user.currentStreak}', 'Day Streak'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87)),
      ],
    );
  }

  Widget _buildEmptySection(BuildContext context, String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800.withValues(alpha: 0.5) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(message, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
    );
  }

  Widget _buildReportTile(BuildContext context, bool isDark, dynamic report) {
    final statusColors = {
      'pending': Colors.orange,
      'verified': Colors.green,
      'resolved': AppColors.primary,
    };
    final status = report.status;
    final color = statusColors[status] ?? Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.report_problem, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(report.wasteType ?? 'Unknown', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
                if (report.description != null && report.description.isNotEmpty)
                  Text(report.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(status ?? 'pending', style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildSettingTile(context, isDark, Icons.dark_mode, 'Dark Mode', trailing: Switch(
            value: isDark,
            onChanged: (v) => _toggleTheme(context),
            activeThumbColor: AppColors.primary,
          )),
          const Divider(height: 1, indent: 56),
          _buildSettingTile(context, isDark, Icons.notifications_outlined, 'Notifications', onTap: () {}),
          const Divider(height: 1, indent: 56),
          _buildSettingTile(context, isDark, Icons.info_outline, 'About', onTap: () => _showAbout(context)),
        ],
      ),
    );
  }

  Widget _buildSettingTile(BuildContext context, bool isDark, IconData icon, String title, {VoidCallback? onTap, Widget? trailing}) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: isDark ? AppColors.primaryDark : AppColors.primary),
        title: Text(title, style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Colors.black87)),
        trailing: trailing ?? const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, dynamic logout) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _confirmLogout(context, logout),
        icon: const Icon(Icons.logout, color: Colors.red),
        label: const Text('Log Out', style: TextStyle(color: Colors.red)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, dynamic logout) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              logout();
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _toggleTheme(BuildContext context) {
    // Theme toggle - will use the app's theme mode controller
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Nahriva',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.eco, size: 48, color: AppColors.primary),
      children: [
        const Text('Environmental reporting and education platform.'),
      ],
    );
  }
}

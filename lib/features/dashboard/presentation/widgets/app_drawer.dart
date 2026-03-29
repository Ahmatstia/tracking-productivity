import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:life_os_productivity/core/constants/app_colors.dart';
import 'package:life_os_productivity/features/gamification/presentation/providers/stats_provider.dart';
import 'package:life_os_productivity/features/gamification/domain/user_stats_model.dart';
import 'package:life_os_productivity/features/focus/presentation/pages/focus_page.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamification = ref.watch(gamificationProvider);
    final userStats = gamification.stats;

    return Drawer(
      backgroundColor: const Color(0xFF0D0D19), // Deeper premium dark
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: Column(
          children: [
            // Header: User Profile Card
            _buildDrawerHeader(context, userStats),
            
            const SizedBox(height: 12),
            const Divider(color: Colors.white12, thickness: 1, indent: 20, endIndent: 20),
            const SizedBox(height: 12),

            // Main Menu Action List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                children: [
                  _MenuItem(
                    icon: LucideIcons.timer,
                    title: 'Pomodoro Timer',
                    subtitle: 'Mulai sesi fokus tanpa gangguan',
                    color: AppColors.primary,
                    onTap: () {
                      Navigator.pop(context); // Close drawer
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FocusPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _MenuItem(
                    icon: LucideIcons.settings,
                    title: 'Pengaturan',
                    subtitle: 'Notifikasi & Preferensi',
                    color: Colors.white70,
                    onTap: () {
                      Navigator.pop(context);
                      // Navigator.push for settings in the future
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Menu Pengaturan Segera Hadir!')),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _MenuItem(
                    icon: LucideIcons.crown,
                    title: 'MyLife Premium',
                    subtitle: 'Buka fitur profesional mingguan',
                    color: const Color(0xFFFFD93D),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Anda Sedang Pakai Versi Beta Maksimal!')),
                      );
                    },
                  ),
                ],
              ),
            ),

            const Spacer(),
            
            // Footer Menu (Help/Log out)
            const Divider(color: Colors.white12, thickness: 1, indent: 20, endIndent: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              child: _MenuItem(
                icon: LucideIcons.logOut,
                title: 'Keluar',
                subtitle: '',
                color: Colors.redAccent,
                compact: true,
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context, UserStatsModel userStats) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 32, 24, 24),
      decoration: BoxDecoration(
        color: const Color(0xFF161626),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Elegant Avatar Frame
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                )
              ]
            ),
            child: Container(
              margin: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: Color(0xFF1A1A2E), // Inner ring
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(LucideIcons.user, size: 30, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // User Details
          Text(
            'Sobat Produktif', 
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.flame, color: Colors.orange, size: 14),
                const SizedBox(width: 6),
                Text(
                  '${userStats.currentStreak} Hari Beruntun',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool compact;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      splashColor: color.withValues(alpha: 0.1),
      highlightColor: color.withValues(alpha: 0.05),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: compact ? 12 : 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.transparent),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: compact ? 14 : 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ]
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight, color: Colors.white24, size: 16),
          ],
        ),
      ),
    );
  }
}

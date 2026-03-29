import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:life_os_productivity/core/constants/app_colors.dart';
import 'package:life_os_productivity/features/gamification/presentation/providers/stats_provider.dart';
import 'package:life_os_productivity/features/gamification/domain/user_stats_model.dart';
import 'package:life_os_productivity/features/focus/presentation/pages/focus_page.dart';
import 'package:life_os_productivity/features/profile/presentation/providers/profile_provider.dart';
import 'package:life_os_productivity/features/settings/presentation/pages/settings_page.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamification = ref.watch(gamificationProvider);
    final userStats = gamification.stats;
    final profile = ref.watch(profileProvider);

    return Drawer(
      backgroundColor: AppColors.sheetBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: Column(
          children: [
            _buildDrawerHeader(context, ref, userStats, profile),
            
            const SizedBox(height: 12),
            Divider(color: AppColors.border, thickness: 1, indent: 20, endIndent: 20),
            const SizedBox(height: 12),

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
                      Navigator.pop(context);
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
                    color: AppColors.textSecondary,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  _MenuItem(
                    icon: LucideIcons.crown,
                    title: 'MyLife Premium',
                    subtitle: 'Buka fitur profesional mingguan',
                    color: const Color(0xFFE67E22),
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
            
            Divider(color: AppColors.border, thickness: 1, indent: 20, endIndent: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              child: _MenuItem(
                icon: LucideIcons.logOut,
                title: 'Keluar',
                subtitle: '',
                color: AppColors.error,
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

  Widget _buildDrawerHeader(BuildContext context, WidgetRef ref, UserStatsModel userStats, dynamic profile) {
    final List<Color> avatarColors = [
      AppColors.primary,
      Colors.orangeAccent,
      Colors.purpleAccent,
      const Color(0xFF10B981),
      AppColors.error,
    ];
    final selectedColor = avatarColors[profile.avatarIndex % avatarColors.length];

    return InkWell(
      onTap: () => _showEditProfileSheet(context, ref, profile),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 32, 24, 24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            bottom: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [selectedColor.withValues(alpha: 0.7), selectedColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: selectedColor.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  )
                ]
              ),
              child: Container(
                margin: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(LucideIcons.user, size: 30, color: selectedColor),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name, 
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Versi Gratis', 
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Icon(LucideIcons.edit3, color: AppColors.textSecondary.withValues(alpha: 0.3), size: 18),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
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
      ),
    );
  }

  void _showEditProfileSheet(BuildContext context, WidgetRef ref, dynamic profile) {
    final nameController = TextEditingController(text: profile.name);
    int selectedAvatar = profile.avatarIndex;
    final List<Color> avatarColors = [
      AppColors.primary,
      Colors.orangeAccent,
      Colors.purpleAccent,
      const Color(0xFF10B981),
      AppColors.error,
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
                top: 24, left: 24, right: 24,
              ),
              decoration: BoxDecoration(
                color: AppColors.sheetBackground,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(color: AppColors.border),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, -4))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Personalisasi Profil',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 24),
                  const Text('Nama Kamu:', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Masukkan nama...',
                      hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.5)),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
                      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Warna Tema Profil:', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: avatarColors.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final color = entry.value;
                      return InkWell(
                        onTap: () => setDialogState(() => selectedAvatar = idx),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color.withValues(alpha: 0.15),
                            border: Border.all(
                              color: selectedAvatar == idx ? color : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Icon(LucideIcons.user, color: color, size: 18),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: avatarColors[selectedAvatar],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        if (nameController.text.trim().isNotEmpty) {
                          ref.read(profileProvider.notifier).updateName(nameController.text.trim());
                          ref.read(profileProvider.notifier).updateAvatar(selectedAvatar);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Profil diperbarui!'))
                          );
                        }
                      },
                      child: const Text('Simpan Perubahan', 
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
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
      splashColor: color.withValues(alpha: 0.08),
      highlightColor: color.withValues(alpha: 0.04),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: compact ? 12 : 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
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
                      color: AppColors.textPrimary,
                      fontSize: compact ? 14 : 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ]
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight, color: AppColors.textSecondary.withValues(alpha: 0.3), size: 16),
          ],
        ),
      ),
    );
  }
}

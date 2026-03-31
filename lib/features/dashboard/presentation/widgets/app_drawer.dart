import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:life_os_productivity/core/constants/app_colors.dart';
import 'package:life_os_productivity/features/gamification/presentation/providers/stats_provider.dart';
import 'package:life_os_productivity/features/gamification/domain/user_stats_model.dart';
import 'package:life_os_productivity/features/focus/presentation/pages/focus_page.dart';
import 'package:life_os_productivity/features/profile/presentation/providers/profile_provider.dart';
import 'package:life_os_productivity/features/settings/presentation/pages/settings_page.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

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
          const Divider(
              color: AppColors.border, thickness: 1, indent: 20, endIndent: 20),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              children: [
                _MenuItem(
                  icon: PhosphorIcons.timer(),
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
                  icon: PhosphorIcons.gear(),
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
                  icon: PhosphorIcons.crown(),
                  title: 'MyLife Premium',
                  subtitle: 'Buka fitur profesional mingguan',
                  color: AppColors.primary,
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Anda Sedang Pakai Versi Beta Maksimal!')),
                    );
                  },
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context, WidgetRef ref,
      UserStatsModel userStats, dynamic profile) {
    final List<Color> avatarColors = [
      const Color(0xFF6366F1), // Indigo
      const Color(0xFF10B981), // Emerald
      const Color(0xFF8B5CF6), // Grape
      const Color(0xFFF59E0B), // Amber
      const Color(0xFFF43F5E), // Rose
    ];
    final selectedColor =
        avatarColors[profile.avatarIndex % avatarColors.length];

    return InkWell(
      onLongPress: () => _pickCoverImage(context, ref),
      child: Stack(
        children: [
          // 1. Background Cover Image
          Container(
            height: 240,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                bottom: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            child: profile.coverImagePath != null
                ? Image.file(
                    File(profile.coverImagePath!),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.surface,
                            AppColors.border.withValues(alpha: 0.5)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.surface,
                          AppColors.border.withValues(alpha: 0.5)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
          ),

          // 2. Gradient Overlay for readability
          Container(
            height: 240,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.0),
                  Colors.black.withValues(alpha: 0.1),
                  Colors.black.withValues(alpha: 0.8),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 3. Edit Cover Button (Top Right)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 16,
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child:
                    Icon(PhosphorIcons.camera(), color: Colors.white, size: 18),
              ),
              onPressed: () => _pickCoverImage(context, ref),
            ),
          ),

          // 4. Content (Avatar + Text)
          Container(
            height: 240,
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Avatar dengan border putih bersih (Premium Look)
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                    gradient: LinearGradient(
                      colors: [
                        selectedColor.withValues(alpha: 0.8),
                        selectedColor
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: ClipOval(
                    child: profile.avatarPath != null
                        ? Image.file(
                            File(profile.avatarPath!),
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Center(
                              child: Icon(PhosphorIcons.user(),
                                  size: 28, color: Colors.white),
                            ),
                          )
                        : Center(
                            child: Icon(PhosphorIcons.user(),
                                size: 28, color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const Text(
                            'MyLife Pro Edition', // User wanted production polish, let's make them feel Pro
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(PhosphorIcons.pencilSimple(),
                          color: Colors.white70, size: 16),
                      onPressed: () =>
                          _showEditProfileSheet(context, ref, profile),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Streak Badge di atas gambar
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(PhosphorIcons.flame(),
                          color: Colors.orangeAccent, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        '${userStats.currentStreak} Hari Beruntun',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickCoverImage(BuildContext context, WidgetRef ref) async {
    if (await Permission.photos.request().isGranted ||
        await Permission.storage.request().isGranted) {
      final result = await FilePicker.platform
          .pickFiles(type: FileType.image, allowMultiple: false);
      if (result != null && result.files.single.path != null) {
        ref
            .read(profileProvider.notifier)
            .updateCoverImage(result.files.single.path);
      }
    }
  }

  void _showEditProfileSheet(
      BuildContext context, WidgetRef ref, dynamic profile) {
    final nameController = TextEditingController(text: profile.name);
    int selectedAvatar = profile.avatarIndex;
    String? tempAvatarPath = profile.avatarPath;
    String? tempCoverPath = profile.coverImagePath;

    final List<Color> avatarColors = [
      const Color(0xFF6366F1), // Indigo
      const Color(0xFF10B981), // Emerald
      const Color(0xFF8B5CF6), // Grape
      const Color(0xFFF59E0B), // Amber
      const Color(0xFFF43F5E), // Rose
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
                top: 24,
                left: 24,
                right: 24,
              ),
              decoration: BoxDecoration(
                color: AppColors.sheetBackground,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -4))
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Personalisasi Profil',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 24),
                    const Text('Nama Kamu:',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 13)),
                    TextField(
                      controller: nameController,
                      style: const TextStyle(
                          color: AppColors.textPrimary, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Masukkan nama...',
                        hintStyle: TextStyle(
                            color:
                                AppColors.textSecondary.withValues(alpha: 0.5)),
                        enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.border)),
                        focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.primary)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Warna Tema Profil:',
                        style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: avatarColors.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final color = entry.value;
                        final isSelected = selectedAvatar == idx;
                        return InkWell(
                          onTap: () =>
                              setDialogState(() => selectedAvatar = idx),
                          borderRadius: BorderRadius.circular(30),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            width: isSelected ? 50 : 44,
                            height: isSelected ? 50 : 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected ? color : color.withValues(alpha: 0.1),
                              border: Border.all(
                                color: isSelected ? color : AppColors.border.withValues(alpha: 0.5),
                                width: isSelected ? 3 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected ? color.withValues(alpha: 0.4) : Colors.transparent,
                                  blurRadius: isSelected ? 12 : 0,
                                  spreadRadius: isSelected ? 1 : 0,
                                )
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                isSelected ? PhosphorIcons.check() : PhosphorIcons.paintBrush(),
                                color: isSelected ? Colors.white : color,
                                size: isSelected ? 20 : 18,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () async {
                        if (await Permission.photos.request().isGranted ||
                            await Permission.storage.request().isGranted) {
                          final result = await FilePicker.platform.pickFiles(
                              type: FileType.image, allowMultiple: false);
                          if (result != null &&
                              result.files.single.path != null) {
                            setDialogState(() =>
                                tempAvatarPath = result.files.single.path);
                          }
                        } else {
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                                const SnackBar(
                                    content: Text('Izin galeri diperlukan.')));
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color:
                              AppColors.textSecondary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            if (tempAvatarPath != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(File(tempAvatarPath!),
                                    width: 32, height: 32, fit: BoxFit.cover),
                              )
                            else
                              Icon(PhosphorIcons.userCircle(),
                                  color: AppColors.textPrimary, size: 20),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text('Ubah Foto Profil',
                                  style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500)),
                            ),
                            if (tempAvatarPath != null)
                              const Icon(Icons.check_circle,
                                  color: Colors.green, size: 16),
                            const SizedBox(width: 8),
                            Icon(PhosphorIcons.caretRight(),
                                color: AppColors.textSecondary, size: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Latar Belakang Sidebar:',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 13)),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () async {
                        if (await Permission.photos.request().isGranted ||
                            await Permission.storage.request().isGranted) {
                          final result = await FilePicker.platform.pickFiles(
                              type: FileType.image, allowMultiple: false);
                          if (result != null &&
                              result.files.single.path != null) {
                            setDialogState(
                                () => tempCoverPath = result.files.single.path);
                          }
                        } else {
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                                const SnackBar(
                                    content: Text('Izin galeri diperlukan.')));
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color:
                              AppColors.textSecondary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            if (tempCoverPath != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(File(tempCoverPath!),
                                    width: 32, height: 32, fit: BoxFit.cover),
                              )
                            else
                              Icon(PhosphorIcons.image(),
                                  color: AppColors.textPrimary, size: 20),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text('Ubah Foto Latar Belakang',
                                  style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500)),
                            ),
                            if (tempCoverPath != null)
                              const Icon(Icons.check_circle,
                                  color: Colors.green, size: 16),
                            const SizedBox(width: 8),
                            Icon(PhosphorIcons.caretRight(),
                                color: AppColors.textSecondary, size: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: avatarColors[selectedAvatar],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          final name = nameController.text.trim();
                          if (name.isNotEmpty) {
                            final notifier = ref.read(profileProvider.notifier);
                            notifier.updateName(name);
                            notifier.updateAvatar(selectedAvatar);
                            notifier.updateAvatarPath(tempAvatarPath);
                            notifier.updateCoverImage(tempCoverPath);

                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Profil diperbarui!')));
                          } else {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                                const SnackBar(
                                    content: Text('Nama tidak boleh kosong')));
                          }
                        },
                        child: const Text('Simpan Perubahan',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                    const SizedBox(
                        height:
                            40), // Extra space to ensure button is above system nav or keyboard
                  ],
                ),
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

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      splashColor: color.withValues(alpha: 0.08),
      highlightColor: color.withValues(alpha: 0.04),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
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
            Icon(PhosphorIcons.caretRight(),
                color: AppColors.textSecondary.withValues(alpha: 0.3),
                size: 16),
          ],
        ),
      ),
    );
  }
}

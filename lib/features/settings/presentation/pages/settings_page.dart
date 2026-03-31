import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:life_os_productivity/core/constants/app_colors.dart';
import 'package:life_os_productivity/features/profile/presentation/providers/profile_provider.dart';
import 'package:hive/hive.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Pengaturan', 
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)
        ),
        leading: IconButton(
          icon: Icon(PhosphorIcons.caretLeft(), color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          _buildSectionHeader('Preferensi & Notifikasi'),
          _buildSettingsTile(
            icon: PhosphorIcons.bell(),
            title: 'Notifikasi Harian',
            subtitle: 'Ingatkan saya untuk aktivitas planner',
            trailing: Switch.adaptive(
              value: profile.notificationsEnabled,
              activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
              activeThumbColor: AppColors.primary,
              onChanged: (val) {
                ref.read(profileProvider.notifier).updateNotifications(val);
              },
            ),
          ),
          _buildSettingsTile(
            icon: PhosphorIcons.clock(),
            title: 'Format Waktu',
            subtitle: 'Format 24 Jam (Standar Indonesia)',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Aktif', style: TextStyle(color: AppColors.secondary, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Data & Keamanan'),
          _buildSettingsTile(
            icon: PhosphorIcons.shieldCheck(),
            title: 'Cadangkan Data',
            subtitle: 'Simpan data ke penyimpanan lokal',
            onTap: () {
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur Backup Segera Hadir!'))
              );
            },
          ),
          _buildSettingsTile(
            icon: PhosphorIcons.trash(),
            title: 'Hapus Seluruh Data',
            subtitle: 'Reset aplikasi ke kondisi awal',
            color: AppColors.error,
            onTap: () => _confirmReset(context),
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Info Aplikasi'),
          _buildSettingsTile(
            icon: PhosphorIcons.info(),
            title: 'Versi Aplikasi',
            subtitle: '1.0.0 (Beta Maksimal)',
          ),
          _buildSettingsTile(
            icon: PhosphorIcons.star(),
            title: 'Nilai MyLife OS',
            subtitle: 'Dukung kami berkembang lebih jauh',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    Color color = AppColors.textSecondary,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: AppColors.cardShadow.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        title: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        trailing: trailing ?? (onTap != null ? Icon(PhosphorIcons.caretRight(), color: AppColors.textSecondary.withValues(alpha: 0.3), size: 16) : null),
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Hapus Semua Data?', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'Tindakan ini akan menghapus seluruh isi Planner, Habits, dan Profil Anda secara permanen. Lanjutkan?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(ctx);
              final messenger = ScaffoldMessenger.of(context);
              await Hive.deleteFromDisk();
              navigator.pop();
              messenger.showSnackBar(
                const SnackBar(content: Text('Data Dihapus. Mohon muat ulang aplikasi.'))
              );
            },
            child: const Text('Reset Sekarang', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

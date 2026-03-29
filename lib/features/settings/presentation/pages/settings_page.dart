import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
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
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)
        ),
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          _buildSectionHeader('Preferensi & Notifikasi'),
          _buildSettingsTile(
            icon: LucideIcons.bell,
            title: 'Notifikasi Harian',
            subtitle: 'Ingatkan saya untuk aktivitas planner',
            trailing: Switch.adaptive(
              value: profile.notificationsEnabled,
              activeColor: AppColors.primary,
              onChanged: (val) {
                ref.read(profileProvider.notifier).updateNotifications(val);
              },
            ),
          ),
          _buildSettingsTile(
            icon: LucideIcons.clock,
            title: 'Format Waktu',
            subtitle: 'Format 24 Jam (Standar Indonesia)',
            trailing: const Text('Aktif', style: TextStyle(color: Colors.white38, fontSize: 12)),
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Data & Keamanan'),
          _buildSettingsTile(
            icon: LucideIcons.shieldCheck,
            title: 'Cadangkan Data',
            subtitle: 'Simpan data ke penyimpanan lokal',
            onTap: () {
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur Backup Segera Hadir!'))
              );
            },
          ),
          _buildSettingsTile(
            icon: LucideIcons.trash2,
            title: 'Hapus Seluruh Data',
            subtitle: 'Reset aplikasi ke kondisi awal',
            color: Colors.redAccent,
            onTap: () => _confirmReset(context),
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader('Info Aplikasi'),
          _buildSettingsTile(
            icon: LucideIcons.info,
            title: 'Versi Aplikasi',
            subtitle: '1.0.0 (Beta Maksimal)',
          ),
          _buildSettingsTile(
            icon: LucideIcons.star,
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
          color: Colors.white38,
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
    Color color = Colors.white70,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
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
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 11)),
        trailing: trailing ?? (onTap != null ? const Icon(LucideIcons.chevronRight, color: Colors.white12, size: 16) : null),
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Hapus Semua Data?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Tindakan ini akan menghapus seluruh isi Planner, Habits, dan Profil Anda secara permanen. Lanjutkan?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () async {
              await Hive.deleteFromDisk();
              Navigator.pop(ctx);
              // Restart logic app usually here (or tell user to restart)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data Dihapus. Mohon muat ulang aplikasi.'))
              );
            },
            child: const Text('Reset Sekarang', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

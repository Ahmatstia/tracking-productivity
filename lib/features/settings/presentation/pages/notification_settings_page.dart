import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:life_os_productivity/core/constants/app_colors.dart';
import 'package:life_os_productivity/features/profile/presentation/providers/profile_provider.dart';

class NotificationSettingsPage extends ConsumerWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Pusat Notifikasi', 
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
          _buildInfoCard(),
          const SizedBox(height: 24),
          
          _buildSectionHeader('Sistem & Suara'),
          _buildNotificationTile(
            icon: PhosphorIcons.bellRinging(),
            title: 'Notifikasi Utama',
            subtitle: 'Aktifkan atau nonaktifkan seluruh pengingat aktif',
            value: profile.notificationsEnabled,
            onChanged: (val) => ref.read(profileProvider.notifier).updateNotifications(val),
          ),
          _buildNotificationTile(
            icon: PhosphorIcons.speakerHigh(),
            title: 'Efek Suara',
            subtitle: 'Mainkan suara saat notifikasi muncul',
            value: profile.soundsEnabled,
            enabled: profile.notificationsEnabled,
            onChanged: (val) => ref.read(profileProvider.notifier).updateSounds(val),
          ),

          const SizedBox(height: 24),
          _buildSectionHeader('Manajemen Jadwal'),
          _buildNotificationTile(
            icon: PhosphorIcons.calendarCheck(),
            title: 'Pengingat Planner',
            subtitle: 'Notifikasi 5 menit sebelum aktivitas dimulai',
            value: profile.plannerReminders,
            enabled: profile.notificationsEnabled,
            onChanged: (val) => ref.read(profileProvider.notifier).updatePlannerReminders(val),
          ),

          const SizedBox(height: 24),
          _buildSectionHeader('Rutinitas & Kebiasaan'),
          _buildNotificationTile(
            icon: PhosphorIcons.arrowsClockwise(),
            title: 'Saran Kebiasaan',
            subtitle: 'Pengingat harian untuk aktivitas rutin Anda',
            value: profile.habitReminders,
            enabled: profile.notificationsEnabled,
            onChanged: (val) => ref.read(profileProvider.notifier).updateHabitReminders(val),
          ),

          const SizedBox(height: 24),
          _buildSectionHeader('Target & Fokus'),
          _buildNotificationTile(
            icon: PhosphorIcons.target(),
            title: 'Tenggat Waktu Goal',
            subtitle: 'Notifikasi saat target mendekati deadline',
            value: profile.goalReminders,
            enabled: profile.notificationsEnabled,
            onChanged: (val) => ref.read(profileProvider.notifier).updateGoalReminders(val),
          ),
          _buildNotificationTile(
            icon: PhosphorIcons.timer(),
            title: 'Sesi Fokus',
            subtitle: 'Alert saat sesi Pomodoro atau Fokus berakhir',
            value: profile.focusAlerts,
            enabled: profile.notificationsEnabled,
            onChanged: (val) => ref.read(profileProvider.notifier).updateFocusAlerts(val),
          ),
          
          const SizedBox(height: 40),
          Center(
            child: Text(
              'Kelola dengan bijak untuk menjaga fokus harianmu.',
              style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.5), fontSize: 11, fontStyle: FontStyle.italic),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.textPrimary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(PhosphorIcons.info(), color: AppColors.textPrimary, size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Atur notifikasi agar Anda tetap terhubung dengan target tanpa merasa terganggu.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildNotificationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
  }) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: enabled ? 1.0 : 0.4,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.textPrimary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.textPrimary, size: 20),
          ),
          title: Text(title, 
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.bold)
          ),
          subtitle: Text(subtitle, 
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)
          ),
          trailing: Switch.adaptive(
            value: value,
            activeTrackColor: AppColors.textPrimary.withValues(alpha: 0.3),
            activeThumbColor: AppColors.textPrimary,
            onChanged: enabled ? onChanged : null,
          ),
        ),
      ),
    );
  }
}

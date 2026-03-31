import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:life_os_productivity/core/constants/app_colors.dart';
import 'package:life_os_productivity/features/profile/presentation/providers/profile_provider.dart';
import 'dart:io';

class NotificationSettingsPage extends ConsumerStatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  ConsumerState<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends ConsumerState<NotificationSettingsPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _playingPath;
  Timer? _previewTimer;

  @override
  void dispose() {
    _previewTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _pickAndPreviewSound(String category, String? currentPath) async {
    // 1. Pick File
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      final newPath = result.files.single.path!;
      
      // 2. Play Preview (5-10 seconds as standard)
      await _playPreview(newPath);

      // 3. Save to Profile
      final notifier = ref.read(profileProvider.notifier);
      switch (category) {
        case 'global': notifier.updateGlobalSound(newPath); break;
        case 'planner': notifier.updatePlannerSound(newPath); break;
        case 'habit': notifier.updateHabitSound(newPath); break;
        case 'focus': notifier.updateFocusSound(newPath); break;
      }
    }
  }

  Future<void> _playPreview(String path) async {
    try {
      _previewTimer?.cancel();
      await _audioPlayer.stop();
      
      setState(() {
        _playingPath = path;
      });

      await _audioPlayer.play(DeviceFileSource(path));
      
      // Stop after 8 seconds (common middle ground)
      _previewTimer = Timer(const Duration(seconds: 8), () async {
        await _audioPlayer.stop();
        if (mounted) {
          setState(() {
            _playingPath = null;
          });
        }
      });
    } catch (e) {
      debugPrint('Error playing preview: $e');
    }
  }

  void _stopPreview() async {
    await _audioPlayer.stop();
    _previewTimer?.cancel();
    setState(() {
      _playingPath = null;
    });
  }

  @override
  Widget build(BuildContext context) {
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

          if (profile.soundsEnabled && profile.notificationsEnabled) ...[
            const SizedBox(height: 24),
            _buildSectionHeader('Estetika Suara (Hybrid)'),
            _buildSoundPickerTile(
              category: 'global',
              title: 'Suara Utama (Global)',
              subtitle: 'Suara default untuk semua kategori',
              path: profile.globalSoundPath,
              onReset: () => ref.read(profileProvider.notifier).updateGlobalSound(null),
            ),
            _buildSoundPickerTile(
              category: 'planner',
              title: 'Suara Planner',
              subtitle: 'Musik kustom khusus jadwal harian',
              path: profile.plannerSoundPath,
              onReset: () => ref.read(profileProvider.notifier).updatePlannerSound(null),
            ),
            _buildSoundPickerTile(
              category: 'habit',
              title: 'Suara Kebiasaan',
              subtitle: 'Musik kustom khusus rutinitas',
              path: profile.habitSoundPath,
              onReset: () => ref.read(profileProvider.notifier).updateHabitSound(null),
            ),
          ],

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

  Widget _buildSoundPickerTile({
    required String category,
    required String title,
    required String subtitle,
    required String? path,
    required VoidCallback onReset,
  }) {
    final fileName = path != null ? path.split(Platform.pathSeparator).last : 'Default Sistem';
    final isPlaying = _playingPath == path && path != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
        subtitle: Text(fileName, style: TextStyle(color: path != null ? AppColors.primary : AppColors.textSecondary, fontSize: 11)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (path != null)
              IconButton(
                icon: Icon(isPlaying ? PhosphorIcons.stopCircle() : PhosphorIcons.playCircle(), 
                  color: isPlaying ? AppColors.error : AppColors.textPrimary, size: 24),
                onPressed: isPlaying ? _stopPreview : () => _playPreview(path),
              ),
            IconButton(
              icon: Icon(path == null ? PhosphorIcons.musicNotesPlus() : PhosphorIcons.arrowsClockwise(), color: AppColors.textPrimary),
              onPressed: () => _pickAndPreviewSound(category, path),
            ),
            if (path != null)
              IconButton(
                icon: Icon(PhosphorIcons.trash(), color: AppColors.error.withValues(alpha: 0.7), size: 20),
                onPressed: onReset,
              ),
          ],
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
        ),
        child: ListTile(
          leading: Icon(icon, color: AppColors.textPrimary, size: 20),
          title: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
          subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:life_os_productivity/core/constants/app_colors.dart';
import 'package:life_os_productivity/features/analytics/domain/daily_review_model.dart';
import 'package:life_os_productivity/features/analytics/presentation/providers/analytics_provider.dart';
import 'package:life_os_productivity/features/tasks/domain/task_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DailyReviewPage extends ConsumerStatefulWidget {
  const DailyReviewPage({super.key});

  @override
  ConsumerState<DailyReviewPage> createState() => _DailyReviewPageState();
}

class _DailyReviewPageState extends ConsumerState<DailyReviewPage> {
  int _mood = 3;
  final _wentWellCtrl = TextEditingController();
  final _improveCtrl = TextEditingController();
  bool _isSaving = false;

  final _moodEmojis = ['😫', '😐', '🙂', '😊', '🔥'];
  final _moodLabels = ['Berat', 'Biasa', 'Oke', 'Bagus', 'Luar Biasa!'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final existing = ref.read(dailyReviewProvider);
      if (existing != null) {
        setState(() => _mood = existing.moodRating);
        _wentWellCtrl.text = existing.whatWentWell;
        _improveCtrl.text = existing.whatToImprove;
      }
    });
  }

  @override
  void dispose() {
    _wentWellCtrl.dispose();
    _improveCtrl.dispose();
    super.dispose();
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Selamat Pagi ☀️';
    if (h < 17) return 'Selamat Siang 🌤️';
    if (h < 20) return 'Selamat Sore 🌅';
    return 'Selamat Malam 🌙';
  }

  bool get _isMorning => DateTime.now().hour < 12;

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final taskBox = Hive.box<TaskModel>('tasks_box');
    final today = DateTime.now();
    final todayTasks = taskBox.values.where((t) =>
        t.date.year == today.year &&
        t.date.month == today.month &&
        t.date.day == today.day).toList();
    final completed = todayTasks.where((t) => t.isCompleted).length;

    final review = DailyReviewModel(
      id: '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}',
      date: today,
      moodRating: _mood,
      whatWentWell: _wentWellCtrl.text,
      whatToImprove: _improveCtrl.text,
      tasksCompleted: completed,
      totalTasks: todayTasks.length,
    );

    await ref.read(dailyReviewProvider.notifier).saveReview(review);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Review tersimpan! ✅'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context);
    }
    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isMorning ? 'Briefing Pagi ☀️' : 'Review Malam 🌙',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Greeting ─────────────────────────────
            Text(_greeting(),
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                )),
            const SizedBox(height: 4),
            Text(
              _isMorning
                  ? 'Bagaimana kondisimu hari ini?'
                  : 'Bagaimana harimu hari ini?',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 28),

            // ── Today's Task Preview ─────────────────
            _TodayTaskPreview(),
            const SizedBox(height: 28),

            // ── Mood Selector ────────────────────────
            Text('Bagaimana mood-mu?',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(5, (i) {
                final selected = _mood == i + 1;
                return GestureDetector(
                  onTap: () => setState(() => _mood = i + 1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected ? AppColors.primary : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(_moodEmojis[i],
                            style: TextStyle(fontSize: selected ? 30 : 24)),
                        const SizedBox(height: 4),
                        Text(_moodLabels[i],
                            style: TextStyle(
                              color: selected ? AppColors.primary : AppColors.textSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            )),
                      ],
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 28),

            // ── What Went Well ───────────────────────
            _InputSection(
              icon: LucideIcons.thumbsUp,
              title: 'Apa yang berjalan baik?',
              hint: 'Tulis 1-3 hal positif hari ini...',
              controller: _wentWellCtrl,
              color: Colors.green,
            ),
            const SizedBox(height: 16),

            // ── What to Improve ──────────────────────
            _InputSection(
              icon: LucideIcons.trendingUp,
              title: 'Apa yang bisa lebih baik?',
              hint: 'Refleksi jujur untuk besok...',
              controller: _improveCtrl,
              color: Colors.orange,
            ),
            const SizedBox(height: 32),

            // ── Save Button ──────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    : Text(
                        'Simpan Review ✅',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _TodayTaskPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final taskBox = Hive.box<TaskModel>('tasks_box');
    final today = DateTime.now();
    final todayTasks = taskBox.values.where((t) =>
        t.date.year == today.year &&
        t.date.month == today.month &&
        t.date.day == today.day).toList();
    final completed = todayTasks.where((t) => t.isCompleted).length;
    final total = todayTasks.length;
    final pct = total == 0 ? 0.0 : completed / total;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.clipboardCheck, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text('Progress Hari Ini',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  )),
              const Spacer(),
              Text('$completed/$total task',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            pct == 1.0
                ? '🎉 Semua task selesai! Luar biasa!'
                : total == 0
                    ? '📋 Belum ada task hari ini'
                    : '💪 ${(pct * 100).round()}% selesai, terus semangat!',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _InputSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String hint;
  final TextEditingController controller;
  final Color color;

  const _InputSection({
    required this.icon,
    required this.title,
    required this.hint,
    required this.controller,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(title,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                )),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          maxLines: 3,
          style: TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: color.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: color, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: color.withValues(alpha: 0.2)),
            ),
          ),
        ),
      ],
    );
  }
}

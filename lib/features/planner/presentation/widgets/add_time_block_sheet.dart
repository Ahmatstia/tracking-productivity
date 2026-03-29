import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:life_os_productivity/core/constants/app_colors.dart';
import 'package:life_os_productivity/features/planner/domain/time_block_model.dart';
import 'package:life_os_productivity/features/planner/presentation/providers/time_block_provider.dart';
import 'package:life_os_productivity/features/planner/presentation/providers/habit_pattern_provider.dart';

class AddTimeBlockSheet extends ConsumerStatefulWidget {
  final DateTime date;
  final String? initialStartTime;
  final TimeBlockModel? editBlock; // if editing existing

  const AddTimeBlockSheet({
    super.key,
    required this.date,
    this.initialStartTime,
    this.editBlock,
  });

  @override
  ConsumerState<AddTimeBlockSheet> createState() => _AddTimeBlockSheetState();
}

class _AddTimeBlockSheetState extends ConsumerState<AddTimeBlockSheet> {
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  String _selectedCategory = 'personal';
  String _startTime = '08:00';
  String _endTime = '09:00';
  bool _saveAsHabit = false;

  static const _categories = [
    {'key': 'work', 'label': 'Kerja', 'icon': LucideIcons.briefcase, 'color': Color(0xFF007BFF)},
    {'key': 'health', 'label': 'Kesehatan', 'icon': LucideIcons.heartPulse, 'color': Color(0xFFFF6B6B)},
    {'key': 'learning', 'label': 'Belajar', 'icon': LucideIcons.bookOpen, 'color': Color(0xFFFFD93D)},
    {'key': 'personal', 'label': 'Personal', 'icon': LucideIcons.smile, 'color': Color(0xFF00D084)},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.editBlock != null) {
      final b = widget.editBlock!;
      _titleController.text = b.title;
      _noteController.text = b.note ?? '';
      _selectedCategory = b.category;
      _startTime = b.startTime;
      _endTime = b.endTime;
    } else if (widget.initialStartTime != null) {
      _startTime = widget.initialStartTime!;
      final parts = _startTime.split(':');
      final startHr = int.parse(parts[0]);
      _endTime = '${(startHr + 1).toString().padLeft(2, '0')}:${parts[1]}';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickTime(bool isStart) async {
    final parts = (isStart ? _startTime : _endTime).split(':');
    final initial = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      final formatted =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() {
        if (isStart) {
          _startTime = formatted;
        } else {
          _endTime = formatted;
        }
      });
    }
  }

  Color _categoryColor(String key) {
    return (_categories.firstWhere((c) => c['key'] == key,
          orElse: () => _categories.last)['color'] as Color);
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama aktivitas tidak boleh kosong!')),
      );
      return;
    }

    final startMins = int.parse(_startTime.split(':')[0]) * 60 + int.parse(_startTime.split(':')[1]);
    final endMins = int.parse(_endTime.split(':')[0]) * 60 + int.parse(_endTime.split(':')[1]);
    
    if (endMins <= startMins) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Waktu selesai harus sesudah waktu mulai!')),
      );
      return;
    }

    if (widget.editBlock != null) {
      final updated = widget.editBlock!
        ..title = title
        ..startTime = _startTime
        ..endTime = _endTime
        ..category = _selectedCategory
        ..note = _noteController.text.trim().isEmpty ? null : _noteController.text.trim();
      ref.read(timeBlockProvider.notifier).updateBlock(updated);
    } else {
      ref.read(timeBlockProvider.notifier).addBlock(
            title: title,
            startTime: _startTime,
            endTime: _endTime,
            category: _selectedCategory,
            date: widget.date,
            note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
          );

      if (_saveAsHabit) {
        ref.read(habitPatternProvider.notifier).addPattern(
              title: title,
              startTime: _startTime,
              endTime: _endTime,
              category: _selectedCategory,
            );
      }
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editBlock != null;
    final catColor = _categoryColor(_selectedCategory);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Text(
              isEditing ? 'Edit Aktivitas' : 'Tambah Aktivitas',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            // Title Input
            TextField(
              controller: _titleController,
              autofocus: !isEditing,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Nama aktivitas...',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: Icon(LucideIcons.pencil, color: catColor, size: 18),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.06),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: catColor, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Time pickers row
            Row(
              children: [
                Expanded(child: _TimePicker(label: 'Mulai', time: _startTime, onTap: () => _pickTime(true))),
                const SizedBox(width: 12),
                const Icon(LucideIcons.arrowRight, color: Colors.white38, size: 18),
                const SizedBox(width: 12),
                Expanded(child: _TimePicker(label: 'Selesai', time: _endTime, onTap: () => _pickTime(false))),
              ],
            ),
            const SizedBox(height: 16),

            // Category chips
            const Text('Kategori', style: TextStyle(color: Colors.white60, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat['key'];
                final color = cat['color'] as Color;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat['key'] as String),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? color.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? color : Colors.white12,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(cat['icon'] as IconData, size: 14, color: isSelected ? color : Colors.white38),
                        const SizedBox(width: 6),
                        Text(
                          cat['label'] as String,
                          style: TextStyle(
                            color: isSelected ? color : Colors.white54,
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Note input
            TextField(
              controller: _noteController,
              maxLines: 2,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Catatan (opsional)...',
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.04),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Save as habit toggle
            if (!isEditing)
              GestureDetector(
                onTap: () => setState(() => _saveAsHabit = !_saveAsHabit),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: _saveAsHabit
                        ? AppColors.secondary.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _saveAsHabit ? AppColors.secondary.withValues(alpha: 0.5) : Colors.white12,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _saveAsHabit ? LucideIcons.repeat2 : LucideIcons.repeat,
                        color: _saveAsHabit ? AppColors.secondary : Colors.white38,
                        size: 18,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Jadikan Kebiasaan',
                              style: TextStyle(
                                color: _saveAsHabit ? AppColors.secondary : Colors.white54,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const Text(
                              'Besok akan otomatis ter-generate',
                              style: TextStyle(color: Colors.white38, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _saveAsHabit ? AppColors.secondary : Colors.transparent,
                          border: Border.all(
                            color: _saveAsHabit ? AppColors.secondary : Colors.white24,
                            width: 2,
                          ),
                        ),
                        child: _saveAsHabit
                            ? const Icon(Icons.check, size: 14, color: Colors.black)
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: catColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: Text(
                  isEditing ? 'Simpan Perubahan' : 'Tambah ke Jadwal',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimePicker extends StatelessWidget {
  final String label;
  final String time;
  final VoidCallback onTap;

  const _TimePicker({required this.label, required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(LucideIcons.clock, size: 14, color: Colors.white54),
                const SizedBox(width: 6),
                Text(
                  time,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

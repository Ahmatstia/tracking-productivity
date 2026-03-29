import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:life_os_productivity/core/constants/app_colors.dart';
import 'package:life_os_productivity/features/routines/presentation/providers/routine_provider.dart';
import 'package:life_os_productivity/features/routines/domain/routine_template_model.dart';

class AddRoutineSheet extends ConsumerStatefulWidget {
  const AddRoutineSheet({super.key});

  @override
  ConsumerState<AddRoutineSheet> createState() => _AddRoutineSheetState();
}

class _AddRoutineSheetState extends ConsumerState<AddRoutineSheet> {
  final _nameController = TextEditingController();
  final List<RoutineBlockModel> _blocks = [];
  int _selectedColor = 0xFF00D084; // Default Neon Green

  static const _colors = [
    0xFF007BFF, // Blue
    0xFFFF6B6B, // Red
    0xFFFFD93D, // Yellow
    0xFF00D084, // Green
    0xFFA100FF, // Purple
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _showAddBlockDialog([int? editIndex]) async {
    final titleCtrl = TextEditingController();
    TimeOfDay? startT;
    TimeOfDay? endT;

    if (editIndex != null) {
      final b = _blocks[editIndex];
      titleCtrl.text = b.title;
      final st = b.startTime.split(':');
      final et = b.endTime.split(':');
      startT = TimeOfDay(hour: int.parse(st[0]), minute: int.parse(st[1]));
      endT = TimeOfDay(hour: int.parse(et[0]), minute: int.parse(et[1]));
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            Future<void> pickTime(bool isStart) async {
              final picked = await showTimePicker(
                context: ctx,
                initialTime: (isStart ? startT : endT) ?? TimeOfDay.now(),
                builder: (context, child) {
                  return MediaQuery(
                    data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                setDialogState(() {
                  if (isStart) startT = picked;
                  else endT = picked;
                });
              }
            }

            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
                top: 24, left: 20, right: 20,
              ),
              decoration: BoxDecoration(
                color: AppColors.sheetBackground,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, -4))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(editIndex == null ? 'Tambah Aktivitas' : 'Edit Aktivitas',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleCtrl,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Nama (mis: Baca Buku, Olahraga)',
                      hintStyle: const TextStyle(color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.inputFill,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => pickTime(true),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                            child: Row(
                              children: [
                                const Icon(LucideIcons.clock, color: AppColors.textSecondary, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  startT != null ? '${startT!.hour.toString().padLeft(2, '0')}:${startT!.minute.toString().padLeft(2, '0')}' : 'Jam Mulai',
                                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => pickTime(false),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                            child: Row(
                              children: [
                                const Icon(LucideIcons.clock, color: AppColors.textSecondary, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  endT != null ? '${endT!.hour.toString().padLeft(2, '0')}:${endT!.minute.toString().padLeft(2, '0')}' : 'Jam Selesai',
                                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        if (titleCtrl.text.isEmpty || startT == null || endT == null) {
                          ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Nama dan jam harus diisi lengkap!')));
                          return;
                        }
                        final startStr = '${startT!.hour.toString().padLeft(2, '0')}:${startT!.minute.toString().padLeft(2, '0')}';
                        final endStr = '${endT!.hour.toString().padLeft(2, '0')}:${endT!.minute.toString().padLeft(2, '0')}';
                        
                        // Validasi waktu terbalik
                        if ((startT!.hour * 60 + startT!.minute) >= (endT!.hour * 60 + endT!.minute)) {
                           ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Jam selesai harus lebih besar dari jam mulai!')));
                           return;
                        }

                        setState(() {
                          final block = RoutineBlockModel(
                            title: titleCtrl.text,
                            startTime: startStr,
                            endTime: endStr,
                            category: 'personal',
                          );
                          if (editIndex != null) {
                            _blocks[editIndex] = block;
                          } else {
                            _blocks.add(block);
                          }
                          // Sort the blocks by start time automatically
                          _blocks.sort((a, b) => a.startTime.compareTo(b.startTime));
                        });
                        Navigator.pop(ctx);
                      },
                      child: const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  void _save() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama rutinitas tidak boleh kosong!')));
      return;
    }
    if (_blocks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tambahkan minimal 1 aktivitas!')));
      return;
    }

    ref.read(routineProvider.notifier).addRoutine(
      name: _nameController.text,
      blocks: _blocks,
      colorCode: _selectedColor,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: AppColors.sheetBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, -4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const Text(
            'Buat Template Rutinitas',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Nama Rutinitas (mis: Morning Routine)',
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.inputFill,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: _colors.map((color) => GestureDetector(
              onTap: () => setState(() => _selectedColor = color),
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Color(color),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _selectedColor == color ? Colors.white : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Daftar Aktivitas:', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
              TextButton.icon(
                onPressed: () => _showAddBlockDialog(),
                icon: const Icon(LucideIcons.plus, size: 16),
                label: const Text('Tambah'),
              )
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _blocks.length,
              itemBuilder: (context, index) {
                final b = _blocks[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(LucideIcons.clock, color: AppColors.textSecondary),
                  title: Text(b.title, style: const TextStyle(color: AppColors.textPrimary)),
                  subtitle: Text('${b.startTime} - ${b.endTime}', style: const TextStyle(color: AppColors.textSecondary)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(LucideIcons.edit2, color: AppColors.textSecondary.withValues(alpha: 0.5), size: 16),
                        onPressed: () => _showAddBlockDialog(index),
                      ),
                      IconButton(
                        icon: Icon(LucideIcons.trash2, color: AppColors.error.withValues(alpha: 0.6), size: 16),
                        onPressed: () => setState(() => _blocks.removeAt(index)),
                      ),
                    ],
                  ),
                  onTap: () => _showAddBlockDialog(index),
                );
              },
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(_selectedColor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Simpan Template', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}

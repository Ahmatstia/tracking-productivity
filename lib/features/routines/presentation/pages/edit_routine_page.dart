import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:life_os_productivity/core/constants/app_colors.dart';
import 'package:life_os_productivity/features/routines/presentation/providers/routine_provider.dart';
import 'package:life_os_productivity/features/routines/domain/routine_template_model.dart';

class EditRoutinePage extends ConsumerStatefulWidget {
  final RoutineTemplateModel? existingRoutine;

  const EditRoutinePage({super.key, this.existingRoutine});

  @override
  ConsumerState<EditRoutinePage> createState() => _EditRoutinePageState();
}

class _EditRoutinePageState extends ConsumerState<EditRoutinePage> {
  late final TextEditingController _nameController;
  late List<RoutineBlockModel> _blocks;
  late int _selectedColor;
  late List<int> _assignedDays;

  static const _colors = [
    0xFF007BFF, // Blue
    0xFFFF6B6B, // Red
    0xFFFFD93D, // Yellow
    0xFF00D084, // Green
    0xFFA100FF, // Purple
  ];

  static const _days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existingRoutine?.name ?? '');
    
    // Kita harus buat salinan mendalam (deep copy) dari daftar blok agar tidak terganggu saat dibatalkan (Cancel)
    _blocks = widget.existingRoutine?.blocks.map((b) => RoutineBlockModel(
      title: b.title,
      startTime: b.startTime,
      endTime: b.endTime,
      category: b.category,
    )).toList() ?? [];

    _selectedColor = widget.existingRoutine?.colorCode ?? 0xFF00D084;
    _assignedDays = List.from(widget.existingRoutine?.assignedDays ?? []);
  }

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

            return ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              child: BackdropFilter(
                filter: ColorFilter.mode(Colors.black.withValues(alpha: 0.2), BlendMode.darken),
                child: Container(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
                    top: 24, left: 24, right: 24,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E).withValues(alpha: 0.95),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(editIndex == null ? 'Tambah Aktivitas' : 'Edit Aktivitas',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                          IconButton(
                            icon: const Icon(LucideIcons.x, color: Colors.white38, size: 20),
                            onPressed: () => Navigator.pop(ctx),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: titleCtrl,
                        autofocus: true,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'Nama Aktivitas',
                          hintStyle: const TextStyle(color: Colors.white24),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _TimePickerButton(
                              label: 'Mulai',
                              time: startT,
                              onTap: () => pickTime(true),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _TimePickerButton(
                              label: 'Selesai',
                              time: endT,
                              onTap: () => pickTime(false),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(_selectedColor),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          onPressed: () {
                            // ... logic same ...
                            if (titleCtrl.text.trim().isEmpty || startT == null || endT == null) {
                              ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Nama dan jam harus diisi lengkap!')));
                              return;
                            }
                            final startStr = '${startT!.hour.toString().padLeft(2, '0')}:${startT!.minute.toString().padLeft(2, '0')}';
                            final endStr = '${endT!.hour.toString().padLeft(2, '0')}:${endT!.minute.toString().padLeft(2, '0')}';
                            
                            if ((startT!.hour * 60 + startT!.minute) >= (endT!.hour * 60 + endT!.minute)) {
                               ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Jam selesai harus lebih besar dari jam mulai!')));
                               return;
                            }

                            setState(() {
                              final block = RoutineBlockModel(
                                title: titleCtrl.text.trim(),
                                startTime: startStr,
                                endTime: endStr,
                                category: 'personal',
                              );
                              if (editIndex != null) {
                                _blocks[editIndex] = block;
                              } else {
                                _blocks.add(block);
                              }
                              _blocks.sort((a, b) => a.startTime.compareTo(b.startTime));
                            });
                            Navigator.pop(ctx);
                          },
                          child: const Text('Simpan', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _save() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama rutinitas tidak boleh kosong!')));
      return;
    }
    if (_blocks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tambahkan minimal 1 aktivitas!')));
      return;
    }

    if (widget.existingRoutine != null) {
      // Edit mode
      widget.existingRoutine!
        ..name = _nameController.text.trim()
        ..blocks = _blocks
        ..colorCode = _selectedColor
        ..assignedDays = _assignedDays;
        
      ref.read(routineProvider.notifier).updateRoutine(widget.existingRoutine!);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Rutinitas diperbarui.')));
    } else {
      // Create mode
      ref.read(routineProvider.notifier).addRoutine(
        name: _nameController.text.trim(),
        blocks: _blocks,
        assignedDays: _assignedDays,
        colorCode: _selectedColor,
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Rutinitas baru dibuat.')));
    }
    Navigator.pop(context);
  }

  void _toggleDay(int dayIndex) {
    setState(() {
      int actualDay = dayIndex + 1; // 1 (Mon) - 7 (Sun)
      if (_assignedDays.contains(actualDay)) {
        _assignedDays.remove(actualDay);
      } else {
        _assignedDays.add(actualDay);
      }
      _assignedDays.sort();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.existingRoutine == null ? 'Buat Rutinitas Baru' : 'Edit Rutinitas', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Detail Rutinitas
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: 'Nama Rutinitas (mis: Morning Routine)',
                        hintStyle: const TextStyle(color: Colors.white24, fontSize: 18),
                        filled: false,
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2))),
                        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Warna
                    const Text('Warna Tema', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 12),
                    Row(
                      children: _colors.map((color) => GestureDetector(
                        onTap: () => setState(() => _selectedColor = color),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 12),
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Color(color),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _selectedColor == color ? Colors.white : Colors.transparent,
                              width: 2,
                            ),
                            boxShadow: _selectedColor == color 
                                ? [BoxShadow(color: Color(color).withValues(alpha: 0.5), blurRadius: 10)] 
                                : [],
                          ),
                        ),
                      )).toList(),
                    ),
                    const SizedBox(height: 28),

                    // Penjadwalan Hari
                    const Text('Jadwal Hari Otomatis (Opsional)', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 10,
                      children: List.generate(7, (index) {
                        final isSelected = _assignedDays.contains(index + 1);
                        return GestureDetector(
                          onTap: () => _toggleDay(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 38,
                            height: 38,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(color: isSelected ? AppColors.primary : Colors.white12),
                            ),
                            child: Text(
                              _days[index],
                              style: TextStyle(
                                color: isSelected ? Colors.black : Colors.white70,
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 28),

                    // Daftar Aktivitas
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Daftar Aktivitas:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                        TextButton.icon(
                          onPressed: () => _showAddBlockDialog(),
                          icon: const Icon(LucideIcons.plus, size: 16),
                          label: const Text('Tambah'),
                        )
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (_blocks.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.02),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 2, style: BorderStyle.solid),
                        ),
                        child: Column(
                          children: [
                            const Icon(LucideIcons.listPlus, size: 40, color: Colors.white24),
                            const SizedBox(height: 12),
                            const Text('Belum ada aktivitas.', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            const Text('Buat rangkaian kebiasaanmu dari awal.', style: TextStyle(color: Colors.white38, fontSize: 12)),
                          ],
                        ),
                      ),
                    
                    ..._blocks.asMap().entries.map((entry) {
                      final int index = entry.key;
                      final RoutineBlockModel b = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                          leading: Icon(LucideIcons.clock, color: Color(_selectedColor).withValues(alpha: 0.8), size: 16),
                          title: Text(b.title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                          subtitle: Text('${b.startTime} - ${b.endTime}', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(LucideIcons.edit2, color: Colors.white54, size: 16),
                                onPressed: () => _showAddBlockDialog(index),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              const SizedBox(width: 12),
                              IconButton(
                                icon: const Icon(LucideIcons.trash2, color: Colors.redAccent, size: 16),
                                onPressed: () => setState(() => _blocks.removeAt(index)),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                          onTap: () => _showAddBlockDialog(index),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            
            // Bottom Action Bar
            Container(
              padding: EdgeInsets.only(
                top: 16,
                bottom: 16 + MediaQuery.of(context).viewPadding.bottom,
                left: 20,
                right: 20,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF161626),
                border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(LucideIcons.save, color: Colors.black, size: 20),
                  label: Text(widget.existingRoutine == null ? 'Simpan Rutinitas Baru' : 'Simpan Perubahan', 
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(_selectedColor), // uses selected routine color
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 8,
                    shadowColor: Color(_selectedColor).withValues(alpha: 0.5),
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

class _TimePickerButton extends StatelessWidget {
  final String label;
  final TimeOfDay? time;
  final VoidCallback onTap;

  const _TimePickerButton({required this.label, this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.clock, color: Colors.white24, size: 14),
                const SizedBox(width: 8),
                Text(
                  time != null ? '${time!.hour.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')}' : '--:--',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
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

  void _addBlockDummy() {
    // Sebagai mock sederhana di bottom sheet
    setState(() {
      _blocks.add(RoutineBlockModel(
        title: 'Aktivitas Baru ${_blocks.length + 1}',
        startTime: '08:00',
        endTime: '09:00',
        category: 'personal',
      ));
    });
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
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const Text(
            'Buat Template Rutinitas',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Nama Rutinitas (mis: Morning Routine)',
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.06),
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
              const Text('Daftar Aktivitas:', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
              TextButton.icon(
                onPressed: _addBlockDummy,
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
                  leading: const Icon(LucideIcons.clock, color: Colors.white54),
                  title: Text(b.title, style: const TextStyle(color: Colors.white)),
                  subtitle: Text('${b.startTime} - ${b.endTime}', style: const TextStyle(color: Colors.white38)),
                  trailing: IconButton(
                    icon: const Icon(LucideIcons.trash2, color: Colors.redAccent, size: 16),
                    onPressed: () => setState(() => _blocks.removeAt(index)),
                  ),
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
              child: const Text('Simpan Template', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:life_os_productivity/core/constants/app_colors.dart';
import 'package:life_os_productivity/features/categories/presentation/providers/category_provider.dart';
import 'package:life_os_productivity/features/categories/presentation/widgets/add_category_sheet.dart';
import 'package:life_os_productivity/features/categories/domain/category_model.dart';

class CategorySelector extends ConsumerWidget {
  final String selectedCategoryId;
  final ValueChanged<String> onChanged;

  const CategorySelector({
    super.key,
    required this.selectedCategoryId,
    required this.onChanged,
  });

  void _showAddCategory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddCategorySheet(),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, CategoryModel cat) {
    if (['work', 'health', 'learning', 'personal'].contains(cat.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kategori bawaan sistem tidak bisa dihapus.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Kategori?', style: TextStyle(color: AppColors.textPrimary)),
        content: Text('Apakah Anda yakin ingin menghapus kategori "${cat.name}"?',
            style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              ref.read(categoryProvider.notifier).deleteCategory(cat.id);
              if (selectedCategoryId == cat.id) {
                 onChanged('personal'); // Default fallback
              }
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Kategori dihapus')),
              );
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('Kategori', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            Text('(Tahan untuk menghapus)', style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontStyle: FontStyle.italic)),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...categories.map((cat) {
              final isSelected = selectedCategoryId == cat.id;
              final catColor = Color(cat.colorCode);

              return GestureDetector(
                onTap: () => onChanged(cat.id),
                onLongPress: () => _showDeleteDialog(context, ref, cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? catColor.withValues(alpha: 0.12) : AppColors.inputFill,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? catColor : AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: catColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        cat.name,
                        style: TextStyle(
                          color: isSelected ? catColor : AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            
            // Add custom category chip
            GestureDetector(
              onTap: () => _showAddCategory(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(PhosphorIcons.plus(), size: 14, color: AppColors.textSecondary.withValues(alpha: 0.7)),
                    const SizedBox(width: 6),
                    Text(
                      'Kategori',
                      style: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.8),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

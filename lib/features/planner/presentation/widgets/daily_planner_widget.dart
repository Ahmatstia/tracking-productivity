import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:life_os_productivity/core/constants/app_colors.dart';
import 'package:life_os_productivity/features/planner/domain/time_block_model.dart';
import 'package:life_os_productivity/features/planner/presentation/providers/time_block_provider.dart';
import 'package:life_os_productivity/features/planner/presentation/widgets/add_time_block_sheet.dart';
import 'package:life_os_productivity/features/categories/presentation/providers/category_provider.dart';
import 'package:life_os_productivity/features/categories/domain/category_model.dart';

class DailyPlannerWidget extends ConsumerStatefulWidget {
  final DateTime date;
  const DailyPlannerWidget({super.key, required this.date});

  @override
  ConsumerState<DailyPlannerWidget> createState() => _DailyPlannerWidgetState();
}

class _DailyPlannerWidgetState extends ConsumerState<DailyPlannerWidget> {
  final ScrollController _scrollController = ScrollController();

  static const int _startHour = 5;
  static const int _endHour = 23;
  static const double _hourHeight = 64.0;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final now = DateTime.now();
      final hour = now.hour < _startHour ? 8 : now.hour;
      final offset = (hour - _startHour) * _hourHeight;
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(offset.clamp(0, _scrollController.position.maxScrollExtent));
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final blocks = ref.watch(timeBlocksByDateProvider(widget.date));
    final categories = ref.watch(categoryProvider);
    final now = DateTime.now();
    final isToday = widget.date.year == now.year &&
        widget.date.month == now.month &&
        widget.date.day == now.day;

    final totalMinutes = (_endHour - _startHour) * 60;
    final totalHeight = (_endHour - _startHour) * _hourHeight;

    return SizedBox.expand(
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        child: SizedBox(
          height: totalHeight,
          width: double.infinity,
          child: Stack(
            children: [
              // Hour lines
              ...List.generate(_endHour - _startHour + 1, (i) {
                final hour = _startHour + i;
                return Positioned(
                  top: i * _hourHeight,
                  left: 0,
                  right: 0,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 48,
                        child: Text(
                          '${hour.toString().padLeft(2, '0')}:00',
                          style: TextStyle(
                            color: AppColors.textSecondary.withValues(alpha: 0.5),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          margin: const EdgeInsets.only(top: 6),
                          color: AppColors.border.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // Tap zones for empty slots
              ...List.generate(_endHour - _startHour, (i) {
                final hour = _startHour + i;
                final topPos = i * _hourHeight;
                final hasBlock = blocks.any((b) {
                  final bStart = b.startMinutes;
                  final bEnd = b.endMinutes;
                  final slotStart = hour * 60;
                  final slotEnd = slotStart + 60;
                  return bStart < slotEnd && bEnd > slotStart;
                });
                if (hasBlock) return const SizedBox.shrink();
                return Positioned(
                  top: topPos + 8,
                  left: 52,
                  right: 8,
                  height: _hourHeight - 8,
                  child: GestureDetector(
                    onTap: () => _showAddSheet(
                        '${hour.toString().padLeft(2, '0')}:00'),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                );
              }),

              // Time Block cards
              ...blocks.map((block) => _buildBlockCard(block, totalMinutes, categories)),

              // Current time indicator
              if (isToday && now.hour >= _startHour && now.hour < _endHour)
                _buildNowIndicator(now),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBlockCard(TimeBlockModel block, int totalMinutes, List<CategoryModel> categories) {
    final top = (block.startMinutes - _startHour * 60) / 60 * _hourHeight;
    final height = (block.durationMinutes / 60 * _hourHeight).clamp(36.0, double.infinity);
    final catColorCode = categories.firstWhere((c) => c.id == block.category, orElse: () => categories.first).colorCode;
    final color = Color(catColorCode);

    return Positioned(
      top: top + 2,
      left: 52,
      right: 8,
      height: height - 4,
      child: GestureDetector(
        onTap: () => _showEditSheet(block),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: block.isCompleted
                ? color.withValues(alpha: 0.06)
                : color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: block.isCompleted
                  ? color.withValues(alpha: 0.15)
                  : color.withValues(alpha: 0.4),
              width: 1.2,
            ),
            boxShadow: block.isCompleted
                ? null
                : [BoxShadow(color: color.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        block.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: block.isCompleted
                              ? AppColors.textSecondary.withValues(alpha: 0.5)
                              : AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          decoration: block.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                    if (height > 44)
                      Flexible(
                        child: Text(
                          '${block.startTime} - ${block.endTime}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: block.isCompleted
                                ? AppColors.textSecondary.withValues(alpha: 0.3)
                                : color.withValues(alpha: 0.8),
                            fontSize: 11,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => ref.read(timeBlockProvider.notifier).toggleBlock(block.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: block.isCompleted ? color : Colors.transparent,
                    border: Border.all(
                      color: block.isCompleted ? color : color.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                  child: block.isCompleted
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.05, end: 0),
      ),
    );
  }

  Widget _buildNowIndicator(DateTime now) {
    final minutes = now.hour * 60 + now.minute;
    final top = (minutes - _startHour * 60) / 60 * _hourHeight;
    return Positioned(
      top: top,
      left: 44,
      right: 0,
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFFEF4444),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Container(
              height: 1.5,
              color: const Color(0xFFEF4444).withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddSheet(String startTime) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTimeBlockSheet(
        date: widget.date,
        initialStartTime: startTime,
      ),
    );
  }

  void _showEditSheet(TimeBlockModel block) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTimeBlockSheet(
        date: widget.date,
        editBlock: block,
      ),
    );
  }
}

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

  static const int _startHour = 4; // Start earlier for better layout coverage
  static const int _endHour = 24;
  static const double _hourHeight = 82.0; // Taller for more premium feel
  static const double _timeColumnWidth = 64.0;

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

    const totalHeight = (_endHour - _startHour) * _hourHeight;

    return Container(
      color: AppColors.background,
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        child: SizedBox(
          height: totalHeight,
          width: double.infinity,
          child: Stack(
            children: [
              // ── Background Hour Indicators ──
              ...List.generate(_endHour - _startHour + 1, (i) {
                final hour = _startHour + i;
                return Positioned(
                  top: i * _hourHeight,
                  left: 0,
                  right: 0,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: _timeColumnWidth,
                        padding: const EdgeInsets.only(top: 0),
                        alignment: Alignment.topCenter,
                        child: Text(
                          '${hour.toString().padLeft(2, '0')}:00',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Opacity(
                          opacity: 0.2,
                          child: const _DashedLine(),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // ── Vertical Axis Line ──
              Positioned(
                top: 0,
                bottom: 0,
                left: _timeColumnWidth,
                child: Container(width: 1, color: AppColors.border.withValues(alpha: 0.2)),
              ),

              // ── Tap zones for empty slots (Continuous Fill) ──
              ...List.generate(_endHour - _startHour, (i) {
                final hour = _startHour + i;
                return Positioned(
                  top: i * _hourHeight,
                  left: _timeColumnWidth,
                  right: 0,
                  height: _hourHeight,
                  child: GestureDetector(
                    onTap: () => _showAddSheet('${hour.toString().padLeft(2, '0')}:00'),
                    child: Container(color: Colors.transparent),
                  ),
                );
              }),

              // ── Time Block cards (Seamless & Full Width) ──
              ...blocks.map((block) => _buildBlockCard(block, categories)),

              // ── Current time indicator (The Pulse) ──
              if (isToday && now.hour >= _startHour && now.hour < _endHour)
                _buildNowIndicator(now).animate().fadeIn(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBlockCard(TimeBlockModel block, List<CategoryModel> categories) {
    final top = (block.startMinutes - _startHour * 60) / 60 * _hourHeight;
    final height = (block.durationMinutes / 60 * _hourHeight).clamp(28.0, double.infinity);
    final verticalPadding = height > 46 ? 12.0 : 4.0;
    
    // Monochrome Logic
    final isCompleted = block.isCompleted;
    final bgOpacity = isCompleted ? 0.03 : 0.08;
    final borderOpacity = isCompleted ? 0.1 : 0.3;

    return Positioned(
      top: top, // SEAMLESS: No vertical offset
      left: _timeColumnWidth, // SEAMLESS: Starts right from the axis
      right: 0, // FULL WIDTH: Ends at the edge
      height: height, // SEAMLESS: Height matches duration exactly
      child: GestureDetector(
        onTap: () => _showEditSheet(block),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: verticalPadding),
          decoration: BoxDecoration(
            color: isCompleted ? AppColors.inputFill.withValues(alpha: 0.5) : AppColors.textPrimary.withValues(alpha: bgOpacity),
            border: Border(
              bottom: BorderSide(color: AppColors.border.withValues(alpha: borderOpacity), width: 0.5),
              left: BorderSide(color: isCompleted ? AppColors.textSecondary : AppColors.textPrimary, width: 4),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      block.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isCompleted ? AppColors.textSecondary : AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (height > 50)
                      Text(
                        '${block.startTime} — ${block.endTime}',
                        style: TextStyle(
                          color: AppColors.textSecondary.withValues(alpha: isCompleted ? 0.4 : 0.7),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _CheckButton(
                isCompleted: block.isCompleted,
                onToggle: () => ref.read(timeBlockProvider.notifier).toggleBlock(block.id),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  Widget _buildNowIndicator(DateTime now) {
    final minutes = now.hour * 60 + now.minute;
    final top = (minutes - _startHour * 60) / 60 * _hourHeight;
    return Positioned(
      top: top,
      left: _timeColumnWidth - 4,
      right: 0,
      child: Row(
        children: [
          Container(
            width: 8, height: 8,
            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
          ),
          Expanded(
            child: Container(height: 1, color: Colors.red.withValues(alpha: 0.6)),
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
      builder: (_) => AddTimeBlockSheet(date: widget.date, initialStartTime: startTime),
    );
  }

  void _showEditSheet(TimeBlockModel block) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTimeBlockSheet(date: widget.date, editBlock: block),
    );
  }
}

class _DashedLine extends StatelessWidget {
  const _DashedLine();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 4.0;
        const dashSpace = 4.0;
        final dashCount = (constraints.maxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return const SizedBox(
              width: dashWidth,
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(color: AppColors.textSecondary),
              ),
            );
          }),
        );
      },
    );
  }
}

class _CheckButton extends StatelessWidget {
  final bool isCompleted;
  final VoidCallback onToggle;

  const _CheckButton({required this.isCompleted, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: 200.ms,
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isCompleted ? AppColors.textPrimary : Colors.transparent,
          border: Border.all(color: AppColors.textPrimary, width: 2),
        ),
        child: isCompleted
            ? const Icon(Icons.check, size: 14, color: Colors.white)
            : null,
      ),
    );
  }
}

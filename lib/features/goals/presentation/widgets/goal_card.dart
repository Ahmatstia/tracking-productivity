import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:life_os_productivity/core/constants/app_colors.dart';

class GoalCard extends StatelessWidget {
  final String title;
  final double progress;
  final String timeLeft;

  const GoalCard({
    super.key,
    required this.title,
    required this.progress,
    required this.timeLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
              Text(timeLeft,
                  style: const TextStyle(
                      color: AppColors.secondary, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          LinearPercentIndicator(
            lineHeight: 8.0,
            percent: progress,
            padding: EdgeInsets.zero,
            barRadius: const Radius.circular(10),
            backgroundColor: AppColors.border,
            progressColor: AppColors.secondary,
            animation: true,
            animationDuration: 1000,
          ),
          const SizedBox(height: 8),
          Text("${(progress * 100).toInt()}% Selesai",
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}

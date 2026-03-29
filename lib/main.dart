import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:life_os_productivity/core/theme/app_theme.dart';
import 'package:life_os_productivity/features/goals/domain/goal_model.dart';
import 'package:life_os_productivity/features/tasks/domain/task_model.dart';
import 'package:life_os_productivity/features/planner/domain/time_block_model.dart';
import 'package:life_os_productivity/features/planner/domain/habit_pattern_model.dart';
import 'package:life_os_productivity/features/dashboard/presentation/pages/main_navigation_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // Register adapters (ID order matters)
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(SubTaskAdapter());
  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(GoalModelAdapter());
  if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(TaskModelAdapter());
  if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(TimeBlockModelAdapter());
  if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(HabitPatternModelAdapter());

  // Open all Hive boxes
  await Hive.openBox<GoalModel>('goals_box');
  await Hive.openBox<TaskModel>('tasks_box');
  await Hive.openBox<TimeBlockModel>('time_blocks_box');
  await Hive.openBox<HabitPatternModel>('habit_patterns_box');

  runApp(
    const ProviderScope(
      child: LifeOSApp(),
    ),
  );
}

class LifeOSApp extends StatelessWidget {
  const LifeOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyLife OS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainNavigationPage(),
    );
  }
}

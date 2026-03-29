import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:life_os_productivity/core/theme/app_theme.dart';
import 'package:life_os_productivity/features/goals/domain/goal_model.dart';
import 'package:life_os_productivity/features/tasks/domain/task_model.dart';
import 'package:life_os_productivity/features/dashboard/presentation/pages/main_navigation_page.dart';

void main() async {
  // 1. Wajib: Pastikan Flutter Engine siap
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inisialisasi Hive untuk Flutter
  await Hive.initFlutter();

  // 3. Registrasi Adapter (Penting agar Hive kenal GoalModel)
  // Pastikan nama Adapter sesuai dengan hasil generate build_runner kamu
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(SubTaskAdapter());
  }
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(GoalModelAdapter());
  }

  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(TaskModelAdapter());
  }

  // 4. Buka Box secara asinkron dan pastikan SELESAI sebelum runApp
  await Hive.openBox<GoalModel>('goals_box');
  await Hive.openBox<TaskModel>('tasks_box');

  // 5. Jalankan aplikasi
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
      title: 'Life OS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainNavigationPage(),
    );
  }
}

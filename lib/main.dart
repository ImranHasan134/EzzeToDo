import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/task.dart';
import 'theme/app_theme.dart';
import 'providers/task_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await Hive.initFlutter();
  Hive.registerAdapter(PriorityAdapter());
  Hive.registerAdapter(TaskStatusAdapter());
  Hive.registerAdapter(TaskCategoryAdapter());
  Hive.registerAdapter(TaskAdapter());

  final taskProvider = TaskProvider();
  await taskProvider.init();

  final themeProvider = ThemeProvider();
  await themeProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: taskProvider),
        ChangeNotifierProvider.value(value: themeProvider),
      ],
      child: const ModernTodoApp(),
    ),
  );
}

class ModernTodoApp extends StatelessWidget {
  const ModernTodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Ezze Task Flow',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const RootScreen(),
    );
  }
}
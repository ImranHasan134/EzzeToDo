import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/task.dart';

import 'theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'providers/task_provider.dart';
import 'screens/home_screen.dart';
import 'screens/task_list_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/settings_screen.dart';

// ════════════════════════════════════════════════════════════
// ENTRY POINT
// ════════════════════════════════════════════════════════════

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await Hive.initFlutter();
  Hive.registerAdapter(PriorityAdapter());
  Hive.registerAdapter(TaskStatusAdapter());
  Hive.registerAdapter(TaskAdapter());
  final taskProvider = TaskProvider();
  final themeProvider = ThemeProvider();
  await taskProvider.init();
  await themeProvider.init();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: taskProvider),
      ChangeNotifierProvider.value(value: themeProvider),
    ],
    child: const EzzeTodoApp(),
  ));
}

// ════════════════════════════════════════════════════════════
// APP
// ════════════════════════════════════════════════════════════

class EzzeTodoApp extends StatelessWidget {
  const EzzeTodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final thp = context.watch<ThemeProvider>();
    return MaterialApp(
        title: 'Ezze ToDo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: thp.themeMode,
        home: const MainNav());
  }
}

// ════════════════════════════════════════════════════════════
// NAVIGATION
// ════════════════════════════════════════════════════════════

class MainNav extends StatefulWidget {
  const MainNav({super.key});

  @override
  State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  int _idx = 0;
  static const _screens = [
    HomeScreen(),
    TaskListScreen(),
    StatsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor =
        isDark ? AppColors.primaryLight : AppColors.primary;
    final inactiveColor =
        isDark ? AppColors.mutedDark : AppColors.mutedLight;

    return Scaffold(
      body: IndexedStack(index: _idx, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            border: Border(
                top: BorderSide(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                    width: 1.5))),
        child: SafeArea(
            child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NI(Icons.home_rounded, Icons.home_outlined, 'Home',
                    0, _idx, activeColor, inactiveColor,
                    (i) => setState(() => _idx = i)),
                _NI(Icons.checklist_rounded, Icons.checklist_outlined,
                    'Tasks', 1, _idx, activeColor, inactiveColor,
                    (i) => setState(() => _idx = i)),
                _NI(Icons.bar_chart_rounded, Icons.bar_chart_outlined,
                    'Stats', 2, _idx, activeColor, inactiveColor,
                    (i) => setState(() => _idx = i)),
                _NI(Icons.settings_rounded, Icons.settings_outlined,
                    'Settings', 3, _idx, activeColor, inactiveColor,
                    (i) => setState(() => _idx = i)),
              ]),
        )),
      ),
    );
  }
}

class _NI extends StatelessWidget {
  final IconData icon, outIcon;
  final String label;
  final int index, current;
  final Color activeColor, inactiveColor;
  final ValueChanged<int> onTap;
  const _NI(this.icon, this.outIcon, this.label, this.index,
      this.current, this.activeColor, this.inactiveColor, this.onTap);

  @override
  Widget build(BuildContext context) {
    final isActive = index == current;
    return Expanded(
        child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(index),
      child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: isActive
              ? BoxDecoration(
                  color: activeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12))
              : null,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(isActive ? icon : outIcon,
                color: isActive ? activeColor : inactiveColor,
                size: 22),
            const SizedBox(height: 3),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: isActive
                        ? FontWeight.w700
                        : FontWeight.w400,
                    color:
                        isActive ? activeColor : inactiveColor)),
          ])),
    ));
  }
}

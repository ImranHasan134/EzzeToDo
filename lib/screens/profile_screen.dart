import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/task_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        children: [
          // Profile Header
          Center(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        border: Border.all(color: theme.colorScheme.primary, width: 2),
                      ),
                      child: Icon(Icons.person, size: 50, color: theme.colorScheme.primary),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: Icon(Icons.edit, size: 14, color: theme.colorScheme.primary),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Jacob Jones', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                Text('Workspace Admin', style: TextStyle(fontSize: 14, color: isDark ? Colors.white54 : Colors.black54)),
              ],
            ),
          ),

          const SizedBox(height: 40),
          Text('PREFERENCES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: isDark ? Colors.white54 : Colors.black54)),
          const SizedBox(height: 12),

          // Theme Toggle Card
          Container(
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: isDark ? Colors.amber.withOpacity(0.1) : Colors.indigo.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, color: isDark ? Colors.amber : Colors.indigo),
              ),
              title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(themeProvider.isDark ? 'Currently On' : 'Currently Off'),
              trailing: Switch(
                value: themeProvider.isDark,
                activeColor: theme.colorScheme.primary,
                onChanged: (_) => themeProvider.toggleTheme(),
              ),
            ),
          ),

          const SizedBox(height: 24),
          Text('DATA MANAGEMENT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: isDark ? Colors.white54 : Colors.black54)),
          const SizedBox(height: 12),

          // Clear Data Card
          Container(
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
              ),
              title: const Text('Clear All Tasks', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.redAccent)),
              subtitle: const Text('Wipe local device storage'),
              onTap: () => _showClearDialog(context),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).cardTheme.color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear All Data?', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('This action cannot be undone. All tasks will be permanently deleted from this device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              context.read<TaskProvider>().clearAllTasks();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Storage wiped successfully', style: TextStyle(fontWeight: FontWeight.w600)),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Wipe Data'),
          ),
        ],
      ),
    );
  }
}
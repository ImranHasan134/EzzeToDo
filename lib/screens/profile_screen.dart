import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/task_provider.dart';
import '../providers/user_provider.dart';
import '../services/pdf_service.dart'; // 🔴 IMPORT PDF SERVICE

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final userProvider = context.watch<UserProvider>();
    final taskProvider = context.read<TaskProvider>(); // Used for export
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
          // ── PROFILE HEADER ──
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => userProvider.pickImage(),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          border: Border.all(color: theme.colorScheme.primary, width: 2),
                          image: userProvider.imageBase64 != null
                              ? DecorationImage(
                            image: MemoryImage(base64Decode(userProvider.imageBase64!)),
                            fit: BoxFit.cover,
                          )
                              : null,
                        ),
                        child: userProvider.imageBase64 == null
                            ? Icon(Icons.person, size: 50, color: theme.colorScheme.primary)
                            : null,
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, shape: BoxShape.circle),
                        child: Icon(Icons.camera_alt_rounded, size: 14, color: theme.colorScheme.primary),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => _showEditNameDialog(context, userProvider),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(userProvider.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                      const SizedBox(width: 8),
                      Icon(Icons.edit, size: 16, color: theme.colorScheme.primary),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text('Welcome, Boss!', style: TextStyle(fontSize: 14, color: isDark ? Colors.white54 : Colors.black54)),
              ],
            ),
          ),

          const SizedBox(height: 40),
          Text('PREFERENCES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: isDark ? Colors.white54 : Colors.black54)),
          const SizedBox(height: 12),

          // ── THEME TOGGLE ──
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

          // 🔴 NEW: EXPORT PDF CARD
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
                decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.picture_as_pdf_rounded, color: Colors.blueAccent),
              ),
              title: const Text('Export PDF Report', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blueAccent)),
              subtitle: const Text('Generate A4 structured summary'),
              onTap: () => PdfService.exportTaskReport(taskProvider, userProvider.name), // 🔴 Triggers PDF Generation
            ),
          ),

          const SizedBox(height: 12),

          // ── CLEAR DATA CARD ──
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
              title: const Text('Clear All Data', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.redAccent)),
              subtitle: const Text('Wipe tasks & profile data'),
              onTap: () => _showClearDialog(context, userProvider),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditNameDialog(BuildContext context, UserProvider userProvider) {
    final TextEditingController nameCtrl = TextEditingController(text: userProvider.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardTheme.color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Name', style: TextStyle(fontWeight: FontWeight.w700)),
        content: TextField(
          controller: nameCtrl,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'Enter your name',
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).colorScheme.primary)),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
            onPressed: () {
              userProvider.updateName(nameCtrl.text);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showClearDialog(BuildContext context, UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).cardTheme.color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear All Data?', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('This action cannot be undone. All tasks and profile data will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              context.read<TaskProvider>().clearAllTasks();
              userProvider.clearProfile();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Storage wiped successfully', style: TextStyle(fontWeight: FontWeight.w600)), behavior: SnackBarBehavior.floating),
              );
            },
            child: const Text('Wipe Data'),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class AddOrEditScreen extends StatefulWidget {
  final Task? task;

  const AddOrEditScreen({super.key, this.task});

  @override
  State<AddOrEditScreen> createState() => _AddOrEditScreenState();
}

class _AddOrEditScreenState extends State<AddOrEditScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  Priority _priority = Priority.medium;
  TaskCategory _category = TaskCategory.work;
  DateTime? _deadline; // 🔴 NEW: Tracks the due date

  bool get isEdit => widget.task != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _titleCtrl.text = widget.task!.title;
      _descCtrl.text = widget.task!.description;
      _priority = widget.task!.priority;
      _category = widget.task!.category ?? TaskCategory.work;
      _deadline = widget.task!.deadline; // 🔴 Load existing deadline
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _saveTask() {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task title cannot be empty'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    context.read<TaskProvider>().saveTask(Task(
      id: isEdit ? widget.task!.id : null,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      priority: _priority,
      category: _category,
      deadline: _deadline, // 🔴 Save the deadline
      createdAt: isEdit ? widget.task!.createdAt : null,
      status: isEdit ? widget.task!.status : TaskStatus.todo,
      progress: isEdit ? widget.task!.progress : 0,
    ));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Task' : 'New Task'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          physics: const BouncingScrollPhysics(),
          children: [
            TextField(
              controller: _titleCtrl,
              autofocus: !isEdit,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                hintText: 'What needs to be done?',
                hintStyle: TextStyle(
                  color: isDark ? Colors.white30 : Colors.black26,
                  fontWeight: FontWeight.w600,
                ),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _descCtrl,
              maxLines: null,
              minLines: 3,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Add details or notes...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.white30 : Colors.black26,
                ),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
              ),
            ),

            const SizedBox(height: 32),

            // ── DUE DATE PICKER ──
            Text('Due Date', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white54 : Colors.black54, letterSpacing: 0.5)),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _deadline ?? DateTime.now(),
                  firstDate: DateTime.now(), // Prevent picking past dates for new tasks
                  lastDate: DateTime(2100),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: isDark ? const ColorScheme.dark(primary: Color(0xFF3B8258)) : const ColorScheme.light(primary: Color(0xFF3B8258)),
                      ),
                      child: child!,
                    );
                  },
                );
                if (date != null) setState(() => _deadline = date);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Text(
                      _deadline == null ? 'Select a due date' : '${_deadline!.month}/${_deadline!.day}/${_deadline!.year}',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _deadline == null ? (isDark ? Colors.white30 : Colors.black38) : (isDark ? Colors.white : Colors.black87)
                      ),
                    ),
                    const Spacer(),
                    if (_deadline != null)
                      GestureDetector(
                        onTap: () => setState(() => _deadline = null),
                        child: const Icon(Icons.close, size: 18, color: Colors.redAccent),
                      )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── CATEGORY SELECTOR ──
            Text('Category', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white54 : Colors.black54, letterSpacing: 0.5)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<TaskCategory>(
                segments: const [
                  ButtonSegment(value: TaskCategory.work, label: FittedBox(fit: BoxFit.scaleDown, child: Text('Workspace'))),
                  ButtonSegment(value: TaskCategory.portfolio, label: FittedBox(fit: BoxFit.scaleDown, child: Text('Portfolio'))),
                  ButtonSegment(value: TaskCategory.personal, label: FittedBox(fit: BoxFit.scaleDown, child: Text('Personal'))),
                ],
                selected: {_category},
                onSelectionChanged: (Set<TaskCategory> c) => setState(() => _category = c.first),
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: theme.colorScheme.primary.withOpacity(0.15),
                  selectedForegroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── PRIORITY SELECTOR ──
            Text('Priority Level', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white54 : Colors.black54, letterSpacing: 0.5)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<Priority>(
                segments: [
                  ButtonSegment(value: Priority.low, label: FittedBox(fit: BoxFit.scaleDown, child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.circle, size: 10, color: Priority.low.color), const SizedBox(width: 6), Text(Priority.low.label)]))),
                  ButtonSegment(value: Priority.medium, label: FittedBox(fit: BoxFit.scaleDown, child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.circle, size: 10, color: Priority.medium.color), const SizedBox(width: 6), Text(Priority.medium.label)]))),
                  ButtonSegment(value: Priority.high, label: FittedBox(fit: BoxFit.scaleDown, child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.circle, size: 10, color: Priority.high.color), const SizedBox(width: 6), Text(Priority.high.label)]))),
                ],
                selected: {_priority},
                onSelectionChanged: (Set<Priority> p) => setState(() => _priority = p.first),
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: theme.colorScheme.primary.withOpacity(0.15),
                  selectedForegroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
          child: FilledButton(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              backgroundColor: theme.colorScheme.primary,
            ),
            onPressed: _saveTask,
            child: Text(
                isEdit ? 'Save Changes' : 'Create Task',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)
            ),
          ),
        ),
      ),
    );
  }
}
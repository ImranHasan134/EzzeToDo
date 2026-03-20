import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/task.dart';
import '../theme/app_theme.dart';
import '../providers/task_provider.dart';

class AddOrEditScreen extends StatefulWidget {
  final Task? task;
  const AddOrEditScreen({super.key, this.task});

  @override
  State<AddOrEditScreen> createState() => _AddOrEditScreenState();
}

class _AddOrEditScreenState extends State<AddOrEditScreen> {
  final _fk = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  Priority _priority = Priority.medium;
  TaskStatus _status = TaskStatus.todo;
  DateTime? _deadline;
  bool _saving = false;

  bool get isEdit => widget.task != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      final t = widget.task!;
      _titleCtrl.text = t.title;
      _descCtrl.text = t.description;
      _priority = t.priority;
      _status = t.status;
      _deadline = t.deadline;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
          data: Theme.of(ctx).copyWith(
              colorScheme: Theme.of(ctx)
                  .colorScheme
                  .copyWith(primary: AppColors.primary)),
          child: child!),
    );
    if (d != null) setState(() => _deadline = d);
  }

  Future<void> _save() async {
    if (!_fk.currentState!.validate()) return;
    setState(() => _saving = true);
    final p = context.read<TaskProvider>();
    try {
      if (isEdit) {
        await p.updateTask(widget.task!.copyWith(
            title: _titleCtrl.text.trim(),
            description: _descCtrl.text.trim(),
            priority: _priority,
            status: _status,
            deadline: _deadline,
            clearDeadline: _deadline == null));
      } else {
        await p.addTask(p.newTask(
            title: _titleCtrl.text.trim(),
            description: _descCtrl.text.trim(),
            deadline: _deadline,
            priority: _priority,
            status: _status));
      }
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(isEdit ? 'Task updated!' : 'Task added!'),
            backgroundColor: AppColors.completed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        titleSpacing: 4,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.borderDark
                  : AppColors.borderLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.close_rounded,
                size: 18,
                color: theme.textTheme.bodySmall?.color),
          ),
        ),
        title: Text(isEdit ? 'Edit Task' : 'New Task',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
                color: theme.textTheme.displaySmall?.color)),
      ),
      body: Form(
        key: _fk,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
          children: [

            // ── TITLE ────────────────────────────────────
            _FieldLabel('Task Title'),
            TextFormField(
              controller: _titleCtrl,
              maxLength: 100,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.textDark
                      : AppColors.textLight),
              decoration: InputDecoration(
                  hintText: 'What needs to be done?',
                  counterText: '',
                  filled: true,
                  fillColor: isDark
                      ? AppColors.inputBgDark
                      : AppColors.inputBgLight,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: isDark
                              ? AppColors.inputBorderDark
                              : AppColors.inputBorderLight,
                          width: 1.2)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: isDark
                              ? AppColors.inputBorderDark
                              : AppColors.inputBorderLight,
                          width: 1.2)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: AppColors.primary, width: 1.5)),
                  errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: AppColors.error, width: 1.2)),
                  focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: AppColors.error, width: 1.5)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 13)),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Title is required'
                  : null,
              textCapitalization: TextCapitalization.sentences,
            ),

            const SizedBox(height: 16),

            // ── DESCRIPTION ───────────────────────────────
            _FieldLabel('Description'),
            TextFormField(
              controller: _descCtrl,
              maxLines: 3,
              maxLength: 500,
              style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.textDark
                      : AppColors.textLight),
              decoration: InputDecoration(
                  hintText: 'Add details (optional)...',
                  filled: true,
                  fillColor: isDark
                      ? AppColors.inputBgDark
                      : AppColors.inputBgLight,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: isDark
                              ? AppColors.inputBorderDark
                              : AppColors.inputBorderLight,
                          width: 1.2)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: isDark
                              ? AppColors.inputBorderDark
                              : AppColors.inputBorderLight,
                          width: 1.2)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: AppColors.primary, width: 1.5)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 13)),
              textCapitalization: TextCapitalization.sentences,
            ),

            const SizedBox(height: 16),

            // ── DEADLINE ──────────────────────────────────
            _FieldLabel('Deadline'),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 13),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.inputBgDark
                      : AppColors.inputBgLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: _deadline != null
                          ? AppColors.primary
                          : isDark
                          ? AppColors.inputBorderDark
                          : AppColors.inputBorderLight,
                      width: _deadline != null ? 1.5 : 1.2),
                ),
                child: Row(children: [
                  Icon(Icons.calendar_today_rounded,
                      size: 16,
                      color: _deadline != null
                          ? AppColors.primary
                          : isDark
                          ? AppColors.mutedDark
                          : AppColors.mutedLight),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                        _deadline != null
                            ? DateFormat('EEE, MMM d, yyyy')
                            .format(_deadline!)
                            : 'Pick a deadline',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: _deadline != null
                                ? FontWeight.w500
                                : FontWeight.w400,
                            color: _deadline != null
                                ? isDark
                                ? AppColors.textDark
                                : AppColors.textLight
                                : isDark
                                ? AppColors.mutedDark
                                : AppColors.mutedLight)),
                  ),
                  if (_deadline != null)
                    GestureDetector(
                      onTap: () =>
                          setState(() => _deadline = null),
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(Icons.close_rounded,
                            size: 13,
                            color: isDark
                                ? AppColors.mutedDark
                                : AppColors.mutedLight),
                      ),
                    ),
                ]),
              ),
            ),

            const SizedBox(height: 16),

            // ── PRIORITY ──────────────────────────────────
            _FieldLabel('Priority'),
            Row(
              children: Priority.values.map((pr) {
                final isSel = pr == _priority;
                final col = H.priorityColor(pr);
                final bg = H.priorityBg(pr);
                final isLast = pr == Priority.values.last;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                        right: isLast ? 0 : 8),
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _priority = pr),
                      child: AnimatedContainer(
                        duration:
                        const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                            vertical: 11),
                        decoration: BoxDecoration(
                          color: isSel
                              ? bg
                              : isDark
                              ? AppColors.inputBgDark
                              : AppColors.inputBgLight,
                          borderRadius:
                          BorderRadius.circular(10),
                          border: Border.all(
                              color: isSel
                                  ? col
                                  : isDark
                                  ? AppColors.inputBorderDark
                                  : AppColors.inputBorderLight,
                              width: isSel ? 1.5 : 1.2),
                        ),
                        alignment: Alignment.center,
                        child: Column(children: [
                          Text(H.priorityIcon(pr),
                              style: const TextStyle(
                                  fontSize: 20)),
                          const SizedBox(height: 5),
                          Text(H.priorityLabel(pr),
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSel
                                      ? col
                                      : isDark
                                      ? AppColors.mutedDark
                                      : AppColors.mutedLight)),
                        ]),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // ── STATUS ────────────────────────────────────
            _FieldLabel('Status'),
            ...TaskStatus.values.map((s) {
              final isSel = s == _status;
              final col = H.statusColor(s);
              final bg = H.statusBg(s);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _status = s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSel
                          ? bg
                          : isDark
                          ? AppColors.inputBgDark
                          : AppColors.inputBgLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: isSel
                              ? col
                              : isDark
                              ? AppColors.inputBorderDark
                              : AppColors.inputBorderLight,
                          width: isSel ? 1.5 : 1.2),
                    ),
                    child: Row(children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: isSel
                              ? col.withOpacity(0.15)
                              : isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                            _statusIcon(s),
                            size: 15,
                            color: isSel
                                ? col
                                : isDark
                                ? AppColors.mutedDark
                                : AppColors.mutedLight),
                      ),
                      const SizedBox(width: 12),
                      Text(H.statusLabel(s),
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSel
                                  ? col
                                  : isDark
                                  ? AppColors.textDark
                                  : AppColors.textLight)),
                      const Spacer(),
                      AnimatedContainer(
                        duration:
                        const Duration(milliseconds: 180),
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: isSel
                              ? col
                              : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: isSel
                                  ? col
                                  : isDark
                                  ? AppColors.borderDark
                                  : AppColors.borderLight,
                              width: 1.5),
                        ),
                        child: isSel
                            ? const Icon(Icons.check_rounded,
                            size: 11, color: Colors.white)
                            : null,
                      ),
                    ]),
                  ),
                ),
              );
            }),

            const SizedBox(height: 24),

            // ── SAVE BUTTON ───────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  disabledBackgroundColor:
                  AppColors.primary.withOpacity(0.5),
                ),
                child: _saving
                    ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white))
                    : Text(
                    isEdit ? 'Save Changes' : 'Add Task',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _statusIcon(TaskStatus s) {
    switch (s) {
      case TaskStatus.todo:
        return Icons.radio_button_unchecked_rounded;
      case TaskStatus.inProgress:
        return Icons.timelapse_rounded;
      case TaskStatus.completed:
        return Icons.check_circle_outline_rounded;
    }
  }
}

// ═══════════════════════════════════════════════════════════
// FIELD LABEL
// ═══════════════════════════════════════════════════════════

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.1,
              color: isDark
                  ? AppColors.mutedDark
                  : AppColors.mutedLight)),
    );
  }
}
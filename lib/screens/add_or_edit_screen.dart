import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../main.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Task' : 'New Task'),
        leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.pop(context)),
        actions: [
          Padding(
              padding: const EdgeInsets.only(right: 12),
              child: TextButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(isEdit ? 'Save' : 'Add',
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 15))))
        ],
      ),
      body: Form(
          key: _fk,
          child: ListView(padding: const EdgeInsets.all(16), children: [
            _Lbl('Task Title *'),
            TextFormField(
                controller: _titleCtrl,
                maxLength: 100,
                decoration: const InputDecoration(
                    hintText: 'What needs to be done?',
                    counterText: ''),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Title is required'
                    : null,
                textCapitalization: TextCapitalization.sentences),
            const SizedBox(height: 16),
            _Lbl('Description'),
            TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                maxLength: 500,
                decoration: const InputDecoration(
                    hintText: 'Add details (optional)...'),
                textCapitalization: TextCapitalization.sentences),
            const SizedBox(height: 16),
            _Lbl('Deadline'),
            GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                      color: theme.inputDecorationTheme.fillColor,
                      border: Border.all(
                          color: _deadline != null
                              ? AppColors.primary
                              : theme.dividerColor,
                          width: 1.5),
                      borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 18,
                        color: _deadline != null
                            ? AppColors.primary
                            : theme.textTheme.bodySmall?.color),
                    const SizedBox(width: 10),
                    Text(
                        _deadline != null
                            ? DateFormat('EEEE, MMM d, yyyy')
                                .format(_deadline!)
                            : 'Pick a deadline',
                        style: TextStyle(
                            fontSize: 14,
                            color: _deadline != null
                                ? theme.textTheme.bodyLarge?.color
                                : theme.textTheme.bodySmall?.color)),
                    const Spacer(),
                    if (_deadline != null)
                      GestureDetector(
                          onTap: () => setState(() => _deadline = null),
                          child: Icon(Icons.close_rounded,
                              size: 16,
                              color: theme.textTheme.bodySmall?.color)),
                  ]),
                )),
            const SizedBox(height: 16),
            _Lbl('Priority'),
            Row(
                children: Priority.values.map((pr) {
              final isSel = pr == _priority;
              final col = H.priorityColor(pr);
              final bg = H.priorityBg(pr);
              return Expanded(
                  child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                          onTap: () => setState(() => _priority = pr),
                          child: AnimatedContainer(
                              duration:
                                  const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12),
                              decoration: BoxDecoration(
                                  color: isSel
                                      ? bg
                                      : Colors.transparent,
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  border: Border.all(
                                      color: isSel
                                          ? col
                                          : theme.dividerColor,
                                      width: isSel ? 2 : 1.5)),
                              alignment: Alignment.center,
                              child: Column(children: [
                                Text(H.priorityIcon(pr),
                                    style: const TextStyle(
                                        fontSize: 18)),
                                const SizedBox(height: 4),
                                Text(H.priorityLabel(pr),
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isSel
                                            ? col
                                            : theme.textTheme.bodySmall
                                                ?.color)),
                              ])))));
            }).toList()),
            const SizedBox(height: 16),
            _Lbl('Status'),
            ...TaskStatus.values.map((s) {
              final isSel = s == _status;
              final col = H.statusColor(s);
              return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                      onTap: () => setState(() => _status = s),
                      child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                              color: isSel
                                  ? H.statusBg(s)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: isSel
                                      ? col
                                      : theme.dividerColor,
                                  width: isSel ? 2 : 1.5)),
                          child: Row(children: [
                            Text(H.statusIcon(s),
                                style: TextStyle(
                                    color: col, fontSize: 16)),
                            const SizedBox(width: 10),
                            Text(H.statusLabel(s),
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: isSel
                                        ? col
                                        : theme.textTheme.bodyLarge
                                            ?.color)),
                            const Spacer(),
                            if (isSel)
                              Icon(Icons.check_circle_rounded,
                                  color: col, size: 18),
                          ]))));
            }),
            const SizedBox(height: 32),
            ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: 16)),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(
                        isEdit ? 'Save Changes' : 'Add Task',
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600))),
          ])),
    );
  }
}

class _Lbl extends StatelessWidget {
  final String text;
  const _Lbl(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontWeight: FontWeight.w600)),
      );
}

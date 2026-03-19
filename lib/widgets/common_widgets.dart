import 'package:flutter/material.dart';

import '../models/task.dart';
import '../theme/app_theme.dart';
import '../providers/task_provider.dart';

// ════════════════════════════════════════════════════════════
// PRIORITY BADGE
// ════════════════════════════════════════════════════════════

class PriorityBadge extends StatelessWidget {
  final Priority priority;
  final bool small;
  const PriorityBadge(
      {super.key, required this.priority, this.small = false});

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(
            horizontal: small ? 8 : 10, vertical: small ? 2 : 4),
        decoration: BoxDecoration(
            color: H.priorityBg(priority),
            borderRadius: BorderRadius.circular(20)),
        child: Text(H.priorityLabel(priority),
            style: TextStyle(
                fontSize: small ? 10 : 12,
                fontWeight: FontWeight.w600,
                color: H.priorityColor(priority))),
      );
}

// ════════════════════════════════════════════════════════════
// STATUS BADGE
// ════════════════════════════════════════════════════════════

class StatusBadge extends StatelessWidget {
  final TaskStatus status;
  final bool small;
  const StatusBadge({super.key, required this.status, this.small = false});

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(
            horizontal: small ? 8 : 10, vertical: small ? 2 : 4),
        decoration: BoxDecoration(
            color: H.statusBg(status),
            borderRadius: BorderRadius.circular(20)),
        child: Text('${H.statusIcon(status)} ${H.statusLabel(status)}',
            style: TextStyle(
                fontSize: small ? 10 : 12,
                fontWeight: FontWeight.w600,
                color: H.statusColor(status))),
      );
}

// ════════════════════════════════════════════════════════════
// TASK CARD
// ════════════════════════════════════════════════════════════

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap, onComplete;
  final VoidCallback? onDelete;
  const TaskCard(
      {super.key,
      required this.task,
      required this.onTap,
      required this.onComplete,
      this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = task.status == TaskStatus.completed;
    final pc = H.priorityColor(task.priority);
    final cardColor = theme.brightness == Brightness.dark
        ? AppColors.cardDark
        : AppColors.cardLight;
    final borderColor = theme.brightness == Brightness.dark
        ? AppColors.borderDark
        : AppColors.borderLight;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        clipBehavior: Clip.hardEdge,
        child: IntrinsicHeight(
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
            Container(width: 5, color: pc),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: onComplete,
                              child: AnimatedContainer(
                                duration:
                                    const Duration(milliseconds: 200),
                                width: 22,
                                height: 22,
                                margin: const EdgeInsets.only(
                                    top: 1, right: 10),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isCompleted
                                      ? AppColors.completed
                                      : Colors.transparent,
                                  border: Border.all(
                                      color: isCompleted
                                          ? AppColors.completed
                                          : pc,
                                      width: 2),
                                ),
                                child: isCompleted
                                    ? const Icon(Icons.check,
                                        size: 13, color: Colors.white)
                                    : null,
                              ),
                            ),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Text(task.title,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        decoration: isCompleted
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none,
                                        color: isCompleted
                                            ? (theme.brightness ==
                                                    Brightness.dark
                                                ? AppColors.mutedDark
                                                : AppColors.mutedLight)
                                            : (theme.brightness ==
                                                    Brightness.dark
                                                ? AppColors.textDark
                                                : AppColors.textLight),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis),
                                  if (task.description.isNotEmpty) ...[
                                    const SizedBox(height: 3),
                                    Text(task.description,
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: theme.brightness ==
                                                    Brightness.dark
                                                ? AppColors.mutedDark
                                                : AppColors.mutedLight),
                                        maxLines: 1,
                                        overflow:
                                            TextOverflow.ellipsis),
                                  ],
                                ])),
                            if (onDelete != null)
                              GestureDetector(
                                  onTap: onDelete,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.only(left: 8),
                                    child: Icon(
                                        Icons.delete_outline_rounded,
                                        size: 18,
                                        color: Colors.red),
                                  )),
                          ]),
                      const SizedBox(height: 8),
                      Row(children: [
                        PriorityBadge(
                            priority: task.priority, small: true),
                        const SizedBox(width: 6),
                        StatusBadge(status: task.status, small: true),
                        const Spacer(),
                        if (task.deadline != null)
                          Row(children: [
                            Icon(Icons.schedule_rounded,
                                size: 12,
                                color:
                                    H.deadlineColor(task, context)),
                            const SizedBox(width: 3),
                            Text(H.deadlineLabel(task),
                                style: TextStyle(
                                  fontSize: 11,
                                  color:
                                      H.deadlineColor(task, context),
                                  fontWeight: task.isOverdue
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                )),
                          ]),
                      ]),
                    ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// SECTION HEADER
// ════════════════════════════════════════════════════════════

class SectionHeader extends StatelessWidget {
  final String title;
  final String? trailing;
  final VoidCallback? onTrailingTap;
  const SectionHeader(
      {super.key,
      required this.title,
      this.trailing,
      this.onTrailingTap});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(children: [
          Text(title,
              style: Theme.of(context).textTheme.headlineSmall),
          const Spacer(),
          if (trailing != null)
            GestureDetector(
                onTap: onTrailingTap,
                child: Text(trailing!,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600))),
        ]),
      );
}

// ════════════════════════════════════════════════════════════
// FILTER CHIP ROW
// ════════════════════════════════════════════════════════════

class FilterChipRow extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onChanged;
  const FilterChipRow(
      {super.key,
      required this.options,
      required this.selected,
      required this.onChanged});

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: options.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            final opt = options[i];
            final isSel = opt == selected;
            return GestureDetector(
              onTap: () => onChanged(opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: isSel
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: isSel
                          ? AppColors.primary
                          : Theme.of(context).dividerColor,
                      width: 1.5),
                ),
                child: Text(opt,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isSel
                            ? Colors.white
                            : Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color)),
              ),
            );
          },
        ),
      );
}

// ════════════════════════════════════════════════════════════
// EMPTY STATE
// ════════════════════════════════════════════════════════════

class EmptyState extends StatelessWidget {
  final String emoji, title, subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  const EmptyState(
      {super.key,
      required this.emoji,
      required this.title,
      required this.subtitle,
      this.actionLabel,
      this.onAction});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            Text(emoji, style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(title,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(subtitle,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                  onPressed: onAction, child: Text(actionLabel!)),
            ],
          ]),
        ),
      );
}

// ════════════════════════════════════════════════════════════
// STAT BOX
// ════════════════════════════════════════════════════════════

class StatBox extends StatelessWidget {
  final String label, value;
  final Color color, bgColor;
  const StatBox(
      {super.key,
      required this.label,
      required this.value,
      required this.color,
      required this.bgColor});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14)),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Text(value,
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: color)),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: color)),
        ]),
      );
}

// ════════════════════════════════════════════════════════════
// CIRCULAR PROGRESS WIDGET
// ════════════════════════════════════════════════════════════

class CircularProgressWidget extends StatelessWidget {
  final double value;
  final double size;
  final Color color;
  final String centerText;
  final String? label;
  const CircularProgressWidget(
      {super.key,
      required this.value,
      this.size = 80,
      required this.color,
      required this.centerText,
      this.label});

  @override
  Widget build(BuildContext context) => Column(children: [
        SizedBox(
            width: size,
            height: size,
            child: Stack(alignment: Alignment.center, children: [
              SizedBox(
                  width: size,
                  height: size,
                  child: CircularProgressIndicator(
                    value: value,
                    strokeWidth: 8,
                    backgroundColor: color.withOpacity(0.15),
                    valueColor: AlwaysStoppedAnimation(color),
                    strokeCap: StrokeCap.round,
                  )),
              Text(centerText,
                  style: TextStyle(
                      fontSize: size * 0.2,
                      fontWeight: FontWeight.w800,
                      color: color)),
            ])),
        if (label != null) ...[
          const SizedBox(height: 8),
          Text(label!, style: Theme.of(context).textTheme.bodySmall),
        ],
      ]);
}

// ════════════════════════════════════════════════════════════
// APP DIVIDER
// ════════════════════════════════════════════════════════════

class AppDivider extends StatelessWidget {
  const AppDivider({super.key});

  @override
  Widget build(BuildContext context) => Divider(
      color: Theme.of(context).dividerColor, height: 1, thickness: 1);
}

// ════════════════════════════════════════════════════════════
// SETTINGS TILE
// ════════════════════════════════════════════════════════════

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  const SettingsTile(
      {super.key,
      required this.icon,
      required this.title,
      this.subtitle,
      this.trailing,
      this.onTap,
      this.iconColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: (iconColor ?? AppColors.primary)
                      .withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon,
                    size: 18,
                    color: iconColor ?? AppColors.primary)),
            const SizedBox(width: 14),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(title, style: theme.textTheme.titleMedium),
                  if (subtitle != null)
                    Text(subtitle!,
                        style: theme.textTheme.bodySmall),
                ])),
            if (trailing != null) trailing!,
          ])),
    );
  }
}

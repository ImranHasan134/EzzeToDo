import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../theme/app_theme.dart';
import '../providers/task_provider.dart';
import '../widgets/common_widgets.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<TaskProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(slivers: [

        // ── APP BAR ────────────────────────────────────────
        SliverAppBar(
          floating: true,
          snap: true,
          titleSpacing: 20,
          toolbarHeight: 60,
          title: Text('Stats',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: theme.textTheme.displaySmall?.color)),
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
          sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── TOP 2x2 STAT GRID ──────────────────────────
                Row(children: [
                  Expanded(
                      child: _MiniStatBox(
                          label: 'Completion',
                          value: '${(p.completionRate * 100).round()}%',
                          color: AppColors.todo,
                          bgColor: AppColors.primarySurface,
                          icon: Icons.donut_large_rounded)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _MiniStatBox(
                          label: 'This Week',
                          value: '${p.thisWeekCompleted.length}',
                          color: AppColors.inProgress,
                          bgColor: AppColors.completedBg,
                          icon: Icons.calendar_today_rounded)),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                      child: _MiniStatBox(
                          label: 'Total Tasks',
                          value: '${p.totalCount}',
                          color: AppColors.primary,
                          bgColor: AppColors.todoBg,
                          icon: Icons.list_alt_rounded)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _MiniStatBox(
                          label: 'Overdue',
                          value: '${p.overdueTasks.length}',
                          color: p.overdueTasks.isEmpty
                              ? AppColors.completed
                              : AppColors.high,
                          bgColor: p.overdueTasks.isEmpty
                              ? AppColors.completedBg
                              : AppColors.highBg,
                          icon: p.overdueTasks.isEmpty
                              ? Icons.check_circle_outline_rounded
                              : Icons.error_outline_rounded)),
                ]),

                const SizedBox(height: 20),

                // ── COMPLETION OVERVIEW ────────────────────────
                _SectionCard(
                  title: 'Completion Overview',
                  child: Row(children: [
                    // Small ring
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: Stack(alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 80,
                              height: 80,
                              child: CircularProgressIndicator(
                                value: p.completionRate,
                                strokeWidth: 7,
                                strokeCap: StrokeCap.round,
                                backgroundColor:
                                AppColors.completed.withOpacity(0.12),
                                valueColor: AlwaysStoppedAnimation(
                                    AppColors.completed),
                              ),
                            ),
                            Column(mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                      '${(p.completionRate * 100).round()}%',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.5,
                                          color: AppColors.completed)),
                                  Text('done',
                                      style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? AppColors.mutedDark
                                              : AppColors.mutedLight)),
                                ]),
                          ]),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                        child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              _PRow('Completed', p.completedCount,
                                  p.totalCount, AppColors.completed),
                              const SizedBox(height: 10),
                              _PRow('In Progress', p.inProgressCount,
                                  p.totalCount, AppColors.inProgress),
                              const SizedBox(height: 10),
                              _PRow('To Do', p.todoCount,
                                  p.totalCount, AppColors.todo),
                            ])),
                  ]),
                ),

                const SizedBox(height: 12),

                // ── BY PRIORITY ────────────────────────────────
                _SectionCard(
                  title: 'By Priority',
                  child: Row(children: [
                    Expanded(
                        child: _PTile('High', p.highCount,
                            AppColors.highBg, AppColors.high)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _PTile('Medium', p.mediumCount,
                            AppColors.mediumBg, AppColors.medium)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _PTile('Low', p.lowCount,
                            AppColors.lowBg, AppColors.low)),
                  ]),
                ),

                const SizedBox(height: 12),

                // ── 7-DAY ACTIVITY ─────────────────────────────
                _SectionCard(
                  title: '7-Day Activity',
                  child: SizedBox(
                      height: 160,
                      child: _BarChart(data: p.dailyCompletionMap)),
                ),

                const SizedBox(height: 12),

                // ── STATUS DISTRIBUTION ────────────────────────
                if (p.totalCount > 0)
                  _SectionCard(
                    title: 'Status Distribution',
                    child: SizedBox(
                      height: 160,
                      child: Row(children: [
                        Expanded(
                            child: PieChart(PieChartData(
                              sections: [
                                if (p.completedCount > 0)
                                  PieChartSectionData(
                                      value: p.completedCount
                                          .toDouble(),
                                      color: AppColors.completed,
                                      title: '${p.completedCount}',
                                      radius: 52,
                                      titleStyle: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 12)),
                                if (p.inProgressCount > 0)
                                  PieChartSectionData(
                                      value: p.inProgressCount
                                          .toDouble(),
                                      color: AppColors.inProgress,
                                      title:
                                      '${p.inProgressCount}',
                                      radius: 52,
                                      titleStyle: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 12)),
                                if (p.todoCount > 0)
                                  PieChartSectionData(
                                      value: p.todoCount.toDouble(),
                                      color: AppColors.todo,
                                      title: '${p.todoCount}',
                                      radius: 52,
                                      titleStyle: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 12)),
                              ],
                              sectionsSpace: 2,
                              centerSpaceRadius: 28,
                            ))),
                        const SizedBox(width: 20),
                        Column(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              _LI(AppColors.completed, 'Completed'),
                              const SizedBox(height: 8),
                              _LI(AppColors.inProgress, 'In Progress'),
                              const SizedBox(height: 8),
                              _LI(AppColors.todo, 'To Do'),
                            ]),
                      ]),
                    ),
                  ),
              ])),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// MINI STAT BOX
// ═══════════════════════════════════════════════════════════

class _MiniStatBox extends StatelessWidget {
  final String label, value;
  final Color color, bgColor;
  final IconData icon;
  const _MiniStatBox({
    required this.label,
    required this.value,
    required this.color,
    required this.bgColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1.2),
      ),
      child: Row(children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                      color: color)),
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.mutedDark
                          : AppColors.mutedLight)),
            ]),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// SECTION CARD
// ═══════════════════════════════════════════════════════════

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1.2),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: isDark
                        ? AppColors.textDark
                        : AppColors.textLight)),
            const SizedBox(height: 14),
            child,
          ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// PROGRESS ROW
// ═══════════════════════════════════════════════════════════

class _PRow extends StatelessWidget {
  final String label;
  final int count, total;
  final Color color;
  const _PRow(this.label, this.count, this.total, this.color);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pct = total == 0 ? 0.0 : count / total;
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
                child: Text(label,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.mutedDark
                            : AppColors.mutedLight))),
            Text('$count',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color)),
          ]),
          const SizedBox(height: 4),
          ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                  value: pct,
                  minHeight: 4,
                  backgroundColor: color.withOpacity(0.12),
                  valueColor: AlwaysStoppedAnimation(color))),
        ]);
  }
}

// ═══════════════════════════════════════════════════════════
// PRIORITY TILE
// ═══════════════════════════════════════════════════════════

class _PTile extends StatelessWidget {
  final String label;
  final int count;
  final Color color, bg;
  const _PTile(this.label, this.count, this.color, this.bg);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
        horizontal: 10, vertical: 10),
    decoration: BoxDecoration(
        color: bg, borderRadius: BorderRadius.circular(10)),
    child: Column(children: [
      Text('$count',
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: color)),
      const SizedBox(height: 2),
      Text(label,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color)),
    ]),
  );
}

// ═══════════════════════════════════════════════════════════
// BAR CHART
// ═══════════════════════════════════════════════════════════

class _BarChart extends StatelessWidget {
  final Map<String, int> data;
  const _BarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final entries = data.entries.toList();
    final maxVal = data.values.fold(0, (a, b) => a > b ? a : b);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BarChart(BarChartData(
      maxY: (maxVal + 1).toDouble(),
      barGroups: List.generate(
          entries.length,
              (i) => BarChartGroupData(x: i, barRods: [
            BarChartRodData(
                toY: entries[i].value == 0
                    ? 0.15
                    : entries[i].value.toDouble(),
                color: entries[i].value > 0
                    ? AppColors.primary
                    : AppColors.primary.withOpacity(0.1),
                width: 16,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(5)))
          ])),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
            sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i >= entries.length)
                    return const SizedBox();
                  return Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(entries[i].key,
                          style: TextStyle(
                              fontSize: 9,
                              color: isDark
                                  ? AppColors.mutedDark
                                  : AppColors.mutedLight)));
                })),
        leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
              color: isDark
                  ? AppColors.borderDark
                  : AppColors.borderLight,
              strokeWidth: 0.8)),
    ));
  }
}

// ═══════════════════════════════════════════════════════════
// LEGEND ITEM
// ═══════════════════════════════════════════════════════════

class _LI extends StatelessWidget {
  final Color color;
  final String label;
  const _LI(this.color, this.label);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(children: [
      Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
              color: color, shape: BoxShape.circle)),
      const SizedBox(width: 7),
      Text(label,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.mutedDark
                  : AppColors.mutedLight)),
    ]);
  }
}
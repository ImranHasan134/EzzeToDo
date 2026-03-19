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
    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
            floating: true,
            snap: true,
            titleSpacing: 16,
            title: Text('Productivity Stats',
                style: theme.textTheme.headlineMedium)),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          sliver: SliverList(
              delegate: SliverChildListDelegate([
            Row(children: [
              Expanded(
                  child: StatBox(
                      label: 'Completion Rate',
                      value:
                          '${(p.completionRate * 100).round()}%',
                      color: AppColors.primary,
                      bgColor: AppColors.primarySurface)),
              const SizedBox(width: 10),
              Expanded(
                  child: StatBox(
                      label: 'This Week',
                      value: '${p.thisWeekCompleted.length}',
                      color: AppColors.completed,
                      bgColor: AppColors.completedBg)),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                  child: StatBox(
                      label: 'Total Tasks',
                      value: '${p.totalCount}',
                      color: AppColors.todo,
                      bgColor: AppColors.todoBg)),
              const SizedBox(width: 10),
              Expanded(
                  child: StatBox(
                      label: 'Overdue',
                      value: '${p.overdueTasks.length}',
                      color: p.overdueTasks.isEmpty
                          ? AppColors.completed
                          : AppColors.high,
                      bgColor: p.overdueTasks.isEmpty
                          ? AppColors.completedBg
                          : AppColors.highBg)),
            ]),
            const SizedBox(height: 24),
            _Card(
                title: 'Completion Overview',
                child: Row(children: [
                  CircularProgressWidget(
                      value: p.completionRate,
                      size: 100,
                      color: AppColors.completed,
                      centerText:
                          '${(p.completionRate * 100).round()}%',
                      label: 'Completed'),
                  const SizedBox(width: 24),
                  Expanded(
                      child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                        _PRow('Completed', p.completedCount,
                            p.totalCount, AppColors.completed),
                        const SizedBox(height: 12),
                        _PRow('In Progress', p.inProgressCount,
                            p.totalCount, AppColors.inProgress),
                        const SizedBox(height: 12),
                        _PRow('To Do', p.todoCount, p.totalCount,
                            AppColors.todo),
                      ])),
                ])),
            const SizedBox(height: 16),
            _Card(
                title: 'By Priority',
                child: Row(children: [
                  Expanded(
                      child: _PTile('High', p.highCount,
                          AppColors.high, AppColors.highBg)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _PTile('Medium', p.mediumCount,
                          AppColors.medium, AppColors.mediumBg)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _PTile('Low', p.lowCount,
                          AppColors.low, AppColors.lowBg)),
                ])),
            const SizedBox(height: 16),
            _Card(
                title: '7-Day Activity',
                child: SizedBox(
                    height: 180,
                    child:
                        _BarChart(data: p.dailyCompletionMap))),
            const SizedBox(height: 16),
            if (p.totalCount > 0)
              _Card(
                  title: 'Status Distribution',
                  child: SizedBox(
                      height: 200,
                      child: Row(children: [
                        Expanded(
                            child: PieChart(PieChartData(
                              sections: [
                                if (p.completedCount > 0)
                                  PieChartSectionData(
                                      value: p.completedCount
                                          .toDouble(),
                                      color: AppColors.completed,
                                      title:
                                          '${p.completedCount}',
                                      radius: 60,
                                      titleStyle: const TextStyle(
                                          color: Colors.white,
                                          fontWeight:
                                              FontWeight.w700,
                                          fontSize: 13)),
                                if (p.inProgressCount > 0)
                                  PieChartSectionData(
                                      value: p.inProgressCount
                                          .toDouble(),
                                      color:
                                          AppColors.inProgress,
                                      title:
                                          '${p.inProgressCount}',
                                      radius: 60,
                                      titleStyle: const TextStyle(
                                          color: Colors.white,
                                          fontWeight:
                                              FontWeight.w700,
                                          fontSize: 13)),
                                if (p.todoCount > 0)
                                  PieChartSectionData(
                                      value:
                                          p.todoCount.toDouble(),
                                      color: AppColors.todo,
                                      title: '${p.todoCount}',
                                      radius: 60,
                                      titleStyle: const TextStyle(
                                          color: Colors.white,
                                          fontWeight:
                                              FontWeight.w700,
                                          fontSize: 13)),
                              ],
                              sectionsSpace: 3,
                              centerSpaceRadius: 30,
                            ))),
                        const SizedBox(width: 20),
                        Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              _LI(AppColors.completed,
                                  'Completed'),
                              const SizedBox(height: 10),
                              _LI(AppColors.inProgress,
                                  'In Progress'),
                              const SizedBox(height: 10),
                              _LI(AppColors.todo, 'To Do'),
                            ]),
                      ]))),
          ])),
        ),
      ]),
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final Widget child;
  const _Card({required this.title, required this.child});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 1.5)),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Text(title,
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          child,
        ]),
      );
}

class _PRow extends StatelessWidget {
  final String label;
  final int count, total;
  final Color color;
  const _PRow(this.label, this.count, this.total, this.color);

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : count / total;
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
      Row(children: [
        Expanded(
            child: Text(label,
                style: Theme.of(context).textTheme.bodySmall)),
        Text('$count',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color)),
      ]),
      const SizedBox(height: 4),
      ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation(color))),
    ]);
  }
}

class _PTile extends StatelessWidget {
  final String label;
  final int count;
  final Color color, bg;
  const _PTile(this.label, this.count, this.color, this.bg);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          Text('$count',
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: color)),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color)),
        ]),
      );
}

class _BarChart extends StatelessWidget {
  final Map<String, int> data;
  const _BarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final entries = data.entries.toList();
    final maxVal =
        data.values.fold(0, (a, b) => a > b ? a : b);
    return BarChart(BarChartData(
      maxY: (maxVal + 1).toDouble(),
      barGroups: List.generate(
          entries.length,
          (i) => BarChartGroupData(x: i, barRods: [
                BarChartRodData(
                    toY: entries[i].value == 0
                        ? 0.2
                        : entries[i].value.toDouble(),
                    color: entries[i].value > 0
                        ? AppColors.primary
                        : AppColors.primarySurface,
                    width: 20,
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6)))
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
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(entries[i].key,
                          style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color)));
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
              color: Theme.of(context).dividerColor,
              strokeWidth: 1)),
    ));
  }
}

class _LI extends StatelessWidget {
  final Color color;
  final String label;
  const _LI(this.color, this.label);

  @override
  Widget build(BuildContext context) => Row(children: [
        Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
                color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label,
            style: Theme.of(context).textTheme.bodySmall),
      ]);
}

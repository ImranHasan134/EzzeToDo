import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/task_provider.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _isLoaded = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final weekData = provider.last7DaysCompletions;
    final catData = provider.categoryDistribution;
    final maxY = weekData.isEmpty ? 10.0 : (weekData.reduce((a, b) => a > b ? a : b) + 2).toDouble();

    return Scaffold(
      appBar: AppBar(title: const Text('Project Analytics')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          physics: const BouncingScrollPhysics(),
          children: [
            // ── THIS MONTH'S OVERVIEW ──
            const Text('This Month\'s Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _MonthStatCard(title: 'Total Tasks', value: provider.thisMonthTotalTasks, color: isDark ? Colors.white : Colors.black87)),
                const SizedBox(width: 12),
                Expanded(child: _MonthStatCard(title: 'To Do', value: provider.thisMonthTodoTasks, color: Colors.blueAccent)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _MonthStatCard(title: 'In Progress', value: provider.thisMonthRunningTasks, color: Colors.orangeAccent)),
                const SizedBox(width: 12),
                Expanded(child: _MonthStatCard(title: 'Completed', value: provider.thisMonthCompletedTasks, color: theme.colorScheme.primary)),
              ],
            ),
            const SizedBox(height: 40),

            // ── BAR CHART (7 Days) ──
            const Text('Tasks Completed (Last 7 Days)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 24),
            Container(
              height: 250,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.dividerColor)
              ),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final days = ['6d', '5d', '4d', '3d', '2d', '1d', 'Today'];
                          return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(days[value.toInt()], style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 10, fontWeight: FontWeight.w600))
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: weekData.asMap().entries.map((e) {
                    return BarChartGroupData(
                      x: e.key,
                      barRods: [
                        BarChartRodData(
                          toY: _isLoaded ? e.value.toDouble() : 0,
                          color: theme.colorScheme.primary,
                          width: 16,
                          borderRadius: BorderRadius.circular(4),
                          backDrawRodData: BackgroundBarChartRodData(show: true, toY: maxY, color: theme.dividerColor.withOpacity(0.5)),
                        )
                      ],
                    );
                  }).toList(),
                ),
                swapAnimationDuration: const Duration(milliseconds: 800),
                swapAnimationCurve: Curves.easeOutCubic,
              ),
            ),

            const SizedBox(height: 40),

            // ── PIE CHART (Categories) ──
            const Text('Task Distribution', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 24),
            Container(
              height: 250,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.dividerColor)
              ),
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 4,
                        centerSpaceRadius: 40,
                        sections: [
                          PieChartSectionData(
                              color: Colors.blueAccent,
                              value: catData['Workspace']!.toDouble(),
                              title: '${catData['Workspace']}',
                              radius: _isLoaded ? 50 : 0,
                              showTitle: _isLoaded && catData['Workspace']! > 0,
                              titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
                          ),
                          PieChartSectionData(
                              color: Colors.purpleAccent,
                              value: catData['Portfolio']!.toDouble(),
                              title: '${catData['Portfolio']}',
                              radius: _isLoaded ? 50 : 0,
                              showTitle: _isLoaded && catData['Portfolio']! > 0,
                              titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
                          ),
                          PieChartSectionData(
                              color: Colors.orangeAccent,
                              value: catData['Personal']!.toDouble(),
                              title: '${catData['Personal']}',
                              radius: _isLoaded ? 50 : 0,
                              showTitle: _isLoaded && catData['Personal']! > 0,
                              titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
                          ),
                        ],
                      ),
                      swapAnimationDuration: const Duration(milliseconds: 800),
                      swapAnimationCurve: Curves.easeOutBack,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Indicator(color: Colors.blueAccent, text: 'Workspace'),
                      const SizedBox(height: 12),
                      _Indicator(color: Colors.purpleAccent, text: 'Portfolio'),
                      const SizedBox(height: 12),
                      _Indicator(color: Colors.orangeAccent, text: 'Personal'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 🔴 NEW SUB-WIDGET FOR THE MONTHLY STATS
class _MonthStatCard extends StatelessWidget {
  final String title;
  final int value;
  final Color color;

  const _MonthStatCard({required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Text('$value', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: color, height: 1)),
        ],
      ),
    );
  }
}

class _Indicator extends StatelessWidget {
  final Color color;
  final String text;
  const _Indicator({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
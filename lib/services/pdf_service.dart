import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class PdfService {
  static Future<void> exportTaskReport(TaskProvider provider, String userName) async {
    final doc = pw.Document();

    final allTasks = provider.allTasks;
    final todo = allTasks.where((t) => t.status == TaskStatus.todo).toList();
    final inProgress = allTasks.where((t) => t.status == TaskStatus.inProgress).toList();
    final completed = allTasks.where((t) => t.status == TaskStatus.completed).toList();
    final catData = provider.categoryDistribution;

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader(userName),
        footer: (context) => _buildFooter(context),
        build: (context) {
          return [
            pw.SizedBox(height: 20),
            _buildSummaryAndChart(catData, allTasks.length),
            pw.SizedBox(height: 30),
            if (inProgress.isNotEmpty) _buildTaskList('Running / In Progress', inProgress, PdfColors.orange),
            if (inProgress.isNotEmpty) pw.SizedBox(height: 20),
            if (todo.isNotEmpty) _buildTaskList('To Do / Pending', todo, PdfColors.blue),
            if (todo.isNotEmpty) pw.SizedBox(height: 20),
            if (completed.isNotEmpty) _buildTaskList('Completed', completed, PdfColors.green),
          ];
        },
      ),
    );

    // This opens the native device PDF preview/print/share dialog
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'TaskFlow_Report_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  static pw.Widget _buildHeader(String userName) {
    final now = DateTime.now();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('TaskFlow Executive Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800)),
            pw.Text('Date: ${now.month}/${now.day}/${now.year}', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Text('Generated for: $userName', style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey800)),
        pw.SizedBox(height: 12),
        pw.Divider(color: PdfColors.grey400, thickness: 1.5),
      ],
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 16),
      child: pw.Text(
        'Page ${context.pageNumber} of ${context.pagesCount}',
        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
      ),
    );
  }

  static pw.Widget _buildSummaryAndChart(Map<String, int> catData, int totalTasks) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Category Distribution', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 12),
                _buildLegendItem('Workspace', catData['Workspace']!, totalTasks, PdfColors.blue),
                pw.SizedBox(height: 4),
                _buildLegendItem('Portfolio', catData['Portfolio']!, totalTasks, PdfColors.purple),
                pw.SizedBox(height: 4),
                _buildLegendItem('Personal', catData['Personal']!, totalTasks, PdfColors.orange),
              ],
            ),
          ),
          pw.Container(
            height: 120,
            width: 120,
            child: pw.Chart(
              grid: pw.PieGrid(),
              datasets: [
                pw.PieDataSet(value: catData['Workspace']!.toDouble(), color: PdfColors.blue, legend: 'Workspace'),
                pw.PieDataSet(value: catData['Portfolio']!.toDouble(), color: PdfColors.purple, legend: 'Portfolio'),
                pw.PieDataSet(value: catData['Personal']!.toDouble(), color: PdfColors.orange, legend: 'Personal'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildLegendItem(String title, int count, int total, PdfColor color) {
    final pct = total == 0 ? 0 : ((count / total) * 100).toStringAsFixed(1);
    return pw.Row(
      children: [
        pw.Container(width: 10, height: 10, decoration: pw.BoxDecoration(shape: pw.BoxShape.circle, color: color)),
        pw.SizedBox(width: 8),
        pw.Text('$title: $count tasks ($pct%)', style: const pw.TextStyle(fontSize: 12)),
      ],
    );
  }

  static pw.Widget _buildTaskList(String title, List<Task> tasks, PdfColor headerColor) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: headerColor)),
        pw.SizedBox(height: 8),
        pw.TableHelper.fromTextArray(
          headers: ['Task Name', 'Category', 'Priority', 'Due Date', 'Progress'],
          data: tasks.map((t) {
            final due = t.deadline != null ? '${t.deadline!.month}/${t.deadline!.day}/${t.deadline!.year}' : 'No Date';
            return [
              t.title,
              t.safeCategory.name.toUpperCase(),
              t.priority.name.toUpperCase(),
              due,
              '${t.progress}%'
            ];
          }).toList(),
          border: null,
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 10),
          headerDecoration: pw.BoxDecoration(color: headerColor, borderRadius: const pw.BorderRadius.vertical(top: pw.Radius.circular(6))),
          cellStyle: const pw.TextStyle(fontSize: 10),
          cellPadding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5))),
          cellAlignment: pw.Alignment.centerLeft,
          columnWidths: {
            0: const pw.FlexColumnWidth(3),
            1: const pw.FlexColumnWidth(1.5),
            2: const pw.FlexColumnWidth(1.5),
            3: const pw.FlexColumnWidth(1.5),
            4: const pw.FlexColumnWidth(1),
          },
        ),
      ],
    );
  }
}
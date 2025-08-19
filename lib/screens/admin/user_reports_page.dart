import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planit_mt/models/report_model.dart';
import 'package:planit_mt/providers/report_provider.dart';
import 'package:provider/provider.dart';

class UserReportsPage extends StatelessWidget {
  const UserReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final reportProvider = context.watch<ReportProvider>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('User Reports'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Open Reports'),
              Tab(text: 'Resolved'),
            ],
            labelColor: Colors.black,
            indicatorColor: Color(0xFFBFA054),
          ),
        ),
        body: StreamBuilder<List<Report>>(
          stream: reportProvider.reportsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No reports found."));
            }
            final allReports = snapshot.data!;
            final openReports =
                allReports.where((r) => r.status == ReportStatus.open).toList();
            final resolvedReports = allReports
                .where((r) => r.status == ReportStatus.resolved)
                .toList();

            return TabBarView(
              children: [
                _buildReportsList(context, openReports),
                _buildReportsList(context, resolvedReports),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildReportsList(BuildContext context, List<Report> reports) {
    if (reports.isEmpty) {
      return const Center(child: Text('No reports in this category.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ExpansionTile(
            leading: Icon(
              report.status == ReportStatus.resolved
                  ? Icons.check_circle
                  : Icons.error_outline,
              color: report.status == ReportStatus.resolved
                  ? Colors.green
                  : Colors.red,
            ),
            title: Text(report.reason,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Against: ${report.reportedVendorName}'),
            trailing: Text(DateFormat('dd/MM/yy').format(report.timestamp.toDate())),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Reported by (ID): ${report.reporterId}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(report.details.isNotEmpty
                        ? report.details
                        : 'No additional details provided.'),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            final newStatus =
                                report.status == ReportStatus.open
                                    ? ReportStatus.resolved
                                    : ReportStatus.open;
                            context
                                .read<ReportProvider>()
                                .updateReportStatus(report.id, newStatus);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                report.status == ReportStatus.resolved
                                    ? Colors.grey
                                    : Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(report.status == ReportStatus.resolved
                              ? 'Re-Open'
                              : 'Mark as Resolved'),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

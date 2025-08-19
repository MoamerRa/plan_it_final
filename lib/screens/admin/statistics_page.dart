import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planit_mt/models/vendor/app_vendor.dart';
import 'package:planit_mt/screens/admin/platform_stats_model.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  @override
  void initState() {
    super.initState();
    // מזניקים את הטעינות ברגע שהדף נפתח
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final admin = context.read<AdminProvider>();
      admin.fetchPlatformStats();
      // אם ה־Avg Rating נשען על רשימת ספקים – נטען גם אותה אם ריקה
      if (admin.allVendors.isEmpty) admin.fetchAllVendors();
    });
  }

  Future<void> _refresh() async {
    final admin = context.read<AdminProvider>();
    await Future.wait([
      admin.fetchPlatformStats(),
      admin.fetchAllVendors(),
    ]);
  }

  double _calculateAverageRating(List<AppVendor> vendors) {
    if (vendors.isEmpty) return 0.0;
    final rated = vendors.where((v) => v.rating > 0).toList();
    if (rated.isEmpty) return 0.0;
    final sum = rated.fold<double>(0.0, (s, v) => s + v.rating);
    return sum / rated.length;
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();
    final stats = adminProvider.stats;
    final averageRating = _calculateAverageRating(adminProvider.allVendors);

    // שגיאה גלובלית? הצג עם Retry
    if (adminProvider.error != null && stats == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Platform Statistics'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Failed to load platform statistics.\n${adminProvider.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _refresh,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try again'),
                )
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text('Platform Statistics'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
        ],
      ),
      body: (adminProvider.isLoading && stats == null)
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(stats?.totalUsers ?? 0),
                    const SizedBox(height: 24),
                    _buildLineChart(),
                    const SizedBox(height: 24),
                    const Text(
                      "Key Metrics",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    if (stats != null)
                      _buildMetricsGrid(stats, averageRating)
                    else
                      const Text('No stats yet. Pull to refresh.'),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader(int totalUsers) {
    /* כמו אצלך */ /* ... */ return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(DateFormat('MMMM yyyy').format(DateTime.now()),
            style: TextStyle(color: Colors.grey[600], fontSize: 16)),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(NumberFormat.compact().format(totalUsers),
                style:
                    const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            const Text("Total Users",
                style: TextStyle(fontSize: 20, color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _buildLineChart() {
    /* כמו אצלך */ /* ... */ return AspectRatio(
      aspectRatio: 1.7,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: const Color(0xFF1E2742),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      const style =
                          TextStyle(color: Colors.white70, fontSize: 12);
                      switch (value.toInt()) {
                        case 0:
                          return const Text('Oct', style: style);
                        case 1:
                          return const Text('Nov', style: style);
                        case 2:
                          return const Text('Dec', style: style);
                        case 3:
                          return const Text('Jan', style: style);
                        default:
                          return const Text('');
                      }
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: const [
                    FlSpot(0, 1.5),
                    FlSpot(1, 2.5),
                    FlSpot(2, 2.2),
                    FlSpot(3, 3.5)
                  ],
                  isCurved: true,
                  color: Colors.amber,
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        Colors.amber.withOpacity(0.3),
                        Colors.amber.withOpacity(0.0)
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(PlatformStats stats, double averageRating) {
    /* כמו אצלך */ /* ... */
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildMetricCard(
            title: "Total Vendors",
            value: stats.totalVendors.toString(),
            icon: Icons.store,
            color: Colors.blue),
        _buildMetricCard(
            title: "Events Planned",
            value: stats.eventsPlanned.toString(),
            icon: Icons.celebration,
            color: Colors.orange),
        _buildMetricCard(
            title: "Pending Vendors",
            value: stats.pendingVendors.toString(),
            icon: Icons.pending_actions,
            color: Colors.purple),
        _buildMetricCard(
            title: "Avg. Rating",
            value: "${averageRating.toStringAsFixed(1)} ★",
            icon: Icons.star,
            color: Colors.amber),
      ],
    );
  }

  Widget _buildMetricCard(
      {required String title,
      required String value,
      required IconData icon,
      required Color color}) {
    /* כמו אצלך */ /* ... */
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 32, color: color),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                Text(title, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

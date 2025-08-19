import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../providers/guest_provider.dart';
import 'legend_dot.dart';

class GuestPieChart extends StatelessWidget {
  const GuestPieChart({super.key});

  @override
  Widget build(BuildContext context) {
    // Connect to the GuestProvider to get real data
    final guestProvider = context.watch<GuestProvider>();

    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/guestList'),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 150,
            width: 150,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 0,
                // Build sections from the provider's data
                sections: [
                  PieChartSectionData(
                    value: guestProvider.confirmedCount.toDouble(),
                    color: const Color(0xFF941B2E),
                    title: '${guestProvider.confirmedCount}',
                    radius: 60,
                    titleStyle: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  PieChartSectionData(
                    value: guestProvider.pendingCount.toDouble(),
                    color: const Color(0xFFD5B04C),
                    title: '${guestProvider.pendingCount}',
                    radius: 60,
                    titleStyle: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  PieChartSectionData(
                    value: guestProvider.declinedCount.toDouble(),
                    color: Colors.grey[400],
                    title: '${guestProvider.declinedCount}',
                    radius: 60,
                    titleStyle: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Total Guests',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  '${guestProvider.totalCount}',
                  style: const TextStyle(
                    fontSize: 28,
                    color: Color(0xFFD5B04C),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const LegendDot(color: Color(0xFF941B2E), text: 'Confirmed'),
                const SizedBox(height: 8),
                const LegendDot(color: Color(0xFFD5B04C), text: 'Pending'),
                const SizedBox(height: 8),
                LegendDot(color: Colors.grey[400]!, text: 'Declined'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

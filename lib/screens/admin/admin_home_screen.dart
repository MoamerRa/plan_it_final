import 'package:flutter/material.dart';
import 'package:planit_mt/models/admin/app_admin.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart'; // Import AuthProvider for logout

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen for changes in AdminProvider
    final adminProvider = context.watch<AdminProvider>();
    final admin = adminProvider.admin ??
        AdminModel(id: 'ad_001', name: 'Admin', email: 'admin@planit.com');

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text('Admin Panel',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined, color: Colors.black),
            tooltip: 'Logout',
            onPressed: () async {
              // Perform logout and navigate to welcome screen
              await context.read<AuthProvider>().signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/', (route) => false);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headerSection(admin.name),
            const SizedBox(height: 24),
            _buildQuickStats(adminProvider),
            const SizedBox(height: 24),
            const Text(
              "System Management",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildDashboardCard(context,
                    title: 'Approve Vendors',
                    icon: Icons.verified_user_outlined,
                    color: Colors.green,
                    route: '/approveVendors'),
                // ================== התיקון כאן ==================
                // The route name was corrected from '/manageVendors' to '/managevendors'
                _buildDashboardCard(context,
                    title: 'Manage Vendors',
                    icon: Icons.store_mall_directory_outlined,
                    color: Colors.blue,
                    route: '/managevendors'),
                // ===============================================
                _buildDashboardCard(context,
                    title: 'View Statistics',
                    icon: Icons.bar_chart_outlined,
                    color: Colors.purple,
                    route: '/statistics'),
                _buildDashboardCard(context,
                    title: 'User Reports',
                    icon: Icons.flag_outlined,
                    color: Colors.red,
                    route: '/reports'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerSection(String adminName) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: Color(0xFFBFA054),
              child: Icon(Icons.admin_panel_settings,
                  size: 30, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Welcome Back,", style: TextStyle(fontSize: 16)),
                Text(
                  adminName,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(AdminProvider adminProvider) {
    // If data is still loading, show temporary text
    if (adminProvider.isLoading && adminProvider.stats == null) {
      return const Center(child: Text("Loading stats..."));
    }

    // Display the real data
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _StatItem(
            count: adminProvider.pendingVendors.length.toString(),
            label: 'Pending Vendors'),
        _StatItem(
            count: adminProvider.stats?.totalUsers.toString() ?? 'N/A',
            label: 'Total Users'),
        const _StatItem(count: '3', label: 'Open Reports'), // Dummy data
      ],
    );
  }

  Widget _buildDashboardCard(BuildContext context,
      {required String title,
      required IconData icon,
      required Color color,
      required String route}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String count;
  final String label;

  const _StatItem({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }
}

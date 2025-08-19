import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/vendor/app_vendor.dart';
import '../../providers/admin_provider.dart';

class ManageVendorsPage extends StatefulWidget {
  const ManageVendorsPage({super.key});

  @override
  State<ManageVendorsPage> createState() => _ManageVendorsPageState();
}

class _ManageVendorsPageState extends State<ManageVendorsPage> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load ONLY vendors for this page (do not call fetchAllData which also loads stats)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AdminProvider>().fetchAllVendors();
    });
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    await context.read<AdminProvider>().fetchAllVendors();
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();
    final allVendors = adminProvider.allVendors;

    // Filter the list based on the search query
    final filteredVendors = allVendors.where((vendor) {
      return vendor.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Vendors'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh List',
            onPressed: _refresh, // vendors-only refresh
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search by vendor name...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          Expanded(child: _buildContent(adminProvider, filteredVendors)),
        ],
      ),
    );
  }

  /// Builds the main content based on the provider's state (loading, error, empty, data).
  Widget _buildContent(AdminProvider provider, List<AppVendor> vendors) {
    // Loading while fetching vendors
    if (provider.isLoading && vendors.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // IMPORTANT: Scope the error to this page.
    // Show error only if vendors list is empty; ignore unrelated errors (e.g., stats).
    if (provider.error != null && vendors.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'An error occurred: ${provider.error}\nPlease try refreshing.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      );
    }

    if (vendors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? 'No vendors found in the system.'
                  : 'No vendors match your search.',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: vendors.length,
        itemBuilder: (context, index) {
          final vendor = vendors[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(
                  vendor.imageUrl.isNotEmpty
                      ? vendor.imageUrl
                      : 'https://placehold.co/150/EFEFEF/AAAAAA&text=No+Image',
                ),
                onBackgroundImageError: (_, __) {},
              ),
              title: Text(vendor.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(vendor.category),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Tooltip(
                    message:
                        vendor.isApproved ? 'Approved' : 'Pending Approval',
                    child: Icon(
                      vendor.isApproved
                          ? Icons.check_circle
                          : Icons.pending_actions,
                      color: vendor.isApproved ? Colors.green : Colors.orange,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    tooltip: 'Delete Vendor',
                    onPressed: () => _confirmDelete(
                        context, context.read<AdminProvider>(), vendor),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, AdminProvider provider, AppVendor vendor) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text(
              'Are you sure you want to delete the vendor "${vendor.name}"? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                provider.deleteVendor(vendor.vendorId);
              },
            ),
          ],
        );
      },
    );
  }
}

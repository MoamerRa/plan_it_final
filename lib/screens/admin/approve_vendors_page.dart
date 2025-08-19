import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:planit_mt/providers/admin_provider.dart';

/// Version that avoids "use_build_context_synchronously" lints
/// by capturing objects before awaits + guarding with `mounted`.
class ApproveVendorsPage extends StatefulWidget {
  const ApproveVendorsPage({super.key});

  @override
  State<ApproveVendorsPage> createState() => _ApproveVendorsPageState();
}

class _ApproveVendorsPageState extends State<ApproveVendorsPage> {
  // track vendorIds that are currently being processed (approve/decline)
  final Set<String> _processing = <String>{};

  Future<void> _refresh() async {
    if (!mounted) return;
    final admin = context.read<AdminProvider>(); // capture before await
    await admin.fetchPendingVendors();
  }

  Future<void> _approve(String vendorId) async {
    setState(() => _processing.add(vendorId));
    if (!mounted) return; // in case widget disposed during setState microtask
    final admin = context.read<AdminProvider>(); // capture before await
    final messenger = ScaffoldMessenger.of(context); // capture before await

    try {
      await admin.approveVendor(vendorId);
      // No direct context use after await; using captured messenger
      messenger.showSnackBar(const SnackBar(content: Text('Vendor approved')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Failed to approve: $e')));
    } finally {
      if (mounted) setState(() => _processing.remove(vendorId));
    }
  }

  Future<void> _decline(String vendorId) async {
    setState(() => _processing.add(vendorId));
    if (!mounted) return;
    final admin = context.read<AdminProvider>();
    final messenger = ScaffoldMessenger.of(context);

    try {
      await admin.declineVendor(vendorId);
      messenger.showSnackBar(const SnackBar(content: Text('Vendor declined')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Failed to decline: $e')));
    } finally {
      if (mounted) setState(() => _processing.remove(vendorId));
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Approve New Vendors'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: adminProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : adminProvider.pendingVendors.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline,
                          size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No vendors waiting for approval.',
                          style: TextStyle(fontSize: 18, color: Colors.grey)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(12),
                    itemCount: adminProvider.pendingVendors.length,
                    itemBuilder: (context, index) {
                      final vendor = adminProvider.pendingVendors[index];
                      final bool isProcessing =
                          _processing.contains(vendor.vendorId);

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    (vendor.imageUrl).isNotEmpty
                                        ? vendor.imageUrl
                                        : 'https://placehold.co/128x128?text=${Uri.encodeComponent(vendor.name.isNotEmpty ? vendor.name[0] : 'V')}',
                                  ),
                                ),
                                title: Text(
                                  vendor.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(vendor.category),
                              ),
                              const Divider(),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: isProcessing
                                    ? const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 3),
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          TextButton.icon(
                                            icon: const Icon(Icons.close,
                                                color: Colors.red),
                                            label: const Text('Decline',
                                                style: TextStyle(
                                                    color: Colors.red)),
                                            onPressed: () =>
                                                _decline(vendor.vendorId),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton.icon(
                                            icon: const Icon(Icons.check,
                                                color: Colors.white),
                                            label: const Text('Approve'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              foregroundColor: Colors.white,
                                            ),
                                            onPressed: () =>
                                                _approve(vendor.vendorId),
                                          ),
                                        ],
                                      ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

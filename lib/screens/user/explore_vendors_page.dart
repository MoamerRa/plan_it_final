import 'package:flutter/material.dart';
import 'package:planit_mt/providers/event_provider.dart';
import 'package:planit_mt/providers/package_provider.dart';
import 'package:planit_mt/services/booking_service.dart';
import 'package:provider/provider.dart';
import '../../models/vendor/app_vendor.dart';
import '../../providers/vendor_provider.dart';

class ExploreVendorsPage extends StatefulWidget {
  const ExploreVendorsPage({super.key});

  @override
  State<ExploreVendorsPage> createState() => _ExploreVendorsPageState();
}

class _ExploreVendorsPageState extends State<ExploreVendorsPage> {
  final List<String> _categories = const [
    'All',
    'Hall',
    'DJ',
    'Catering',
    'Photography',
    'Clothing',
    'Decor',
    'Makeup',
  ];

  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  Set<String> _unavailableVendorIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // We must have an event to check availability, so we fetch vendors after checking for an event.
      final activeEvent = context.read<EventProvider>().activeEvent;
      if (activeEvent != null) {
        context.read<VendorProvider>().fetchApprovedVendors();
        _checkVendorAvailability();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    // When refreshing, we need to re-fetch vendors AND their availability
    await context.read<VendorProvider>().fetchApprovedVendors();
    await _checkVendorAvailability();
  }

  /// Checks which vendors are already booked on the user's active event date.
  Future<void> _checkVendorAvailability() async {
    final activeEvent = context.read<EventProvider>().activeEvent;
    if (activeEvent == null) return; // No date to check against

    final bookingService = BookingService();
    final confirmedBookings =
        await bookingService.getConfirmedBookingsForDate(activeEvent.date);

    if (mounted) {
      setState(() {
        _unavailableVendorIds =
            confirmedBookings.map((b) => b.vendorId).toSet();
      });
    }
  }

  List<AppVendor> _filterVendors(List<AppVendor> allVendors) {
    final q = _searchController.text.trim().toLowerCase();
    final cat = _selectedCategory.trim().toLowerCase();

    return allVendors.where((v) {
      final name = v.name.trim().toLowerCase();
      final vcat = v.category.trim().toLowerCase();
      final matchesCategory = (cat == 'all') || (vcat == cat);
      final matchesSearch = q.isEmpty || name.contains(q);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final vendorProvider = context.watch<VendorProvider>();
    final eventProvider = context.watch<EventProvider>();
    final allVendors = vendorProvider.approvedVendors;
    final filteredVendors = _filterVendors(allVendors);
    final packageProvider = context.watch<PackageProvider>();

    // NEW: Show a prompt if no event is created yet.
    if (eventProvider.activeEvent == null) {
      return _buildCreateEventPrompt(context);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Explore Vendors',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _refresh,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryChips(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: _buildContent(vendorProvider, filteredVendors),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/packageBuilder'),
        label: const Text('My Package'),
        icon: Badge(
          label: Text('${packageProvider.selectedVendors.length}'),
          isLabelVisible: packageProvider.selectedVendors.isNotEmpty,
          child: const Icon(Icons.shopping_basket_outlined),
        ),
      ),
    );
  }

  // NEW WIDGET
  Widget _buildCreateEventPrompt(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explore Vendors')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.calendar_month, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'First, let\'s set up your event!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'You need to choose a date for your event before you can see available vendors.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  // Navigate to create event page and wait for a result
                  final eventCreated =
                      await Navigator.pushNamed(context, '/createEvent');
                  // If an event was created, reload the data on this page
                  if (eventCreated == true && mounted) {
                    _refresh();
                  }
                },
                child: const Text('Create Your Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search vendors...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: _categories.map((category) {
          final selected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(category),
              selected: selected,
              onSelected: (_) => setState(() => _selectedCategory = category),
              selectedColor: const Color(0xFFBFA054),
              backgroundColor: Colors.grey[200],
              labelStyle: TextStyle(
                color: selected ? Colors.white : Colors.black,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContent(VendorProvider provider, List<AppVendor> vendors) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(provider.error!, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            )
          ],
        ),
      );
    }
    if (vendors.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Icon(Icons.search_off, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Center(
            child: Text('No vendors found',
                style: TextStyle(fontSize: 18, color: Colors.grey)),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: vendors.length,
      itemBuilder: (context, index) {
        final vendor = vendors[index];
        return _buildVendorCard(context, vendor);
      },
    );
  }

  Widget _buildVendorCard(BuildContext context, AppVendor vendor) {
    final packageProvider = context.read<PackageProvider>();
    final isAdded = packageProvider.isVendorInPackage(vendor);
    final isUnavailable = _unavailableVendorIds.contains(vendor.vendorId);
    final imageUrl = vendor.imageUrl.isNotEmpty
        ? vendor.imageUrl
        : 'https://placehold.co/600x400?text=No+Image';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: InkWell(
        onTap: () =>
            Navigator.pushNamed(context, '/vendordetails', arguments: vendor),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                imageUrl,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => Container(
                  height: 160,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image,
                      color: Colors.grey, size: 40),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(vendor.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(
                            '${vendor.category} • ₪${vendor.price.toStringAsFixed(0)}'),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 16),
                            Text('${vendor.rating}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: isUnavailable
                        ? null
                        : () {
                            if (isAdded) {
                              packageProvider.removeVendor(vendor);
                            } else {
                              packageProvider.addVendor(vendor);
                            }
                          },
                    icon: Icon(isUnavailable
                        ? Icons.block
                        : (isAdded ? Icons.check : Icons.add_shopping_cart)),
                    label: Text(
                        isUnavailable ? 'Booked' : (isAdded ? 'Added' : 'Add')),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: isUnavailable
                            ? Colors.red.shade300
                            : (isAdded
                                ? Colors.grey
                                : const Color(0xFFBFA054))),
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

import 'package:flutter/material.dart';
import 'package:planit_mt/models/user/recommendationmodel.dart';
import 'package:planit_mt/providers/event_provider.dart';
import 'package:planit_mt/providers/recommendationprovider.dart';
import 'package:planit_mt/providers/vendor_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class RecommendedPackagesPage extends StatefulWidget {
  const RecommendedPackagesPage({super.key});

  @override
  State<RecommendedPackagesPage> createState() =>
      _RecommendedPackagesPageState();
}

class _RecommendedPackagesPageState extends State<RecommendedPackagesPage> {
  DateTime? _selectedDate;
  final _budgetController = TextEditingController();
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to access context safely in initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Pre-fill form fields if an active event exists
      final activeEvent = context.read<EventProvider>().activeEvent;
      if (activeEvent != null) {
        setState(() {
          _selectedDate = activeEvent.date;
          _budgetController.text = activeEvent.totalBudget.toStringAsFixed(0);
        });
      }
    });
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final budget = double.tryParse(_budgetController.text.trim());
    if (_selectedDate == null || budget == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please provide a valid date and budget.")),
      );
      return;
    }

    // Get the necessary providers
    final recommendationProvider = context.read<RecommendationProvider>();
    final vendorProvider = context.read<VendorProvider>();

    // Call the generation logic with real data
    await recommendationProvider.generateRecommendations(
      allApprovedVendors: vendorProvider.approvedVendors,
      date: _selectedDate!,
      budget: budget,
      preferredCategory: _selectedCategory,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch for changes in the recommendation provider
    final recommendationProvider = context.watch<RecommendationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Package Recommendations'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildForm(context),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          _buildResults(recommendationProvider),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Find Your Perfect Package',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        // Date Picker
        ListTile(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          title: Text(_selectedDate == null
              ? 'Choose Event Date'
              : DateFormat('dd/MM/yyyy').format(_selectedDate!)),
          trailing: const Icon(Icons.calendar_today),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              firstDate: DateTime.now(),
              lastDate: DateTime(2030),
              initialDate: _selectedDate ?? DateTime.now(),
            );
            if (picked != null) {
              setState(() => _selectedDate = picked);
            }
          },
        ),
        const SizedBox(height: 12),
        // Budget input
        TextField(
          controller: _budgetController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Enter Your Budget (₪)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: context.watch<RecommendationProvider>().isLoading
              ? null
              : _generate,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
          child: const Text("Generate Recommendations"),
        ),
      ],
    );
  }

  Widget _buildResults(RecommendationProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Building your dream packages..."),
          ],
        ),
      );
    }

    if (provider.recommendations.isEmpty) {
      return const Center(
        child:
            Text("No packages found for your criteria. Try a larger budget."),
      );
    }

    return Column(
      children: provider.recommendations
          .map((pkg) => _buildPackageCard(pkg))
          .toList(),
    );
  }

  Widget _buildPackageCard(RecommendedPackage package) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'he_IL', symbol: '₪', decimalDigits: 0);
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(package.name,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Date: ${DateFormat('dd/MM/yyyy').format(package.date)}'),
            Text(
                'Total Price: ${currencyFormatter.format(package.totalPrice)}'),
            const Divider(height: 24),
            const Text('Included Vendors:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            ...package.vendors.map((v) => ListTile(
                  leading: const Icon(Icons.business_center),
                  title: Text(v.name),
                  subtitle: Text(v.category),
                )),
          ],
        ),
      ),
    );
  }
}

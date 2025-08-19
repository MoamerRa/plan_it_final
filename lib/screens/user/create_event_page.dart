import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../models/vendor/app_vendor.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _budgetController = TextEditingController();
  DateTime? _selectedDate;

  AppVendor? _selectedVendor; // NEW: optional vendor coming from Explore

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Accept an optional vendor passed via Navigator arguments
    final args = ModalRoute.of(context)?.settings.arguments;
    if (_selectedVendor == null && args is Map && args['vendor'] != null) {
      try {
        _selectedVendor = AppVendor.fromJson(
            Map<String, dynamic>.from(args['vendor'] as Map));
      } catch (_) {
        // ignore malformed payloads
      }
      // If vendor has a suggested date (not typical), you could also read it here
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  Future<void> _submitForm() async {
    final form = _formKey.currentState;
    if (form == null) return;

    if (!form.validate()) return;

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date for the event.')),
      );
      return;
    }

    final eventProvider = context.read<EventProvider>();
    final userId = context.read<AuthProvider>().firebaseUser?.uid;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: User not logged in.')),
      );
      return;
    }

    final budget = double.tryParse(_budgetController.text.trim());
    if (budget == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid budget amount.')),
      );
      return;
    }

    // Optionally you could add vendorId into the event if your backend supports it.
    // Kept minimal to avoid breaking EventProvider API.
    final error = await eventProvider.createNewEvent(
      title: _titleController.text.trim(),
      date: _selectedDate!,
      totalBudget: budget,
      userId: userId,
      // You can extend EventProvider to accept vendorId if needed:
      // vendorId: _selectedVendor?.vendorId,
    );

    if (!mounted) return;

    if (error == null) {
      // Navigate to home (your original behavior) or to calendar/summary
      Navigator.pushNamedAndRemoveUntil(context, '/userHome', (route) => false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event created successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<EventProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Your Event'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_selectedVendor != null)
                _SelectedVendorBanner(vendorName: _selectedVendor!.name),
              if (_selectedVendor != null) const SizedBox(height: 12),
              TextFormField(
                controller: _titleController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Event Title',
                  hintText: 'e.g., My Wedding, Birthday Party',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Please enter a title'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _budgetController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Total Budget (₪)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a budget';
                  }
                  final v = double.tryParse(value.trim());
                  if (v == null || v < 0) return 'Please enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                title: Text(
                  _selectedDate == null
                      ? 'Select Event Date'
                      : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Create Event'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedVendorBanner extends StatelessWidget {
  final String vendorName;
  const _SelectedVendorBanner({required this.vendorName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF7E0),
        border: Border.all(color: const Color(0xFFF3D27F)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.storefront, color: Color(0xFFBFA054)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Selected vendor: $vendorName',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

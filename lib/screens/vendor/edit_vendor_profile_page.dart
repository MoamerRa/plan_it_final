import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/vendor/app_vendor.dart';
import '../../providers/vendor_provider.dart';

class EditVendorProfilePage extends StatefulWidget {
  const EditVendorProfilePage({super.key});

  @override
  State<EditVendorProfilePage> createState() => _EditVendorProfilePageState();
}

class _EditVendorProfilePageState extends State<EditVendorProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;

  String? _selectedCategory;

  final List<String> _categories = [
    'Hall',
    'DJ',
    'Catering',
    'Photography',
    'Clothing',
    'Decor',
    'Makeup'
  ];

  final List<File> _newGalleryImages = [];

  @override
  void initState() {
    super.initState();
    final vendor = Provider.of<VendorProvider>(context, listen: false).vendor;
    _descriptionController =
        TextEditingController(text: vendor?.description ?? '');
    _priceController =
        TextEditingController(text: vendor?.price.toString() ?? '0.0');

    _selectedCategory = vendor?.category;
    if (!_categories.contains(_selectedCategory)) {
      _selectedCategory = null;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // --- REVERTED: Back to a simple gallery picker ---
  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _newGalleryImages.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category.')),
      );
      return;
    }

    final vendorProvider = context.read<VendorProvider>();
    final price = double.tryParse(_priceController.text) ?? 0.0;

    final error = await vendorProvider.updateProfile(
      description: _descriptionController.text,
      price: price,
      category: _selectedCategory!,
      newGalleryImages: _newGalleryImages,
    );

    if (!mounted) return;

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vendorProvider = context.watch<VendorProvider>();
    final vendor = vendorProvider.vendor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Your Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            onPressed: vendorProvider.isLoading ? null : _saveProfile,
          ),
        ],
      ),
      body: vendorProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Business Description'),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: 'Tell customers about your business...',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter a description' : null,
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Category'),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      items: _categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedCategory = newValue;
                        });
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Select your business category',
                      ),
                      validator: (value) =>
                          value == null ? 'Please select a category' : null,
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Base Price (₪)'),
                    TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'e.g., 5000',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) return 'Please enter a price';
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Gallery Images'),
                    _buildGalleryManager(vendor),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFBFA054),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Save Changes',
                            style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildGalleryManager(AppVendor? vendor) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount:
            (vendor?.galleryUrls.length ?? 0) + _newGalleryImages.length + 1,
        itemBuilder: (context, index) {
          if (index ==
              (vendor?.galleryUrls.length ?? 0) + _newGalleryImages.length) {
            return _buildAddImageButton();
          }
          if (index < _newGalleryImages.length) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(_newGalleryImages[index], fit: BoxFit.cover),
            );
          }
          final existingImageIndex = index - _newGalleryImages.length;
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(vendor!.galleryUrls[existingImageIndex],
                fit: BoxFit.cover),
          );
        },
      ),
    );
  }

  Widget _buildAddImageButton() {
    // --- REVERTED: Back to a simple onTap ---
    return InkWell(
      onTap: _pickImage,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Icon(Icons.add_a_photo_outlined, color: Colors.grey),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:pildat_cms/models/contact_detail.dart';
import 'package:pildat_cms/providers/dropdown_provider.dart';
import 'package:pildat_cms/screens/contact_form_screen.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';

class ScanConfirmationScreen extends StatefulWidget {
  final Map<String, dynamic> scannedData;

  const ScanConfirmationScreen({Key? key, required this.scannedData})
      : super(key: key);

  @override
  State<ScanConfirmationScreen> createState() => _ScanConfirmationScreenState();
}

class _ScanConfirmationScreenState extends State<ScanConfirmationScreen> {
  final Map<String, TextEditingController> _controllers = {};

  DropdownOption? _selectedCategory;
  DropdownOption? _selectedSubCategory;
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _subCategoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.scannedData.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        _controllers[key] = TextEditingController(text: value.toString());
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _categoryController.dispose();
    _subCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dropdowns = Provider.of<DropdownProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm & Classify'),
        backgroundColor: const Color(0xFF008CBA),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                const Text(
                  'Please review and edit the scanned details.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  '1. Classify Contact (Optional)',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                _buildCategorySearch(dropdowns),
                const SizedBox(height: 16),
                _buildSubCategorySearch(dropdowns),
                const SizedBox(height: 24),
                Text(
                  '2. Review Scanned Text',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ..._controllers.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: entry.value,
                      decoration: InputDecoration(
                        labelText: _formatKey(entry.key),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey[400]!),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('CANCEL'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF008CBA),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      final Map<String, dynamic> updatedData = {};
                      _controllers.forEach((key, controller) {
                        updatedData[key] = controller.text;
                      });
                      
                      updatedData['category_id'] = _selectedCategory?.id;
                      updatedData['sub_category_id'] = _selectedSubCategory?.id;

                      final ContactDetail contact =
                          _createContactFromScan(updatedData);

                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) =>
                              ContactFormScreen(initialData: contact),
                        ),
                      );
                    },
                    child: const Text('CONTINUE TO FORM'),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCategorySearch(DropdownProvider dropdowns) {
    return TypeAheadField<DropdownOption>(
      controller: _categoryController,
      suggestionsCallback: (pattern) {
        final allCategories = dropdowns.getOptions('categories');
        if (pattern.isEmpty) {
          return allCategories;
        }
        return allCategories
            .where((option) =>
                option.name.toLowerCase().contains(pattern.toLowerCase()))
            .toList();
      },
      itemBuilder: (context, option) {
        return ListTile(title: Text(option.name));
      },
      onSelected: (option) {
        setState(() {
          _selectedCategory = option;
          _categoryController.text = option.name;
          _selectedSubCategory = null;
          _subCategoryController.clear();
        });
      },
      builder: (context, controller, focusNode) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: const InputDecoration(
            labelText: 'Search Main Category',
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.search),
          ),
        );
      },
    );
  }

  Widget _buildSubCategorySearch(DropdownProvider dropdowns) {
    return TypeAheadField<DropdownOption>(
      controller: _subCategoryController,
      // 1. This parameter is removed.
      // enabled: _selectedCategory != null, // <-- THIS WAS THE BUG
      
      suggestionsCallback: (pattern) {
        if (_selectedCategory == null) {
          return [];
        }
        final allSubCategories = dropdowns.getOptions('sub_categories');
        final filteredList = allSubCategories
            .where((option) => option.categoryId == _selectedCategory!.id)
            .toList();

        if (pattern.isEmpty) {
          return filteredList;
        }
        return filteredList
            .where((option) =>
                option.name.toLowerCase().contains(pattern.toLowerCase()))
            .toList();
      },
      itemBuilder: (context, option) {
        return ListTile(title: Text(option.name));
      },
      onSelected: (option) {
        setState(() {
          _selectedSubCategory = option;
          _subCategoryController.text = option.name;
        });
      },
      builder: (context, controller, focusNode) {
        // 2. The logic is moved here.
        final bool isEnabled = _selectedCategory != null;
        
        return TextField(
          controller: controller,
          focusNode: focusNode,
          enabled: isEnabled, // <-- THIS IS THE FIX
          decoration: InputDecoration(
            labelText: 'Search Sub-Category',
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.search),
            filled: !isEnabled,
            fillColor: !isEnabled ? Colors.grey[200] : null,
          ),
        );
      },
    );
  }

  String _formatKey(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  ContactDetail _createContactFromScan(Map<String, dynamic> data) {
    data['id'] = 0;
    data['status'] = 1;
    return ContactDetail.fromJson(data);
  }
}
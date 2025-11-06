import 'package:flutter/material.dart';
import 'package:pildat_cms/services/api_service.dart';

// --- UPDATED THIS CLASS ---
class DropdownOption {
  final String id;
  final String name;
  final String? categoryId; // <-- ADDED THIS FIELD

  DropdownOption({
    required this.id,
    required this.name,
    this.categoryId, // <-- ADDED THIS
  });
}
// --- END OF UPDATE ---

class DropdownProvider with ChangeNotifier {
  final ApiService _apiService;

  Map<String, List<DropdownOption>> _dropdownData = {};
  bool _isLoading = false;
  bool _isLoaded = false;
  String? _error;

  bool get isLoading => _isLoading;
  bool get isLoaded => _isLoaded;
  String? get error => _error;
  
  List<DropdownOption> getOptions(String key) {
    return _dropdownData[key] ?? [];
  }

  DropdownProvider(this._apiService) {
    _fetchDropdowns();
  }

  Future<void> _fetchDropdowns() async {
    if (_isLoaded || _isLoading) return; 

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get('dropdowns.php');
      if (response['success'] == true && response['dropdowns'] != null) {
        final Map<String, dynamic> allDropdowns = response['dropdowns'];
        
        // --- UPDATED THIS LOOP ---
        allDropdowns.forEach((key, list) {
          final List<DropdownOption> options = (list as List).map((item) {
            // Your API uses different "name" fields, so we check for them
            final String name = item['category_name'] ??
                                item['sub_category_name'] ??
                                item['occupation_name'] ??
                                item['political_party_name'] ??
                                item['country_name'] ??
                                item['speciality_name'] ??
                                item['cast_name'] ??
                                item['position_name'] ??
                                item['employer_name'] ??
                                item['designation_name'] ??
                                item['province_name'] ??
                                'Unknown';
            
            // This now saves the category_id if it exists
            return DropdownOption(
              id: item['id'].toString(),
              name: name,
              categoryId: item['category_id']?.toString(), // <-- ADDED THIS
            );
          }).toList();
          
          _dropdownData[key] = options;
        });
        // --- END OF UPDATE ---

        _isLoaded = true;
        _isLoading = false;
        notifyListeners();
      } else {
        throw Exception(response['message'] ?? 'Failed to parse dropdowns');
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
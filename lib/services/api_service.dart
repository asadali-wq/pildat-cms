// lib/services/api_service.dart (MOBILE-ONLY VERSION)
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// NO 'kIsWeb' or 'browser_client.dart' imports

import 'package:pildat_cms/models/contact_detail.dart';
import 'package:pildat_cms/models/contact_list_item.dart';

class ApiService {
  final String _baseUrl = "https://cms.pildat.org/api";
  String? _cookie;
  late http.Client _client; // Use a standard client

  ApiService() {
    _client = http.Client(); // Just a standard client
  }

  Future<void> _loadCookie() async {
    if (_cookie != null) return;
    final prefs = await SharedPreferences.getInstance();
    _cookie = prefs.getString('session_cookie');
  }

  Future<void> _saveCookie(String rawCookie) async {
    String cookie = rawCookie.split(';')[0];
    _cookie = cookie;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('session_cookie', cookie);
  }

  Future<void> clearCookie() async {
    _cookie = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_cookie');
  }

  // --- API Methods ---

  Future<Map<String, dynamic>> login(String loginId, String password) async {
    final response = await _client.post( 
      Uri.parse('$_baseUrl/login.php'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'login_Id': loginId, 'password': password},
    );

    final String? rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      await _saveCookie(rawCookie);
    }

    return jsonDecode(response.body);
  }

  Future<void> logout() async {
    await _loadCookie();
    var headers = {'Cookie': _cookie ?? ''}; // Always add the cookie

    await _client.get( 
      Uri.parse('$_baseUrl/logout.php'),
      headers: headers,
    );
    await clearCookie();
  }

  Future<dynamic> get(String endpoint) async {
    await _loadCookie();
    var headers = {'Cookie': _cookie ?? ''}; // Always add the cookie

    final response = await _client.get( 
      Uri.parse('$_baseUrl/$endpoint'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      return {'success': false, 'message': 'Unauthorized'};
    } else {
      throw Exception('Failed to load data from $endpoint');
    }
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    final response = await get('dashboard.php') as Map<String, dynamic>;
    return response;
  }

  Future<Map<String, dynamic>> getContacts(int page) async {
    final response = await get('contacts.php?page=$page') as Map<String, dynamic>;
    return response;
  }

  Future<ContactDetail?> getContactDetails(String contactId) async {
    final response = await get('ajax_get_contact.php?id=$contactId') as Map<String, dynamic>;
    if (response['error'] == null) {
      return ContactDetail.fromJson(response);
    }
    return null;
  }

  Future<List<ContactListItem>> searchContacts(String term) async {
    final response = await get('ajax_search.php?term=$term');

    if (response != null && response is List) {
      return (response as List)
          .map((data) => ContactListItem.fromJson(data as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> post(
      String endpoint, Map<String, String> body) async {
    await _loadCookie();

    var headers = {
        'Cookie': _cookie ?? '',
        'Content-Type': 'application/x-www-form-urlencoded'
      }; // Always add cookie

    final response = await _client.post(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      return {'success': false, 'message': 'Unauthorized'};
    } else {
      throw Exception('Failed to post data to $endpoint');
    }
  }

  Future<Map<String, dynamic>> addContact(Map<String, String> formData) {
    return post('contact_add.php', formData);
  }

  Future<Map<String, dynamic>> updateContact(String contactId, Map<String, String> formData) {
    return post('contact_edit.php?id=$contactId', formData);
  }

  Future<Map<String, dynamic>> deleteContact(String contactId) async {
    return await get('contact_delete.php?id=$contactId') as Map<String, dynamic>;
  }
}
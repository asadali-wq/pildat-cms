import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pildat_cms/models/contact_list_item.dart';
import 'package:pildat_cms/services/api_service.dart';
import 'package:pildat_cms/screens/contact_form_screen.dart';
import 'package:pildat_cms/screens/contact_view_screen.dart';
import 'package:pildat_cms/services/ai_service.dart';
import 'package:pildat_cms/screens/scan_confirmation_screen.dart';
import 'package:image_picker/image_picker.dart';

class ContactListScreen extends StatefulWidget {
  const ContactListScreen({Key? key}) : super(key: key);

  @override
  State<ContactListScreen> createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  final List<ContactListItem> _contacts = [];
  final ScrollController _scrollController = ScrollController();
  
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _error;

  // --- NEW STATE FOR SEARCH ---
  bool _isSearchMode = false;
  List<ContactListItem> _searchResults = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadContacts(); // Load initial list

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent * 0.9 &&
          !_isLoading &&
          !_isSearchMode) { // Don't infinite scroll in search mode
        _loadContacts();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);
    
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final response = await apiService.getContacts(_currentPage);

      if (response['success'] == true) {
        final List newContacts = response['contacts'];
        final Map pagination = response['pagination'];

        setState(() {
          _currentPage++;
          _isLoading = false;
          _hasMore = pagination['currentPage'] <= pagination['totalPages'];
          _contacts.addAll(newContacts
              .map((data) => ContactListItem.fromJson(data))
              .toList());
        });
      } else {
        throw Exception(response['message'] ?? 'Failed to load contacts');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  // --- NEW FUNCTION FOR SEARCH ---
  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _isSearchMode = false;
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _isSearchMode = true;
      _error = null;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final results = await apiService.searchContacts(query);
      setState(() {
        _isLoading = false;
        _searchResults = results;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  // --- THIS IS THE NEW SCAN FUNCTION ---
  Future<void> _scanNewContact() async {
    final scanService = ScanService();
    Map<String, dynamic>? scannedData;
    
    try {
      // --- This shows a loading dialog ---
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Dialog(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Scanning Card...'),
              ],
            ),
          ),
        ),
      );

      // 1. Scan and get data (using the Camera)
      scannedData = await scanService.scanCard(ImageSource.camera);
      
      if (!mounted) return;
      Navigator.of(context).pop(); // Close the loading dialog

      // 2. If data was found, go to the confirmation screen
      if (scannedData != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ScanConfirmationScreen(scannedData: scannedData!), // <-- FIX
          ),
        );
      } else {
        // User cancelled the camera
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Scan cancelled')),
        );
      }
      
    } catch (e) {
      // 3. If an error happened, show it
      if (!mounted) return;
      Navigator.of(context).pop(); // Close the loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Scan Failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF008CBA),
        title: _isSearchMode
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: _performSearch,
              )
            : const Text('All Contacts'),
        actions: [
          IconButton(
            icon: Icon(_isSearchMode ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearchMode = !_isSearchMode;
                _searchResults = [];
                _searchController.clear();
              });
            },
          ),
          // --- THIS IS THE NEW SCAN BUTTON ---
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined),
            tooltip: 'Scan Card',
            onPressed: _scanNewContact,
          ),
          // --- END OF NEW BUTTON ---
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final List<ContactListItem> currentList =
        _isSearchMode ? _searchResults : _contacts;

    if (currentList.isEmpty && _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text('Error: $_error')); // Simplified error
    }
    
    if (currentList.isEmpty && !_isLoading) {
      return const Center(child: Text('No contacts found.'));
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: currentList.length + (_isSearchMode ? 0 : 1),
      itemBuilder: (context, index) {
        if (index == currentList.length) {
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!_hasMore) {
            return const Center(
                child: Padding(
                    padding: EdgeInsets.all(16.0), child: Text('End of list')));
          }
          return const SizedBox.shrink();
        }

        final contact = currentList[index];
        return ListTile(
          leading: CircleAvatar(
            child: Text(contact.fullName.isNotEmpty ? contact.fullName[0] : '?'),
          ),
          title: Text(contact.fullName),
          subtitle: Text(contact.emailAddress ?? 'No email'),
          onTap: () {
            // Navigate to the view screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ContactViewScreen(contactId: contact.id),
              ),
            );
          },
        );
      },
    );
  }
}
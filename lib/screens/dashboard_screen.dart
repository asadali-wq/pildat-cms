import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pildat_cms/providers/auth_provider.dart';
import 'package:pildat_cms/services/api_service.dart';
import 'package:pildat_cms/models/dashboard_stats.dart';
import 'package:intl/intl.dart'; // We'll use this for number formatting
import 'package:pildat_cms/screens/contact_list_screen.dart';
import 'package:pildat_cms/screens/contact_form_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // A Future will hold our stats
  late Future<DashboardStats> _statsFuture;
  final _numberFormat = NumberFormat.decimalPattern(); // For formatting 1000 as 1,000

  @override
  void initState() {
    super.initState();
    // Start fetching the stats as soon as the screen loads
    final apiService = Provider.of<ApiService>(context, listen: false);
    _statsFuture = _fetchStats(apiService);
  }

  // This function calls the API and parses the response
  Future<DashboardStats> _fetchStats(ApiService apiService) async {
    final response = await apiService.getDashboardStats();
    if (response['success'] == true && response['stats'] != null) {
      // It worked! Convert the JSON 'stats' into our object
      return DashboardStats.fromJson(response['stats']);
    } else {
      // If the API call fails *this time*, we'll know
      throw Exception(response['message'] ?? 'Failed to load stats');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: const Color(0xFF008CBA), // Your PILDAT Blue
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              authProvider.logout();
            },
          )
        ],
      ),
      // The body is now a FutureBuilder
      // It will "build" itself based on the state of our API call
      body: FutureBuilder<DashboardStats>(
        future: _statsFuture,
        builder: (context, snapshot) {
          // Case 1: Still loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Case 2: An error happened (like a new 401, or no internet)
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error loading dashboard:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            );
          }

          // Case 3: We have data!
          if (snapshot.hasData) {
            final stats = snapshot.data!;
            // Pass the data to our grid-building widget
            return _buildStatsGrid(stats);
          }

          // Just in case
          return const Center(child: Text('No data.'));
        },
      ),
	  // --- ADD THIS WIDGET ---
	    floatingActionButton: FloatingActionButton(
	      onPressed: () {
	        // Open the form in "Add New" mode (contactId is null)
	        Navigator.push(
	          context,
	          MaterialPageRoute(builder: (context) => const ContactFormScreen()),
	        );
	      },
	      backgroundColor: const Color(0xFF008CBA),
	      child: const Icon(Icons.add),
	      tooltip: 'Add Contact',
	    ),
    );
  }

  // A helper widget to build the grid (based on your dashboard.php)
  Widget _buildStatsGrid(DashboardStats stats) {
    return GridView.count(
      crossAxisCount: 2, // 2 columns
      padding: const EdgeInsets.all(16.0),
      crossAxisSpacing: 16.0,
      mainAxisSpacing: 16.0,
      childAspectRatio: 1.2, // Makes cards a bit taller
      children: [
		// --- THIS IS THE MODIFIED WIDGET ---
		  InkWell(
		    onTap: () {
		      // Navigate to the new screen
		      Navigator.push(
		        context,
		        MaterialPageRoute(
		            builder: (context) => const ContactListScreen()),
		      );
		    },
		    child: _buildStatCard(
		      'Total Contacts',
		      _numberFormat.format(stats.totalContacts),
		      Icons.people_outline,
		      Colors.blue,
		    ),
		  ),
        _buildStatCard(
          'Activity Logs',
          _numberFormat.format(stats.activityLogs),
          Icons.history,
          Colors.green,
        ),
        _buildStatCard(
          'Active Contacts',
          _numberFormat.format(stats.activeContacts),
          Icons.how_to_reg,
          Colors.orange,
        ),
        _buildStatCard(
          'Categories',
          _numberFormat.format(stats.categories),
          Icons.category_outlined,
          Colors.purple,
        ),
      ],
    );
  }

  // A helper widget to build a single card
  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
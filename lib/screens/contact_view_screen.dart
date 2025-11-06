import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pildat_cms/models/contact_detail.dart';
import 'package:pildat_cms/providers/dropdown_provider.dart';
import 'package:pildat_cms/services/api_service.dart';
import 'package:pildat_cms/screens/contact_form_screen.dart';

class ContactViewScreen extends StatefulWidget {
  final String contactId;
  const ContactViewScreen({Key? key, required this.contactId}) : super(key: key);

  @override
  State<ContactViewScreen> createState() => _ContactViewScreenState();
}

class _ContactViewScreenState extends State<ContactViewScreen> {
  late Future<ContactDetail?> _contactFuture;

  @override
  void initState() {
    super.initState();
    final apiService = Provider.of<ApiService>(context, listen: false);
    _contactFuture = apiService.getContactDetails(widget.contactId);
  }

  String? _findDropdownName(List<DropdownOption> options, String? id) {
    if (id == null || id.isEmpty) return null;
    try {
      return options.firstWhere((option) => option.id == id).name;
    } catch (e) {
      return id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dropdowns = Provider.of<DropdownProvider>(context, listen: false);

    return FutureBuilder<ContactDetail?>(
      future: _contactFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Loading...')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(child: Text('Error: ${snapshot.error ?? 'Contact not found.'}')),
          );
        }

        final contact = snapshot.data!;
        
        // --- THIS IS THE FIX ---
        final String? gender = _findDropdownName([
          DropdownOption(id: '1', name: 'Male'),
          DropdownOption(id: '2', name: 'Female'),
          DropdownOption(id: '3', name: 'Other')
        ], contact.genderId);
        
        final String? maritalStatus = _findDropdownName([
           DropdownOption(id: '1', name: 'Single'),
           DropdownOption(id: '2', name: 'Married'),
           DropdownOption(id: '3', name: 'Divorced'),
           DropdownOption(id: '4', name: 'Widowed')
        ], contact.maritalStatusId);
        // --- END OF FIX ---
        
        final String? caste = _findDropdownName(dropdowns.getOptions('casts'), contact.castId);
        final String? eduCountry = _findDropdownName(dropdowns.getOptions('countries'), contact.countryOfHighestEducationId);
        final String? employer = _findDropdownName(dropdowns.getOptions('employers'), contact.employerId);
        final String? designation = _findDropdownName(dropdowns.getOptions('designations'), contact.designationId);
        final String? workCountry = _findDropdownName(dropdowns.getOptions('countries'), contact.workCountryId);
        final String? occupation = _findDropdownName(dropdowns.getOptions('occupations'), contact.occupationId);
        final String? position = _findDropdownName(dropdowns.getOptions('positions'), contact.positionId);
        final String? speciality = _findDropdownName(dropdowns.getOptions('specialities'), contact.specialityId);
        final String? province = _findDropdownName(dropdowns.getOptions('provinces'), contact.provinceId);
        final String? resCountry = _findDropdownName(dropdowns.getOptions('countries'), contact.residenceCountryId);
        final String? category = _findDropdownName(dropdowns.getOptions('categories'), contact.categoryId);
        final String? subCategory = _findDropdownName(dropdowns.getOptions('sub_categories'), contact.subCategoryId);
        final String? politicalParty = _findDropdownName(dropdowns.getOptions('political_parties'), contact.politicalPartyId);

        return Scaffold(
          appBar: AppBar(
            title: Text(contact.fullName),
            backgroundColor: const Color(0xFF008CBA),
          ),
          body: ListView(
            padding: const EdgeInsets.all(8.0),
            children: [
              _buildSection('Main Details', [
                _buildDetailTile('Status', contact.status == 1 ? 'Active' : 'Inactive', Icons.check_circle_outline),
                _buildDetailTile('Date of Birth', contact.dob, Icons.cake_outlined),
                _buildDetailTile('Gender', gender, Icons.person_outline),
                _buildDetailTile('Marital Status', maritalStatus, Icons.family_restroom_outlined),
                _buildDetailTile('Caste', caste, Icons.group_work_outlined),
              ]),
              
              _buildSection('Education', [
                _buildDetailTile('Highest Education', contact.highestEducation, Icons.school_outlined),
                _buildDetailTile('Institution', contact.institutionOfHighestEducation, Icons.account_balance_outlined),
                _buildDetailTile('City of Education', contact.cityOfHighestEducation, Icons.location_city_outlined),
                _buildDetailTile('Country of Education', eduCountry, Icons.public_outlined),
              ]),
              
              _buildSection('Work & Professional', [
                _buildDetailTile('Employer', employer, Icons.business_outlined),
                _buildDetailTile('Employer (Manual)', contact.employerName, Icons.business_outlined),
                _buildDetailTile('Designation', designation, Icons.work_outline),
                _buildDetailTile('Designation (Manual)', contact.designationName, Icons.work_outline),
                _buildDetailTile('Occupation', occupation, Icons.work_history_outlined),
                _buildDetailTile('Position', position, Icons.star_border_outlined),
                _buildDetailTile('Speciality', speciality, Icons.star_outline),
                _buildDetailTile('Work Address', contact.workAddress, Icons.location_on_outlined),
                _buildDetailTile('Work City', contact.workCity, Icons.location_city_outlined),
                _buildDetailTile('Work Country', workCountry, Icons.public_outlined),
                _buildDetailTile('Work Phone', contact.workTelephone, Icons.call_outlined),
              ]),
              
              _buildSection('Contact & Residence', [
                _buildDetailTile('Email', contact.emailAddress, Icons.email_outlined),
                _buildDetailTile('Cell Phone 1', contact.cellulerPhone1, Icons.phone_android_outlined),
                _buildDetailTile('Cell Phone 2', contact.cellulerPhone2, Icons.phone_android_outlined),
                _buildDetailTile('WhatsApp', contact.whatsappNumber, Icons.message_outlined),
                _buildDetailTile('Residence Address', contact.residenceAddress, Icons.home_outlined),
                _buildDetailTile('Residence City', contact.residenceCity, Icons.location_city_outlined),
                _buildDetailTile('Residence Province', province, Icons.map_outlined),
                _buildDetailTile('Residence Province (Manual)', contact.residenceProvince, Icons.map_outlined),
                _buildDetailTile('Residence Country', resCountry, Icons.public_outlined),
                _buildDetailTile('Residence Phone', contact.residenceTelephone, Icons.call_outlined),
              ]),
              
              _buildSection('Classification & Social', [
                _buildDetailTile('Category', category, Icons.category_outlined),
                _buildDetailTile('Sub-Category', subCategory, Icons.subdirectory_arrow_right_outlined),
                _buildDetailTile('Political Party', politicalParty, Icons.flag_outlined),
                _buildDetailTile('Website', contact.website, Icons.language_outlined),
                _buildDetailTile('Twitter', contact.twitterHandler, Icons.alternate_email_outlined),
                _buildDetailTile('Facebook', contact.facebook, Icons.facebook_outlined),
                _buildDetailTile('LinkedIn', contact.linkedin, Icons.workspaces_outline),
                _buildDetailTile('Instagram', contact.instagram, Icons.camera_alt_outlined),
              ]),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ContactFormScreen(contactId: contact.id.toString()),
                ),
              );
            },
            backgroundColor: const Color(0xFF008CBA),
            child: const Icon(Icons.edit),
            tooltip: 'Edit Contact',
          ),
        );
      },
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    final validChildren = children.where((child) => child is! SizedBox).toList();
    if (validChildren.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF008CBA),
                  ),
            ),
          ),
          const Divider(height: 1),
          ...validChildren,
        ],
      ),
    );
  }

  Widget _buildDetailTile(String title, String? subtitle, IconData icon) {
    if (subtitle == null || subtitle.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
    );
  }
}
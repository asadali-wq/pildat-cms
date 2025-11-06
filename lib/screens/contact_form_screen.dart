// lib/screens/contact_form_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pildat_cms/models/contact_detail.dart';
import 'package:pildat_cms/models/contact_list_item.dart';
import 'package:pildat_cms/providers/dropdown_provider.dart';
import 'package:pildat_cms/services/api_service.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class ContactFormScreen extends StatefulWidget {
  final String? contactId;
  final ContactDetail? initialData; // <-- This was the fix from before

  const ContactFormScreen({
    Key? key,
    this.contactId,
    this.initialData, // <-- This was the fix from before
  }) : super(key: key);

  @override
  State<ContactFormScreen> createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactFormScreen> {
  late Future<ContactDetail?> _contactFuture;

  @override
  void initState() {
    super.initState();
    // This logic is now correct
    if (widget.contactId != null) {
      final apiService = Provider.of<ApiService>(context, listen: false);
      _contactFuture = apiService.getContactDetails(widget.contactId!);
    } else if (widget.initialData != null) {
      _contactFuture = Future.value(widget.initialData);
    } else {
      _contactFuture = Future.value(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contactId != null ? 'Edit Contact' : 'Add Contact'),
        backgroundColor: const Color(0xFF008CBA),
      ),
      body: Consumer<DropdownProvider>(
        builder: (context, dropdowns, child) {
          if (!dropdowns.isLoaded) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading form options...'),
                ],
              ),
            );
          }

          return FutureBuilder<ContactDetail?>(
            future: _contactFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error loading contact: ${snapshot.error}'));
              }

              final contact = snapshot.data;
              if (widget.contactId != null && contact == null) {
                return const Center(child: Text('Error: Contact not found.'));
              }

              final apiService = Provider.of<ApiService>(context, listen: false);
              return _ContactForm(contact: contact, apiService: apiService);
            },
          );
        },
      ),
    );
  }
}

// --- The Actual Form Widget ---
class _ContactForm extends StatefulWidget {
  final ContactDetail? contact;
  final ApiService apiService;

  const _ContactForm({Key? key, this.contact, required this.apiService}) : super(key: key);

  @override
  State<_ContactForm> createState() => __ContactFormState();
}

class __ContactFormState extends State<_ContactForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  TextEditingController? _fullNameController;
  late TextEditingController _dobController;
  late TextEditingController _highestEducationController;
  late TextEditingController _institutionOfHighestEducationController;
  late TextEditingController _cityOfHighestEducationController;
  late TextEditingController _employerNameController;
  late TextEditingController _designationNameController;
  late TextEditingController _workAddressController;
  late TextEditingController _workCityController;
  late TextEditingController _workTelephoneController;
  late TextEditingController _residenceAddressController;
  late TextEditingController _residenceCityController;
  late TextEditingController _residenceProvinceController;
  late TextEditingController _residenceTelephoneController;
  late TextEditingController _emailAddressController;
  late TextEditingController _cellulerPhone1Controller;
  late TextEditingController _cellulerPhone2Controller;
  late TextEditingController _whatsappNumberController;
  late TextEditingController _websiteController;
  late TextEditingController _twitterHandlerController;
  late TextEditingController _facebookController;
  late TextEditingController _linkedinController;
  late TextEditingController _instagramController;

  String? _selectedStatus;
  String? _selectedGender;
  String? _selectedMaritalStatus;
  String? _selectedCast;
  String? _selectedCountryOfHighestEducation;
  String? _selectedEmployer;
  String? _selectedDesignation;
  String? _selectedWorkCountry;
  String? _selectedOccupation;
  String? _selectedPosition;
  String? _selectedSpeciality;
  String? _selectedProvince;
  String? _selectedResidenceCountry;
  String? _selectedCategory;
  String? _selectedSubCategory;
  String? _selectedPoliticalParty;

  @override
  void initState() {
    super.initState();
    final contact = widget.contact;

    _dobController = TextEditingController(text: contact?.dob ?? '');
    _highestEducationController = TextEditingController(text: contact?.highestEducation ?? '');
    _institutionOfHighestEducationController = TextEditingController(text: contact?.institutionOfHighestEducation ?? '');
    _cityOfHighestEducationController = TextEditingController(text: contact?.cityOfHighestEducation ?? '');
    _employerNameController = TextEditingController(text: contact?.employerName ?? '');
    _designationNameController = TextEditingController(text: contact?.designationName ?? '');
    _workAddressController = TextEditingController(text: contact?.workAddress ?? '');
    _workCityController = TextEditingController(text: contact?.workCity ?? '');
    _workTelephoneController = TextEditingController(text: contact?.workTelephone ?? '');
    _residenceAddressController = TextEditingController(text: contact?.residenceAddress ?? '');
    _residenceCityController = TextEditingController(text: contact?.residenceCity ?? '');
    _residenceProvinceController = TextEditingController(text: contact?.residenceProvince ?? '');
    _residenceTelephoneController = TextEditingController(text: contact?.residenceTelephone ?? '');
    _emailAddressController = TextEditingController(text: contact?.emailAddress ?? '');
    _cellulerPhone1Controller = TextEditingController(text: contact?.cellulerPhone1 ?? '');
    _cellulerPhone2Controller = TextEditingController(text: contact?.cellulerPhone2 ?? '');
    _whatsappNumberController = TextEditingController(text: contact?.whatsappNumber ?? '');
    _websiteController = TextEditingController(text: contact?.website ?? '');
    _twitterHandlerController = TextEditingController(text: contact?.twitterHandler ?? '');
    _facebookController = TextEditingController(text: contact?.facebook ?? '');
    _linkedinController = TextEditingController(text: contact?.linkedin ?? '');
    _instagramController = TextEditingController(text: contact?.instagram ?? '');

    _selectedStatus = contact?.status.toString() ?? '1';
    _selectedGender = contact?.genderId;
    _selectedMaritalStatus = contact?.maritalStatusId;
    _selectedCast = contact?.castId;
    _selectedCountryOfHighestEducation = contact?.countryOfHighestEducationId;
    _selectedEmployer = contact?.employerId;
    _selectedDesignation = contact?.designationId;
    _selectedWorkCountry = contact?.workCountryId;
    _selectedOccupation = contact?.occupationId;
    _selectedPosition = contact?.positionId;
    _selectedSpeciality = contact?.specialityId;
    _selectedProvince = contact?.provinceId;
    _selectedResidenceCountry = contact?.residenceCountryId;
    _selectedCategory = contact?.categoryId;
    _selectedSubCategory = contact?.subCategoryId;
    _selectedPoliticalParty = contact?.politicalPartyId;
  }

  @override
  void dispose() {
    _fullNameController?.dispose();
    _dobController.dispose();
    _highestEducationController.dispose();
    _institutionOfHighestEducationController.dispose();
    _cityOfHighestEducationController.dispose();
    _employerNameController.dispose();
    _designationNameController.dispose();
    _workAddressController.dispose();
    _workCityController.dispose();
    _workTelephoneController.dispose();
    _residenceAddressController.dispose();
    _residenceCityController.dispose();
    _residenceProvinceController.dispose();
    _residenceTelephoneController.dispose();
    _emailAddressController.dispose();
    _cellulerPhone1Controller.dispose();
    _cellulerPhone2Controller.dispose();
    _whatsappNumberController.dispose();
    _websiteController.dispose();
    _twitterHandlerController.dispose();
    _facebookController.dispose();
    _linkedinController.dispose();
    _instagramController.dispose();
    super.dispose();
  }

  Widget _buildSection(String title, List<Widget> children) {
    return ExpansionTile(
      title: Text(title, style: Theme.of(context).textTheme.titleLarge),
      initiallyExpanded: title == 'Main Details',
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
        )
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        keyboardType: keyboardType,
      ),
    );
  }

  Widget _buildDropdown(String label, List<DropdownOption> options, String? selectedValue, void Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        value: selectedValue,
        isExpanded: true,
        items: [
          const DropdownMenuItem<String>(value: null, child: Text('-- Select --')),
          ...options.map((option) => DropdownMenuItem<String>(value: option.id, child: Text(option.name, overflow: TextOverflow.ellipsis))),
        ],
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildFullNameField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TypeAheadField<ContactListItem>(
        suggestionsCallback: (pattern) async {
          if (pattern.length < 2) return [];
          return await widget.apiService.searchContacts(pattern);
        },
        itemBuilder: (context, ContactListItem suggestion) {
          return ListTile(
            title: Text(suggestion.fullName),
            subtitle: Text(suggestion.emailAddress ?? ''),
          );
        },
        onSelected: (ContactListItem suggestion) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => ContactFormScreen(contactId: suggestion.id),
            ),
          );
        },
        builder: (context, TextEditingController controller, FocusNode focusNode) {
          _fullNameController = controller;
          // Pre-fill with either the contact's name OR the initialData (from scan)
          final initialName = widget.contact?.fullName ?? '';
          if (controller.text.isEmpty) {
            controller.text = initialName;
          }

          return TextFormField(
            controller: controller,
            focusNode: focusNode,
            decoration: const InputDecoration(
              labelText: 'Full Name *',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a name';
              }
              return null;
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dropdowns = Provider.of<DropdownProvider>(context, listen: false);

    return Form(
      key: _formKey,
      child: ListView(
        children: [
          _buildSection('Main Details', [
            _buildFullNameField(),
            _buildTextField('Date of Birth (YYYY-MM-DD)', _dobController, keyboardType: TextInputType.datetime),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
              value: _selectedStatus,
              items: const [
                DropdownMenuItem(value: '1', child: Text('Active')),
                DropdownMenuItem(value: '0', child: Text('Inactive')),
              ],
              onChanged: (value) => setState(() => _selectedStatus = value),
            ),
            const SizedBox(height: 8),

            // --- THIS IS THE FIX ---
            _buildDropdown(
              'Gender',
              [
                DropdownOption(id: '1', name: 'Male'),
                DropdownOption(id: '2', name: 'Female'),
                DropdownOption(id: '3', name: 'Other')
              ],
              _selectedGender,
              (value) => setState(() => _selectedGender = value),
            ),
            _buildDropdown(
              'Marital Status',
              [
                DropdownOption(id: '1', name: 'Single'),
                DropdownOption(id: '2', name: 'Married'),
                DropdownOption(id: '3', name: 'Divorced'),
                DropdownOption(id: '4', name: 'Widowed')
              ],
              _selectedMaritalStatus,
              (value) => setState(() => _selectedMaritalStatus = value),
            ),
            // --- END OF FIX ---

            _buildDropdown('Caste', dropdowns.getOptions('casts'), _selectedCast, (value) => setState(() => _selectedCast = value)),
          ]),
          
          _buildSection('Education', [
            _buildTextField('Highest Education', _highestEducationController),
            _buildTextField('Institution', _institutionOfHighestEducationController),
            _buildTextField('City of Institution', _cityOfHighestEducationController),
            _buildDropdown('Country of Institution', dropdowns.getOptions('countries'), _selectedCountryOfHighestEducation, (value) => setState(() => _selectedCountryOfHighestEducation = value)),
          ]),
          
          _buildSection('Work & Professional', [
            _buildDropdown('Employer (from list)', dropdowns.getOptions('employers'), _selectedEmployer, (value) => setState(() => _selectedEmployer = value)),
            _buildTextField('Employer Name (if not in list)', _employerNameController),
            _buildDropdown('Designation (from list)', dropdowns.getOptions('designations'), _selectedDesignation, (value) => setState(() => _selectedDesignation = value)),
            _buildTextField('Designation (if not in list)', _designationNameController),
            _buildTextField('Work Address', _workAddressController),
            _buildTextField('Work City', _workCityController),
            _buildDropdown('Work Country', dropdowns.getOptions('countries'), _selectedWorkCountry, (value) => setState(() => _selectedWorkCountry = value)),
            _buildTextField('Work Telephone', _workTelephoneController, keyboardType: TextInputType.phone),
            _buildDropdown('Occupation', dropdowns.getOptions('occupations'), _selectedOccupation, (value) => setState(() => _selectedOccupation = value)),
            _buildDropdown('Position', dropdowns.getOptions('positions'), _selectedPosition, (value) => setState(() => _selectedPosition = value)),
            _buildDropdown('Speciality', dropdowns.getOptions('specialities'), _selectedSpeciality, (value) => setState(() => _selectedSpeciality = value)),
          ]),
          
          _buildSection('Contact & Residence', [
            _buildTextField('Email Address', _emailAddressController, keyboardType: TextInputType.emailAddress),
            _buildTextField('Cell Phone 1', _cellulerPhone1Controller, keyboardType: TextInputType.phone),
            _buildTextField('Cell Phone 2', _cellulerPhone2Controller, keyboardType: TextInputType.phone),
            _buildTextField('WhatsApp Number', _whatsappNumberController, keyboardType: TextInputType.phone),
            _buildTextField('Residence Address', _residenceAddressController),
            _buildTextField('Residence City', _residenceCityController),
            _buildDropdown('Residence Province (from list)', dropdowns.getOptions('provinces'), _selectedProvince, (value) => setState(() => _selectedProvince = value)),
            _buildTextField('Residence Province (if not in list)', _residenceProvinceController),
            _buildDropdown('Residence Country', dropdowns.getOptions('countries'), _selectedResidenceCountry, (value) => setState(() => _selectedResidenceCountry = value)),
            _buildTextField('Residence Telephone', _residenceTelephoneController, keyboardType: TextInputType.phone),
          ]),
          
          _buildSection('Classification & Social', [
            _buildDropdown('Category', dropdowns.getOptions('categories'), _selectedCategory, (value) => setState(() => _selectedCategory = value)),
            _buildDropdown('Sub-Category', dropdowns.getOptions('sub_categories'), _selectedSubCategory, (value) => setState(() => _selectedSubCategory = value)),
            _buildDropdown('Political Party', dropdowns.getOptions('political_parties'), _selectedPoliticalParty, (value) => setState(() => _selectedPoliticalParty = value)),
            _buildTextField('Website', _websiteController, keyboardType: TextInputType.url),
            _buildTextField('Twitter', _twitterHandlerController),
            _buildTextField('Facebook', _facebookController),
            _buildTextField('LinkedIn', _linkedinController),
            _buildTextField('Instagram', _instagramController),
          ]),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF008CBA), padding: const EdgeInsets.symmetric(vertical: 16)),
              onPressed: _isLoading ? null : _submitForm,
              child: _isLoading ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white)) : Text(widget.contact != null && widget.contact!.id != 0 ? 'Update Contact' : 'Save Contact'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
      // We added a validator to the TypeAheadField, so this check will
      // now correctly validate the full name.
      if (!_formKey.currentState!.validate()) return;

      setState(() => _isLoading = true);

      final Map<String, String> formData = {
        'full_name': _fullNameController?.text ?? '',
        'dob': _dobController.text,
        'highest_education': _highestEducationController.text,
        'institution_of_highest_education': _institutionOfHighestEducationController.text,
        'city_of_highest_education': _cityOfHighestEducationController.text,
        'employer_name': _employerNameController.text,
        'designation_name': _designationNameController.text,
        'work_address': _workAddressController.text,
        'work_city': _workCityController.text,
        'work_telephone': _workTelephoneController.text,
        'residence_address': _residenceAddressController.text,
        'residence_city': _residenceCityController.text,
        'residence_province': _residenceProvinceController.text,
        'residence_telephone': _residenceTelephoneController.text,
        'email_address': _emailAddressController.text,
        'celluler_phone1': _cellulerPhone1Controller.text,
        'celluler_phone2': _cellulerPhone2Controller.text,
        'whatsapp_number': _whatsappNumberController.text,
        'website': _websiteController.text,
        'twitter_handler': _twitterHandlerController.text,
        'facebook': _facebookController.text,
        'linkedin': _linkedinController.text,
        'instagram': _instagramController.text,
        'status': _selectedStatus ?? '1',
        'gender_id': _selectedGender ?? '',
        'maritalStatusId': _selectedMaritalStatus ?? '',
        'cast_id': _selectedCast ?? '',
        'country_of_highest_education_id': _selectedCountryOfHighestEducation ?? '',
        'employer_id': _selectedEmployer ?? '',
        'designation_id': _selectedDesignation ?? '',
        'work_country_id': _selectedWorkCountry ?? '',
        'occupation_id': _selectedOccupation ?? '',
        'position_id': _selectedPosition ?? '',
        'speciality_id': _selectedSpeciality ?? '',
        'province_id': _selectedProvince ?? '',
        'residence_country_id': _selectedResidenceCountry ?? '',
        'category_id': _selectedCategory ?? '',
        'sub_category_id': _selectedSubCategory ?? '',
        'political_party_id': _selectedPoliticalParty ?? '',
      };

      String message = '';
      bool success = false;

      try {
        final apiService = Provider.of<ApiService>(context, listen: false);
        Map<String, dynamic> response;

        if (widget.contact != null && widget.contact!.id != 0) {
          response = await apiService.updateContact(widget.contact!.id.toString(), formData);
        } else {
          response = await apiService.addContact(formData);
        }

        if (response['success'] == true) {
          success = true;
          message = response['message'] ?? (widget.contact != null ? 'Contact updated' : 'Contact added');
        } else {
          message = response['message'] ?? 'An unknown error occurred.';
        }

      } catch (e) {
        message = 'An error occurred: $e';
        success = false;
      } finally {
        if (!mounted) return; // Check if the widget is still mounted

        // Set loading to false
        setState(() => _isLoading = false);

        // Show the message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );

        // ONLY pop the screen if the API call was successful
        if (success) {
          // Wait a very short duration to let the user see the SnackBar
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            Navigator.of(context).pop();
          }
        }
      }
    }
} // <-- ADD THIS CLOSING BRACE to close __ContactFormState
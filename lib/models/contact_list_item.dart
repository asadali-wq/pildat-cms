class ContactListItem {
  final String id;
  final String fullName;
  final String? emailAddress;
  final String? cellPhone;
  final String? workCity;

  ContactListItem({
    required this.id,
    required this.fullName,
    this.emailAddress,
    this.cellPhone,
    this.workCity,
  });

  // --- THIS IS THE NEW, SMARTER 'fromJson' CONSTRUCTOR ---
  factory ContactListItem.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('label')) {
      // This is a SEARCH RESULT from 'ajax_search.php'
      // 'label' contains: "Full Name (email@address.com)"
      // 'value' contains: "Full Name"
      
      return ContactListItem(
        id: json['id']?.toString() ?? '',
        fullName: json['value']?.toString().replaceAll('\n', ' ').trim() ?? 'No Name',
        emailAddress: json['label']?.toString().trim(), // The label has the email, so we'll use it as the subtitle
      );
    } else {
      // This is a FULL CONTACT from 'contacts.php'
      
      return ContactListItem(
        id: json['id']?.toString() ?? '',
        fullName: json['full_name']?.toString().replaceAll('\n', ' ').trim() ?? 'No Name',
        emailAddress: json['email_address']?.toString().trim(),
        cellPhone: json['celluler_phone1']?.toString().trim(),
        workCity: json['work_city']?.toString().trim(),
      );
    }
  }
}
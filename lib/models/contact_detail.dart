// This model holds all the fields for a single contact,
// matching your contact_add.php and contact_edit.php
class ContactDetail {
  final int id;
  final String fullName;
  final String? dob;
  final String? highestEducation;
  final String? institutionOfHighestEducation;
  final String? cityOfHighestEducation;
  final String? workAddress;
  final String? emailAddress;
  final String? workCity;
  final String? workTelephone;
  final String? residenceAddress;
  final String? residenceCity;
  final String? residenceTelephone;
  final String? cellulerPhone1;
  final String? cellulerPhone2;
  final String? whatsappNumber;
  final String? website;
  final String? twitterHandler;
  final String? facebook;
  final String? linkedin;
  final String? instagram;
  final String? employerName;
  final String? designationName;
  final String? residenceProvince;
  final String? contactImage;
  final int status;
  
  // These are all the foreign keys
  final String? categoryId;
  final String? workCountryId;
  final String? residenceCountryId;
  final String? subCategoryId;
  final String? specialityId;
  final String? occupationId;
  final String? politicalPartyId;
  final String? countryOfHighestEducationId;
  final String? castId;
  final String? positionId;
  final String? employerId;
  final String? genderId;
  final String? maritalStatusId;
  final String? provinceId;
  final String? designationId;
  
  ContactDetail({
    required this.id,
    required this.fullName,
    this.dob,
    this.highestEducation,
    this.institutionOfHighestEducation,
    this.cityOfHighestEducation,
    this.workAddress,
    this.emailAddress,
    this.workCity,
    this.workTelephone,
    this.residenceAddress,
    this.residenceCity,
    this.residenceTelephone,
    this.cellulerPhone1,
    this.cellulerPhone2,
    this.whatsappNumber,
    this.website,
    this.twitterHandler,
    this.facebook,
    this.linkedin,
    this.instagram,
    this.employerName,
    this.designationName,
    this.residenceProvince,
    this.contactImage,
    required this.status,
    this.categoryId,
    this.workCountryId,
    this.residenceCountryId,
    this.subCategoryId,
    this.specialityId,
    this.occupationId,
    this.politicalPartyId,
    this.countryOfHighestEducationId,
    this.castId,
    this.positionId,
    this.employerId,
    this.genderId,
    this.maritalStatusId,
    this.provinceId,
    this.designationId,
  });

  // Helper function to safely parse foreign keys, which might be '0' or null
  static String? _parseId(dynamic id) {
    if (id == null) return null;
    final String idStr = id.toString();
    if (idStr == '0' || idStr.isEmpty) return null;
    return idStr;
  }

  factory ContactDetail.fromJson(Map<String, dynamic> json) {
    return ContactDetail(
      id: int.parse(json['id'].toString()),
      fullName: json['full_name'] ?? 'No Name',
      dob: json['dob'],
      highestEducation: json['highest_education'],
      institutionOfHighestEducation: json['institution_of_highest_education'],
      cityOfHighestEducation: json['city_of_highest_education'],
      workAddress: json['work_address'],
      emailAddress: json['email_address'],
      workCity: json['work_city'],
      workTelephone: json['work_telephone'],
      residenceAddress: json['residence_address'],
      residenceCity: json['residence_city'],
      residenceTelephone: json['residence_telephone'],
      cellulerPhone1: json['celluler_phone1'],
      cellulerPhone2: json['celluler_phone2'],
      whatsappNumber: json['whatsapp_number'],
      website: json['website'],
      twitterHandler: json['twitter_handler'],
      facebook: json['facebook'],
      linkedin: json['linkedin'],
      instagram: json['instagram'],
      employerName: json['employer_name'],
      designationName: json['designation_name'],
      residenceProvince: json['residence_province'],
      contactImage: json['contact_image'],
      status: int.parse(json['status']?.toString() ?? '1'),
      
      // Parse all foreign keys
      categoryId: _parseId(json['category_id']),
      workCountryId: _parseId(json['work_country_id']),
      residenceCountryId: _parseId(json['residence_country_id']),
      subCategoryId: _parseId(json['sub_category_id']),
      specialityId: _parseId(json['speciality_id']),
      occupationId: _parseId(json['occupation_id']),
      politicalPartyId: _parseId(json['political_party_id']),
      countryOfHighestEducationId: _parseId(json['country_of_highest_education_id']),
      castId: _parseId(json['cast_id']),
      positionId: _parseId(json['position_id']),
      employerId: _parseId(json['employer_id']),
      genderId: _parseId(json['gender_id']),
      maritalStatusId: _parseId(json['maritalStatusId']),
      provinceId: _parseId(json['province_id']),
      designationId: _parseId(json['designation_id']),
    );
  }
}
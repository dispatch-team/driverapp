class DriverProfile {
  const DriverProfile({
    required this.id,
    required this.keycloakId,
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.courierCompanyId,
    required this.status,
    this.profilePictureId,
    this.additionalDocumentsId,
    required this.ratingAggregate,
    required this.ratingCount,
  });

  final int id;
  final String keycloakId;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final int courierCompanyId;
  final String status;
  final int? profilePictureId;
  final int? additionalDocumentsId;
  final double ratingAggregate;
  final int ratingCount;

  String get fullName {
    final parts = [firstName, if (middleName != null) middleName!, lastName];
    return parts.join(' ');
  }

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0] : '';
    final l = lastName.isNotEmpty ? lastName[0] : '';
    return '$f$l'.toUpperCase();
  }

  factory DriverProfile.fromJson(Map<String, dynamic> json) {
    return DriverProfile(
      id: json['id'] as int,
      keycloakId: json['keycloak_id'] as String,
      firstName: json['first_name'] as String,
      middleName: json['middle_name'] as String?,
      lastName: json['last_name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String,
      courierCompanyId: json['courier_company_id'] as int,
      status: json['status'] as String,
      profilePictureId: json['profile_picture_id'] as int?,
      additionalDocumentsId: json['additional_documents_id'] as int?,
      ratingAggregate: (json['rating_aggregate'] as num).toDouble(),
      ratingCount: json['rating_count'] as int,
    );
  }
}

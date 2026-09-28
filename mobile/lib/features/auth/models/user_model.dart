/// Modèle de données utilisateur TechSOS (Client ou Prestataire/Réparateur)
class UserModel {
  final String id;
  final String phone;
  final String fullName;
  final String role;
  final String? email;
  final String city;
  final String? workshopName;
  final String? addressZone;
  final String? bio;
  final bool? isVerified;
  final double? ratingAvg;
  final int? reviewCount;
  final String? subscriptionStatus;

  const UserModel({
    required this.id,
    required this.phone,
    required this.fullName,
    required this.role,
    this.email,
    this.city = 'Bamako',
    this.workshopName,
    this.addressZone,
    this.bio,
    this.isVerified,
    this.ratingAvg,
    this.reviewCount,
    this.subscriptionStatus,
  });

  bool get isProvider => role.toUpperCase() == 'PROVIDER';
  bool get isClient => role.toUpperCase() == 'CLIENT';

  /// Désérialisation depuis le JSON backend ou local
  factory UserModel.fromJson(Map<String, dynamic> json) {
    final profile = json['providerProfile'] as Map<String, dynamic>?;

    double? parseRating(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString());
    }

    int? parseInt(dynamic val) {
      if (val == null) return null;
      if (val is int) return val;
      return int.tryParse(val.toString());
    }

    return UserModel(
      id: json['id'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      role: json['role'] as String? ?? 'CLIENT',
      email: json['email'] as String?,
      city: json['city'] as String? ?? 'Bamako',
      workshopName: (json['workshopName'] ?? profile?['workshopName']) as String?,
      addressZone: (json['addressZone'] ?? profile?['addressZone']) as String?,
      bio: (json['bio'] ?? profile?['bio']) as String?,
      isVerified: (json['isVerified'] ?? profile?['isVerified']) as bool?,
      ratingAvg: parseRating(json['ratingAvg'] ?? profile?['ratingAvg']),
      reviewCount: parseInt(json['reviewCount'] ?? profile?['reviewCount']),
      subscriptionStatus: (json['subscriptionStatus'] ?? profile?['subscriptionStatus']) as String?,
    );
  }

  /// Sérialisation en JSON pour le stockage local ou requêtes
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'fullName': fullName,
      'role': role,
      if (email != null) 'email': email,
      'city': city,
      if (workshopName != null) 'workshopName': workshopName,
      if (addressZone != null) 'addressZone': addressZone,
      if (bio != null) 'bio': bio,
      if (isVerified != null) 'isVerified': isVerified,
      if (ratingAvg != null) 'ratingAvg': ratingAvg,
      if (reviewCount != null) 'reviewCount': reviewCount,
      if (subscriptionStatus != null) 'subscriptionStatus': subscriptionStatus,
    };
  }

  UserModel copyWith({
    String? id,
    String? phone,
    String? fullName,
    String? role,
    String? email,
    String? city,
    String? workshopName,
    String? addressZone,
    String? bio,
    bool? isVerified,
    double? ratingAvg,
    int? reviewCount,
    String? subscriptionStatus,
  }) {
    return UserModel(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      email: email ?? this.email,
      city: city ?? this.city,
      workshopName: workshopName ?? this.workshopName,
      addressZone: addressZone ?? this.addressZone,
      bio: bio ?? this.bio,
      isVerified: isVerified ?? this.isVerified,
      ratingAvg: ratingAvg ?? this.ratingAvg,
      reviewCount: reviewCount ?? this.reviewCount,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          phone == other.phone &&
          fullName == other.fullName &&
          role == other.role &&
          email == other.email &&
          city == other.city &&
          workshopName == other.workshopName &&
          addressZone == other.addressZone &&
          bio == other.bio &&
          isVerified == other.isVerified &&
          ratingAvg == other.ratingAvg &&
          reviewCount == other.reviewCount &&
          subscriptionStatus == other.subscriptionStatus;

  @override
  int get hashCode =>
      id.hashCode ^
      phone.hashCode ^
      fullName.hashCode ^
      role.hashCode ^
      email.hashCode ^
      city.hashCode ^
      workshopName.hashCode ^
      addressZone.hashCode ^
      bio.hashCode ^
      isVerified.hashCode ^
      ratingAvg.hashCode ^
      reviewCount.hashCode ^
      subscriptionStatus.hashCode;
}

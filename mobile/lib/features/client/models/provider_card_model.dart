import 'dart:convert';

/// Modèle pour les réparateurs recommandés affichés sur l'écran d'accueil Client
class ProviderCardModel {
  final String id;
  final String userId;
  final String workshopName;
  final String? addressZone;
  final String city;
  final double ratingAvg;
  final int reviewCount;
  final bool isVerified;
  final String? phone;
  final String? bio;
  final List<String> specialties;

  const ProviderCardModel({
    required this.id,
    required this.userId,
    required this.workshopName,
    this.addressZone,
    this.city = 'Bamako',
    this.ratingAvg = 0.0,
    this.reviewCount = 0,
    this.isVerified = false,
    this.phone,
    this.bio,
    this.specialties = const [],
  });

  factory ProviderCardModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;

    double parseRating(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      return int.tryParse(val.toString()) ?? 0;
    }

    List<String> parseSpecialties(dynamic val) {
      if (val == null) return [];
      if (val is List) return val.map((e) => e.toString()).toList();
      try {
        final decoded = jsonDecode(val.toString());
        if (decoded is List) return decoded.map((e) => e.toString()).toList();
      } catch (_) {}
      return [];
    }

    return ProviderCardModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? user?['id']?.toString() ?? '',
      workshopName: json['workshopName']?.toString() ?? 'Atelier Tech Bamako',
      addressZone: json['addressZone']?.toString(),
      city: json['city']?.toString() ?? user?['city']?.toString() ?? 'Bamako',
      ratingAvg: parseRating(json['ratingAvg']),
      reviewCount: parseInt(json['reviewCount']),
      isVerified: json['isVerified'] as bool? ?? false,
      phone: user?['phone']?.toString() ?? json['phone']?.toString(),
      bio: json['bio']?.toString(),
      specialties: parseSpecialties(json['specialtiesJson'] ?? json['specialties']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'workshopName': workshopName,
      if (addressZone != null) 'addressZone': addressZone,
      'city': city,
      'ratingAvg': ratingAvg,
      'reviewCount': reviewCount,
      'isVerified': isVerified,
      if (phone != null) 'phone': phone,
      if (bio != null) 'bio': bio,
      'specialties': specialties,
    };
  }
}

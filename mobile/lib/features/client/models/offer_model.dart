/// Modèle de proposition / devis d'un réparateur pour une annonce de panne SOS
class OfferModel {
  final String id;
  final String repairRequestId;
  final String providerId;
  final String workshopName;
  final String? providerPhone;
  final double providerRating;
  final int providerReviewCount;
  final int priceCfa;
  final String estimatedDuration;
  final String? comment;
  final String status;
  final DateTime createdAt;
  final String? repairTitle;
  final String? categoryName;
  final String? issueTypeName;
  final String? clientName;
  final String? clientPhone;
  final String? clientCity;

  const OfferModel({
    required this.id,
    required this.repairRequestId,
    required this.providerId,
    required this.workshopName,
    this.providerPhone,
    this.providerRating = 0.0,
    this.providerReviewCount = 0,
    required this.priceCfa,
    required this.estimatedDuration,
    this.comment,
    this.status = 'PENDING',
    required this.createdAt,
    this.repairTitle,
    this.categoryName,
    this.issueTypeName,
    this.clientName,
    this.clientPhone,
    this.clientCity,
  });

  bool get isPending => status.toUpperCase() == 'PENDING';
  bool get isAccepted => status.toUpperCase() == 'ACCEPTED';
  bool get isRejected => status.toUpperCase() == 'REJECTED';

  /// Désérialisation depuis la réponse de l'API REST TechSOS
  factory OfferModel.fromJson(Map<String, dynamic> json) {
    final provider = json['provider'] as Map<String, dynamic>?;
    final user = provider?['user'] as Map<String, dynamic>?;
    final repair = json['repairRequest'] as Map<String, dynamic>?;
    final category = repair?['category'] as Map<String, dynamic>?;
    final issueType = repair?['issueType'] as Map<String, dynamic>?;
    final client = repair?['client'] as Map<String, dynamic>?;

    final resolvedTitle = repair?['customIssueTitle']?.toString() ??
        repair?['title']?.toString() ??
        issueType?['name']?.toString();

    double parseRating(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    int parseInt(dynamic val, [int fallback = 0]) {
      if (val == null) return fallback;
      if (val is int) return val;
      return int.tryParse(val.toString()) ?? fallback;
    }

    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is DateTime) return val;
      return DateTime.tryParse(val.toString()) ?? DateTime.now();
    }

    return OfferModel(
      id: json['id']?.toString() ?? '',
      repairRequestId: json['repairRequestId']?.toString() ?? '',
      providerId: json['providerId']?.toString() ?? '',
      workshopName: json['workshopName']?.toString() ??
          provider?['workshopName']?.toString() ??
          'Atelier Réparateur',
      providerPhone: json['providerPhone']?.toString() ??
          user?['phone']?.toString(),
      providerRating: parseRating(json['providerRating'] ?? provider?['ratingAvg']),
      providerReviewCount: parseInt(json['providerReviewCount'] ?? provider?['reviewCount']),
      priceCfa: parseInt(json['priceCfa']),
      estimatedDuration: json['estimatedDuration']?.toString() ?? '',
      comment: json['comment']?.toString(),
      status: json['status']?.toString() ?? 'PENDING',
      createdAt: parseDate(json['createdAt']),
      repairTitle: resolvedTitle,
      categoryName: category?['name']?.toString(),
      issueTypeName: issueType?['name']?.toString(),
      clientName: client?['fullName']?.toString(),
      clientPhone: client?['phone']?.toString(),
      clientCity: client?['city']?.toString(),
    );
  }

  /// Sérialisation en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'repairRequestId': repairRequestId,
      'providerId': providerId,
      'workshopName': workshopName,
      if (providerPhone != null) 'providerPhone': providerPhone,
      'providerRating': providerRating,
      'providerReviewCount': providerReviewCount,
      'priceCfa': priceCfa,
      'estimatedDuration': estimatedDuration,
      if (comment != null) 'comment': comment,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  OfferModel copyWith({
    String? id,
    String? repairRequestId,
    String? providerId,
    String? workshopName,
    String? providerPhone,
    double? providerRating,
    int? providerReviewCount,
    int? priceCfa,
    String? estimatedDuration,
    String? comment,
    String? status,
    DateTime? createdAt,
  }) {
    return OfferModel(
      id: id ?? this.id,
      repairRequestId: repairRequestId ?? this.repairRequestId,
      providerId: providerId ?? this.providerId,
      workshopName: workshopName ?? this.workshopName,
      providerPhone: providerPhone ?? this.providerPhone,
      providerRating: providerRating ?? this.providerRating,
      providerReviewCount: providerReviewCount ?? this.providerReviewCount,
      priceCfa: priceCfa ?? this.priceCfa,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      comment: comment ?? this.comment,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OfferModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          repairRequestId == other.repairRequestId &&
          providerId == other.providerId &&
          priceCfa == other.priceCfa &&
          status == other.status;

  @override
  int get hashCode =>
      id.hashCode ^
      repairRequestId.hashCode ^
      providerId.hashCode ^
      priceCfa.hashCode ^
      status.hashCode;
}

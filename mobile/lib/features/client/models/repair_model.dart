import 'dart:convert';
import 'offer_model.dart';

/// Modèle de demande de réparation SOS pour un client
class RepairModel {
  final String id;
  final String categoryId;
  final String? categoryName;
  final String? issueTypeId;
  final String? issueTypeName;
  final String? customIssueTitle;
  final String descriptionText;
  final String? voiceAudioUrl;
  final List<String> photoUrls;
  final String status;
  final String? locationAddress;
  final DateTime createdAt;
  final int offersCount;
  final String? selectedOfferId;
  final List<OfferModel>? offers;

  const RepairModel({
    required this.id,
    required this.categoryId,
    this.categoryName,
    this.issueTypeId,
    this.issueTypeName,
    this.customIssueTitle,
    required this.descriptionText,
    this.voiceAudioUrl,
    this.photoUrls = const [],
    this.status = 'PENDING',
    this.locationAddress,
    required this.createdAt,
    this.offersCount = 0,
    this.selectedOfferId,
    this.offers,
  });

  /// Titre d'affichage principal pour la carte ou l'en-tête
  String get displayTitle {
    if (customIssueTitle != null && customIssueTitle!.isNotEmpty) {
      return customIssueTitle!;
    }
    if (issueTypeName != null && issueTypeName!.isNotEmpty) {
      return issueTypeName!;
    }
    if (categoryName != null && categoryName!.isNotEmpty) {
      return 'Dépannage $categoryName';
    }
    return 'Demande de dépannage';
  }

  /// Nom de la panne ou titre personnalisé
  String get displayIssue {
    if (customIssueTitle != null && customIssueTitle!.isNotEmpty) {
      return customIssueTitle!;
    }
    return issueTypeName ?? 'Panne non spécifiée';
  }

  bool get isPending => status.toUpperCase() == 'PENDING';
  bool get hasOffers =>
      status.toUpperCase() == 'OFFERS_RECEIVED' || offersCount > 0;
  bool get isInProgress => status.toUpperCase() == 'IN_PROGRESS';
  bool get isCompleted => status.toUpperCase() == 'COMPLETED';
  bool get isCancelled => status.toUpperCase() == 'CANCELLED';

  /// Désérialisation depuis le JSON backend ou le cache local
  factory RepairModel.fromJson(Map<String, dynamic> json) {
    // Parsing des photos
    List<String> photos = [];
    if (json['photoUrls'] is List) {
      photos = (json['photoUrls'] as List).map((e) => e.toString()).toList();
    } else if (json['photoUrlsJson'] != null) {
      try {
        final decoded = jsonDecode(json['photoUrlsJson'].toString());
        if (decoded is List) {
          photos = decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {}
    }

    // Parsing du nombre d'offres
    int count = 0;
    if (json['offersCount'] != null) {
      count = int.tryParse(json['offersCount'].toString()) ?? 0;
    } else if (json['_count'] is Map && json['_count']['offers'] != null) {
      count = int.tryParse(json['_count']['offers'].toString()) ?? 0;
    } else if (json['offers'] is List) {
      count = (json['offers'] as List).length;
    }

    // Parsing des offres
    List<OfferModel>? offersList;
    if (json['offers'] is List) {
      offersList = (json['offers'] as List)
          .whereType<Map<String, dynamic>>()
          .map((item) => OfferModel.fromJson(item))
          .toList();
    }

    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is DateTime) return val;
      return DateTime.tryParse(val.toString()) ?? DateTime.now();
    }

    final categoryObj = json['category'] as Map<String, dynamic>?;
    final issueTypeObj = json['issueType'] as Map<String, dynamic>?;

    return RepairModel(
      id: json['id']?.toString() ?? '',
      categoryId: json['categoryId']?.toString() ?? '',
      categoryName: json['categoryName']?.toString() ?? categoryObj?['name']?.toString(),
      issueTypeId: json['issueTypeId']?.toString(),
      issueTypeName: json['issueTypeName']?.toString() ?? issueTypeObj?['name']?.toString(),
      customIssueTitle: json['customIssueTitle']?.toString(),
      descriptionText: json['descriptionText']?.toString() ?? '',
      voiceAudioUrl: json['voiceAudioUrl']?.toString(),
      photoUrls: photos,
      status: json['status']?.toString() ?? 'PENDING',
      locationAddress: json['locationAddress']?.toString(),
      createdAt: parseDate(json['createdAt']),
      offersCount: count,
      selectedOfferId: json['selectedOfferId']?.toString(),
      offers: offersList,
    );
  }

  /// Sérialisation en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      if (categoryName != null) 'categoryName': categoryName,
      if (issueTypeId != null) 'issueTypeId': issueTypeId,
      if (issueTypeName != null) 'issueTypeName': issueTypeName,
      if (customIssueTitle != null) 'customIssueTitle': customIssueTitle,
      'descriptionText': descriptionText,
      if (voiceAudioUrl != null) 'voiceAudioUrl': voiceAudioUrl,
      'photoUrls': photoUrls,
      'status': status,
      if (locationAddress != null) 'locationAddress': locationAddress,
      'createdAt': createdAt.toIso8601String(),
      'offersCount': offersCount,
      if (selectedOfferId != null) 'selectedOfferId': selectedOfferId,
      if (offers != null) 'offers': offers!.map((o) => o.toJson()).toList(),
    };
  }

  RepairModel copyWith({
    String? id,
    String? categoryId,
    String? categoryName,
    String? issueTypeId,
    String? issueTypeName,
    String? customIssueTitle,
    String? descriptionText,
    String? voiceAudioUrl,
    List<String>? photoUrls,
    String? status,
    String? locationAddress,
    DateTime? createdAt,
    int? offersCount,
    String? selectedOfferId,
    List<OfferModel>? offers,
  }) {
    return RepairModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      issueTypeId: issueTypeId ?? this.issueTypeId,
      issueTypeName: issueTypeName ?? this.issueTypeName,
      customIssueTitle: customIssueTitle ?? this.customIssueTitle,
      descriptionText: descriptionText ?? this.descriptionText,
      voiceAudioUrl: voiceAudioUrl ?? this.voiceAudioUrl,
      photoUrls: photoUrls ?? this.photoUrls,
      status: status ?? this.status,
      locationAddress: locationAddress ?? this.locationAddress,
      createdAt: createdAt ?? this.createdAt,
      offersCount: offersCount ?? this.offersCount,
      selectedOfferId: selectedOfferId ?? this.selectedOfferId,
      offers: offers ?? this.offers,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RepairModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          categoryId == other.categoryId &&
          status == other.status &&
          offersCount == other.offersCount &&
          selectedOfferId == other.selectedOfferId;

  @override
  int get hashCode =>
      id.hashCode ^
      categoryId.hashCode ^
      status.hashCode ^
      offersCount.hashCode ^
      selectedOfferId.hashCode;
}

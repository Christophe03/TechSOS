import 'package:flutter/material.dart';

/// Modèle d'une fiche d'atelier de réparation (client physique ou issu de l'application)
class WorkshopEntryModel {
  final String id;
  final String providerId;
  final String origin; // 'FROM_APP' | 'WALK_IN_OFFLINE'
  final String clientName;
  final String clientPhone;
  final String deviceModel;
  final String issueSummary;
  final String? voiceNoteUrl;
  final String status; // 'DEPOSITED', 'DIAGNOSTIC', 'IN_REPAIR', 'READY_FOR_PICKUP', 'DELIVERED'
  final int? priceCfa;
  final DateTime? whatsappNotifiedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const WorkshopEntryModel({
    required this.id,
    required this.providerId,
    this.origin = 'WALK_IN_OFFLINE',
    required this.clientName,
    required this.clientPhone,
    required this.deviceModel,
    required this.issueSummary,
    this.voiceNoteUrl,
    this.status = 'DEPOSITED',
    this.priceCfa,
    this.whatsappNotifiedAt,
    required this.createdAt,
    this.updatedAt,
  });

  /// Libellé en français selon le statut de la fiche d'atelier
  static String getStatusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'DEPOSITED':
        return 'Déposé';
      case 'DIAGNOSTIC':
        return 'Diagnostic';
      case 'IN_REPAIR':
        return 'En réparation';
      case 'READY_FOR_PICKUP':
        return 'Prêt à récupérer';
      case 'DELIVERED':
        return 'Appareil rendu';
      default:
        return status;
    }
  }

  /// Couleur officielle selon le statut de la fiche d'atelier
  static Color getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'DEPOSITED':
        return const Color(0xFFD9A441); // Ambre #D9A441
      case 'DIAGNOSTIC':
        return const Color(0xFF1F3A5F); // Bleu nuit #1F3A5F
      case 'IN_REPAIR':
        return const Color(0xFFE8641C); // Orange #E8641C
      case 'READY_FOR_PICKUP':
        return const Color(0xFF2E8B57); // Vert #2E8B57
      case 'DELIVERED':
        return const Color(0xFF595959); // Gris #595959
      default:
        return const Color(0xFF595959);
    }
  }

  String get statusLabel => getStatusLabel(status);
  Color get statusColor => getStatusColor(status);

  bool get isDeposited => status.toUpperCase() == 'DEPOSITED';
  bool get isDiagnostic => status.toUpperCase() == 'DIAGNOSTIC';
  bool get isInRepair => status.toUpperCase() == 'IN_REPAIR';
  bool get isReadyForPickup => status.toUpperCase() == 'READY_FOR_PICKUP';
  bool get isDelivered => status.toUpperCase() == 'DELIVERED';

  bool get isWalkIn => origin.toUpperCase() == 'WALK_IN_OFFLINE';
  bool get isFromApp => origin.toUpperCase() == 'FROM_APP';

  /// Désérialisation depuis l'API REST TechSOS
  factory WorkshopEntryModel.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic val) {
      if (val == null) return null;
      if (val is int) return val;
      return int.tryParse(val.toString());
    }

    DateTime parseDate(dynamic val, [DateTime? fallback]) {
      if (val == null) return fallback ?? DateTime.now();
      if (val is DateTime) return val;
      return DateTime.tryParse(val.toString()) ?? (fallback ?? DateTime.now());
    }

    DateTime? parseNullableDate(dynamic val) {
      if (val == null) return null;
      if (val is DateTime) return val;
      return DateTime.tryParse(val.toString());
    }

    return WorkshopEntryModel(
      id: json['id']?.toString() ?? '',
      providerId: json['providerId']?.toString() ?? '',
      origin: json['origin']?.toString() ?? 'WALK_IN_OFFLINE',
      clientName: json['clientName']?.toString() ?? '',
      clientPhone: json['clientPhone']?.toString() ?? '',
      deviceModel: json['deviceModel']?.toString() ?? '',
      issueSummary: json['issueSummary']?.toString() ?? '',
      voiceNoteUrl: json['voiceNoteUrl']?.toString(),
      status: json['status']?.toString() ?? 'DEPOSITED',
      priceCfa: parseInt(json['priceCfa']),
      whatsappNotifiedAt: parseNullableDate(json['whatsappNotifiedAt']),
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseNullableDate(json['updatedAt']),
    );
  }

  /// Sérialisation en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'providerId': providerId,
      'origin': origin,
      'clientName': clientName,
      'clientPhone': clientPhone,
      'deviceModel': deviceModel,
      'issueSummary': issueSummary,
      if (voiceNoteUrl != null) 'voiceNoteUrl': voiceNoteUrl,
      'status': status,
      if (priceCfa != null) 'priceCfa': priceCfa,
      if (whatsappNotifiedAt != null)
        'whatsappNotifiedAt': whatsappNotifiedAt!.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  WorkshopEntryModel copyWith({
    String? id,
    String? providerId,
    String? origin,
    String? clientName,
    String? clientPhone,
    String? deviceModel,
    String? issueSummary,
    String? voiceNoteUrl,
    String? status,
    int? priceCfa,
    DateTime? whatsappNotifiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkshopEntryModel(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      origin: origin ?? this.origin,
      clientName: clientName ?? this.clientName,
      clientPhone: clientPhone ?? this.clientPhone,
      deviceModel: deviceModel ?? this.deviceModel,
      issueSummary: issueSummary ?? this.issueSummary,
      voiceNoteUrl: voiceNoteUrl ?? this.voiceNoteUrl,
      status: status ?? this.status,
      priceCfa: priceCfa ?? this.priceCfa,
      whatsappNotifiedAt: whatsappNotifiedAt ?? this.whatsappNotifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkshopEntryModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          providerId == other.providerId &&
          status == other.status &&
          priceCfa == other.priceCfa &&
          whatsappNotifiedAt == other.whatsappNotifiedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      providerId.hashCode ^
      status.hashCode ^
      priceCfa.hashCode ^
      whatsappNotifiedAt.hashCode;
}

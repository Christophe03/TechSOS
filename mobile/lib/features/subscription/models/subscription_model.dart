import 'package:flutter/material.dart';

/// Modèle pour l'état d'abonnement du réparateur TechSOS
class SubscriptionModel {
  final String status; // 'ACTIVE', 'FREE_TRIAL', 'EXPIRED'
  final String subscriptionStatus;
  final String planName;
  final int amountCfa;
  final DateTime? startDate;
  final DateTime? endDate;
  final int remainingDays;
  final bool isTrial;
  final String? transactionRef;
  final String? paymentMethod;

  const SubscriptionModel({
    required this.status,
    required this.subscriptionStatus,
    this.planName = 'Standard Pro',
    this.amountCfa = 5000,
    this.startDate,
    this.endDate,
    this.remainingDays = 0,
    this.isTrial = false,
    this.transactionRef,
    this.paymentMethod,
  });

  bool get isActive => status.toUpperCase() == 'ACTIVE';
  bool get isTrialPeriod =>
      status.toUpperCase() == 'FREE_TRIAL' ||
      subscriptionStatus.toUpperCase() == 'FREE_TRIAL' ||
      isTrial;
  bool get isExpired => status.toUpperCase() == 'EXPIRED';

  String get statusLabel {
    if (isActive) return 'Actif';
    if (isTrialPeriod) return "Période d'essai";
    return 'Expiré';
  }

  Color get statusColor {
    if (isActive) return const Color(0xFF2E8B57); // Vert
    if (isTrialPeriod) return const Color(0xFFD9A441); // Ambre
    return const Color(0xFF595959); // Gris
  }

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is DateTime) return val;
      return DateTime.tryParse(val.toString());
    }

    int parseInt(dynamic val, [int fallback = 0]) {
      if (val == null) return fallback;
      if (val is int) return val;
      return int.tryParse(val.toString()) ?? fallback;
    }

    final subObj = json['subscription'] as Map<String, dynamic>?;

    return SubscriptionModel(
      status: json['status']?.toString() ??
          json['subscriptionStatus']?.toString() ??
          'FREE_TRIAL',
      subscriptionStatus: json['subscriptionStatus']?.toString() ??
          json['status']?.toString() ??
          'FREE_TRIAL',
      planName: json['planName']?.toString() ?? 'Standard Pro',
      amountCfa: parseInt(json['amountCfa'], 5000),
      startDate: parseDate(json['startDate'] ?? subObj?['startDate']),
      endDate: parseDate(json['endDate'] ?? subObj?['endDate']),
      remainingDays: parseInt(json['remainingDays'], 0),
      isTrial: json['isTrial'] == true ||
          json['status'] == 'FREE_TRIAL' ||
          json['subscriptionStatus'] == 'FREE_TRIAL',
      transactionRef: json['transactionRef']?.toString() ??
          subObj?['transactionRef']?.toString(),
      paymentMethod: json['paymentMethod']?.toString() ??
          subObj?['paymentMethod']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'subscriptionStatus': subscriptionStatus,
      'planName': planName,
      'amountCfa': amountCfa,
      if (startDate != null) 'startDate': startDate!.toIso8601String(),
      if (endDate != null) 'endDate': endDate!.toIso8601String(),
      'remainingDays': remainingDays,
      'isTrial': isTrial,
      if (transactionRef != null) 'transactionRef': transactionRef,
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
    };
  }
}

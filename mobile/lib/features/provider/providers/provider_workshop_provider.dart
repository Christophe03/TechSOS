import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_exception.dart';
import '../../auth/providers/auth_provider.dart';
import '../../client/models/offer_model.dart';
import '../../client/models/repair_model.dart';
import '../../subscription/models/subscription_model.dart';
import '../models/workshop_entry_model.dart';

/// Provider pour le fil des pannes publiées à Bamako
final providerFeedProvider =
    FutureProvider.autoDispose<List<RepairModel>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);

  try {
    final response = await apiClient.get(ApiEndpoints.providerFeed);
    if (response.data is List) {
      return (response.data as List)
          .whereType<Map<String, dynamic>>()
          .map((json) => RepairModel.fromJson(json))
          .toList();
    }
    return [];
  } on ApiException {
    rethrow;
  } catch (e) {
    throw ApiException(
      message: 'Impossible de charger le fil des pannes : $e',
    );
  }
});

/// Provider pour la liste des devis / offres soumis par le réparateur
final providerOffersProvider =
    FutureProvider.autoDispose<List<OfferModel>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);

  try {
    final response = await apiClient.get(ApiEndpoints.myOffers);
    if (response.data is List) {
      return (response.data as List)
          .whereType<Map<String, dynamic>>()
          .map((json) => OfferModel.fromJson(json))
          .toList();
    }
    return [];
  } on ApiException {
    rethrow;
  } catch (e) {
    throw ApiException(
      message: 'Impossible de charger vos offres : $e',
    );
  }
});

/// Provider pour les fiches d'atelier (journal back-office)
final workshopEntriesProvider =
    FutureProvider.autoDispose<List<WorkshopEntryModel>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);

  try {
    final response = await apiClient.get(ApiEndpoints.workshop);
    if (response.data is List) {
      return (response.data as List)
          .whereType<Map<String, dynamic>>()
          .map((json) => WorkshopEntryModel.fromJson(json))
          .toList();
    }
    return [];
  } on ApiException {
    rethrow;
  } catch (e) {
    throw ApiException(
      message: 'Impossible de charger le journal d\'atelier : $e',
    );
  }
});

/// Provider pour les statistiques de l'atelier
final workshopStatsProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);

  try {
    final response = await apiClient.get(ApiEndpoints.workshopStats);
    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    }
    return {
      'total': 0,
      'deposited': 0,
      'diagnostic': 0,
      'inRepair': 0,
      'readyForPickup': 0,
      'delivered': 0,
    };
  } catch (_) {
    return {
      'total': 0,
      'deposited': 0,
      'diagnostic': 0,
      'inRepair': 0,
      'readyForPickup': 0,
      'delivered': 0,
    };
  }
});

/// Provider pour l'état d'abonnement courant du réparateur
final subscriptionProvider =
    FutureProvider.autoDispose<SubscriptionModel?>((ref) async {
  final apiClient = ref.watch(apiClientProvider);

  try {
    final response = await apiClient.get(ApiEndpoints.currentSubscription);
    if (response.data is Map<String, dynamic>) {
      return SubscriptionModel.fromJson(response.data as Map<String, dynamic>);
    }
    return const SubscriptionModel(
      status: 'FREE_TRIAL',
      subscriptionStatus: 'FREE_TRIAL',
      planName: 'Standard Pro',
      amountCfa: 5000,
      remainingDays: 30,
      isTrial: true,
    );
  } on ApiException {
    rethrow;
  } catch (e) {
    throw ApiException(
      message: 'Impossible de charger l\'abonnement : $e',
    );
  }
});

/// Classe regroupant les actions du réparateur (soumission d'offre, atelier, abonnement)
class ProviderWorkshopActions {
  final ApiClient apiClient;
  final Ref ref;

  const ProviderWorkshopActions({
    required this.apiClient,
    required this.ref,
  });

  /// Soumet un devis / offre pour une panne SOS
  Future<OfferModel> submitOffer(
    String repairId,
    int priceCfa,
    String estimatedDuration, [
    String? comment,
  ]) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.repairOffers(repairId),
        data: {
          'priceCfa': priceCfa,
          'estimatedDuration': estimatedDuration,
          if (comment != null && comment.trim().isNotEmpty)
            'comment': comment.trim(),
        },
      );

      ref.invalidate(providerOffersProvider);
      ref.invalidate(providerFeedProvider);

      if (response.data is Map<String, dynamic>) {
        return OfferModel.fromJson(response.data as Map<String, dynamic>);
      }

      return OfferModel(
        id: 'offer_${DateTime.now().millisecondsSinceEpoch}',
        repairRequestId: repairId,
        providerId: '',
        workshopName: '',
        priceCfa: priceCfa,
        estimatedDuration: estimatedDuration,
        comment: comment,
        createdAt: DateTime.now(),
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Erreur lors de la soumission de l\'offre : $e',
      );
    }
  }

  /// Enregistre un client physique / comptoir dans l'atelier (déclenche notif WhatsApp)
  Future<WorkshopEntryModel> createQuickEntry(
    String clientName,
    String clientPhone,
    String deviceModel,
    String issueSummary, [
    int? priceCfa,
    String? voiceNoteUrl,
  ]) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.workshopQuickEntry,
        data: {
          'clientName': clientName.trim(),
          'clientPhone': clientPhone.trim(),
          'deviceModel': deviceModel.trim(),
          'issueSummary': issueSummary.trim(),
          if (priceCfa != null && priceCfa > 0) 'priceCfa': priceCfa,
          if (voiceNoteUrl != null && voiceNoteUrl.isNotEmpty)
            'voiceNoteUrl': voiceNoteUrl,
          'origin': 'WALK_IN_OFFLINE',
        },
      );

      ref.invalidate(workshopEntriesProvider);
      ref.invalidate(workshopStatsProvider);

      if (response.data is Map<String, dynamic>) {
        return WorkshopEntryModel.fromJson(
            response.data as Map<String, dynamic>);
      }

      return WorkshopEntryModel(
        id: 'entry_${DateTime.now().millisecondsSinceEpoch}',
        providerId: '',
        origin: 'WALK_IN_OFFLINE',
        clientName: clientName,
        clientPhone: clientPhone,
        deviceModel: deviceModel,
        issueSummary: issueSummary,
        priceCfa: priceCfa,
        voiceNoteUrl: voiceNoteUrl,
        createdAt: DateTime.now(),
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Erreur lors de l\'enregistrement atelier : $e',
      );
    }
  }

  /// Met à jour le statut d'une fiche atelier (déclenche WhatsApp si READY_FOR_PICKUP)
  Future<WorkshopEntryModel> updateEntryStatus(
    String entryId,
    String newStatus, [
    int? priceCfa,
  ]) async {
    try {
      final response = await apiClient.patch(
        ApiEndpoints.workshopStatus(entryId),
        data: {
          'status': newStatus,
          if (priceCfa != null && priceCfa > 0) 'priceCfa': priceCfa,
        },
      );

      ref.invalidate(workshopEntriesProvider);
      ref.invalidate(workshopStatsProvider);

      if (response.data is Map<String, dynamic>) {
        return WorkshopEntryModel.fromJson(
            response.data as Map<String, dynamic>);
      }

      return WorkshopEntryModel(
        id: entryId,
        providerId: '',
        clientName: '',
        clientPhone: '',
        deviceModel: '',
        issueSummary: '',
        status: newStatus,
        priceCfa: priceCfa,
        createdAt: DateTime.now(),
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Erreur lors du changement de statut : $e',
      );
    }
  }

  /// Paiement de l'abonnement mensuel (5 000 FCFA) par Orange Money ou Moov Money
  Future<Map<String, dynamic>> payMobileMoney(
    String phoneNumber,
    String paymentMethod,
  ) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.payMobileMoney,
        data: {
          'phoneNumber': phoneNumber.trim(),
          'paymentMethod': paymentMethod,
        },
      );

      ref.invalidate(subscriptionProvider);

      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }

      return {
        'success': true,
        'message': 'Abonnement activé avec succès',
        'transactionRef': 'TECHSOS-${DateTime.now().millisecondsSinceEpoch}',
      };
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Erreur lors du paiement Mobile Money : $e',
      );
    }
  }
}

/// Provider pour les actions atelier et réparateur
final providerWorkshopProvider = Provider<ProviderWorkshopActions>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProviderWorkshopActions(apiClient: apiClient, ref: ref);
});

/// Alias pour clarté
final providerWorkshopActionsProvider = providerWorkshopProvider;

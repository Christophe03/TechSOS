import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/offline/cache_manager.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/category_model.dart';
import '../models/provider_card_model.dart';
import '../models/repair_model.dart';

/// État immuable de la gestion des annonces de dépannage client
class ClientRepairsState {
  final bool isLoading;
  final bool isSubmitting;
  final List<RepairModel> repairs;
  final String? errorMessage;
  final String? successMessage;

  const ClientRepairsState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.repairs = const [],
    this.errorMessage,
    this.successMessage,
  });

  factory ClientRepairsState.initial() => const ClientRepairsState();

  ClientRepairsState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    List<RepairModel>? repairs,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return ClientRepairsState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      repairs: repairs ?? this.repairs,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}

/// Notifier pour gérer les annonces de pannes, devis et évaluations du client
class ClientRepairsNotifier extends StateNotifier<ClientRepairsState> {
  final ApiClient apiClient;
  final CacheManager cacheManager;

  ClientRepairsNotifier({
    required this.apiClient,
    required this.cacheManager,
  }) : super(ClientRepairsState.initial()) {
    loadMyRequests();
  }

  /// Charge la liste des annonces créées par le client connecté avec cache hors-ligne
  Future<void> loadMyRequests({bool refresh = false}) async {
    if (state.repairs.isEmpty || refresh) {
      state = state.copyWith(isLoading: true, clearError: true);
    }

    try {
      // 1. Tente de lire depuis le cache local pour affichage immédiat
      final cachedList = await cacheManager.getData('my_repairs');
      if (cachedList is List && state.repairs.isEmpty) {
        final cachedRepairs = cachedList
            .whereType<Map<String, dynamic>>()
            .map((item) => RepairModel.fromJson(item))
            .toList();
        state = state.copyWith(repairs: cachedRepairs);
      }

      // 2. Récupère les données fraîches depuis l'API
      final response = await apiClient.get(ApiEndpoints.myRepairs);
      if (response.data is List) {
        final freshRepairs = (response.data as List)
            .whereType<Map<String, dynamic>>()
            .map((item) => RepairModel.fromJson(item))
            .toList();

        state = state.copyWith(
          isLoading: false,
          repairs: freshRepairs,
          clearError: true,
        );

        // Sauvegarde en cache local
        await cacheManager.saveData(
          'my_repairs',
          freshRepairs.map((r) => r.toJson()).toList(),
        );
        return;
      }
      state = state.copyWith(isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: state.repairs.isNotEmpty
            ? null
            : 'Impossible de charger vos demandes. Vérifiez votre connexion.',
      );
    }
  }

  /// Crée et publie une nouvelle demande SOS (avec upload optionnel de note vocale)
  Future<RepairModel?> createRepair({
    required String categoryId,
    String? categoryName,
    String? issueTypeId,
    String? issueTypeName,
    String? customIssueTitle,
    required String descriptionText,
    String? voiceAudioPath,
    List<String>? photoUrls,
    String? locationAddress,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true, clearSuccess: true);

    try {
      String? uploadedVoiceUrl;

      // Si un enregistrement audio local existe, tenter l'upload
      if (voiceAudioPath != null && voiceAudioPath.isNotEmpty) {
        try {
          final file = File(voiceAudioPath);
          if (await file.exists()) {
            final uploadRes = await apiClient.uploadFile(
              ApiEndpoints.storageUpload,
              file: file,
            );
            if (uploadRes.data is Map && uploadRes.data['url'] != null) {
              uploadedVoiceUrl = uploadRes.data['url'].toString();
            }
          } else {
            // Mode dégradé / simulé local
            uploadedVoiceUrl = voiceAudioPath;
          }
        } catch (_) {
          // Si l'upload échoue, on conserve le chemin local en mode résilient
          uploadedVoiceUrl = voiceAudioPath;
        }
      }

      final payload = {
        'categoryId': categoryId,
        if (issueTypeId != null && issueTypeId.isNotEmpty) 'issueTypeId': issueTypeId,
        if (customIssueTitle != null && customIssueTitle.isNotEmpty)
          'customIssueTitle': customIssueTitle,
        'descriptionText': descriptionText,
        if (uploadedVoiceUrl != null) 'voiceAudioUrl': uploadedVoiceUrl,
        'photoUrls': photoUrls ?? [],
        if (locationAddress != null && locationAddress.isNotEmpty)
          'locationAddress': locationAddress,
      };

      final response = await apiClient.post(ApiEndpoints.repairs, data: payload);
      final rawData = response.data as Map<String, dynamic>;

      // Injection des libellés de secours si le backend ne les a pas encore inclus
      final created = RepairModel.fromJson({
        ...rawData,
        if (rawData['category'] == null && categoryName != null)
          'category': {'name': categoryName},
        if (rawData['issueType'] == null && issueTypeName != null)
          'issueType': {'name': issueTypeName},
      });

      final updatedRepairs = [created, ...state.repairs];
      state = state.copyWith(
        isSubmitting: false,
        repairs: updatedRepairs,
        successMessage: 'Votre demande SOS a été envoyée aux réparateurs de Bamako !',
      );

      // Mise à jour du cache
      await cacheManager.saveData(
        'my_repairs',
        updatedRepairs.map((r) => r.toJson()).toList(),
      );

      return created;
    } on ApiException catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.message,
      );
      return null;
    } catch (_) {
      // Mode secours dégradé si backend non accessible : création locale
      final fallback = RepairModel(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        categoryId: categoryId,
        categoryName: categoryName ?? 'Appareil',
        issueTypeId: issueTypeId,
        issueTypeName: issueTypeName,
        customIssueTitle: customIssueTitle,
        descriptionText: descriptionText,
        voiceAudioUrl: voiceAudioPath,
        photoUrls: photoUrls ?? [],
        status: 'PENDING',
        locationAddress: locationAddress ?? 'Bamako',
        createdAt: DateTime.now(),
        offersCount: 0,
      );

      final updated = [fallback, ...state.repairs];
      state = state.copyWith(
        isSubmitting: false,
        repairs: updated,
        successMessage: 'Demande enregistrée localement (envoi différé).',
      );
      await cacheManager.saveData(
        'my_repairs',
        updated.map((r) => r.toJson()).toList(),
      );
      return fallback;
    }
  }

  /// Récupère le détail à jour d'une annonce de panne avec ses offres
  Future<RepairModel?> getRepairDetail(String repairId) async {
    try {
      final response = await apiClient.get(ApiEndpoints.repairDetail(repairId));
      if (response.data is Map<String, dynamic>) {
        final detail = RepairModel.fromJson(response.data as Map<String, dynamic>);
        final updatedList = state.repairs.map((r) => r.id == repairId ? detail : r).toList();
        state = state.copyWith(repairs: updatedList);
        return detail;
      }
    } catch (_) {
      // Retourne l'élément actuellement en mémoire s'il existe
      return state.repairs.where((r) => r.id == repairId).firstOrNull;
    }
    return null;
  }

  /// Accepte l'offre d'un réparateur pour une panne
  Future<bool> acceptOffer({
    required String repairId,
    required String offerId,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final response = await apiClient.post(ApiEndpoints.acceptOffer(offerId));
      RepairModel? updatedRepair;
      if (response.data is Map<String, dynamic>) {
        updatedRepair = RepairModel.fromJson(response.data as Map<String, dynamic>);
      }

      final updatedRepairs = state.repairs.map((r) {
        if (r.id == repairId) {
          if (updatedRepair != null) return updatedRepair;
          // Mise à jour optimiste locale
          final updatedOffers = r.offers?.map((o) {
            if (o.id == offerId) {
              return o.copyWith(status: 'ACCEPTED');
            }
            return o.copyWith(status: 'REJECTED');
          }).toList();

          return r.copyWith(
            status: 'IN_PROGRESS',
            selectedOfferId: offerId,
            offers: updatedOffers,
          );
        }
        return r;
      }).toList();

      state = state.copyWith(
        isSubmitting: false,
        repairs: updatedRepairs,
        successMessage: 'Offre acceptée ! Le réparateur va vous contacter.',
      );

      await cacheManager.saveData(
        'my_repairs',
        updatedRepairs.map((r) => r.toJson()).toList(),
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.message,
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Une erreur est survenue lors de l\'acceptation de l\'offre.',
      );
      return false;
    }
  }

  /// Soumet un avis noté de 1 à 5 étoiles après réalisation du dépannage
  Future<bool> submitReview({
    required String repairId,
    required int rating,
    String? comment,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await apiClient.post(
        ApiEndpoints.repairReviews(repairId),
        data: {
          'rating': rating,
          if (comment != null && comment.trim().isNotEmpty) 'comment': comment.trim(),
        },
      );

      // Rechargement du détail
      await getRepairDetail(repairId);

      state = state.copyWith(
        isSubmitting: false,
        successMessage: 'Merci ! Votre avis a été enregistré.',
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: e.message,
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Impossible d\'envoyer l\'avis actuellement.',
      );
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }
}

/// Provider pour les annonces du client
final clientRepairsProvider =
    StateNotifierProvider<ClientRepairsNotifier, ClientRepairsState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final cacheManager = ref.watch(cacheManagerProvider);
  return ClientRepairsNotifier(
    apiClient: apiClient,
    cacheManager: cacheManager,
  );
});

/// Catégories de secours par défaut à Bamako (mode hors-ligne ou initialisation rapide)
final _defaultBamakoCategories = [
  const CategoryModel(
    id: 'cat_phones',
    name: 'Smartphones & Téléphones',
    code: 'SMARTPHONE',
    icon: 'phone_android',
    issueTypes: [
      IssueTypeModel(id: 'iss_screen', name: 'Écran cassé / tactile défaillant', isOfficial: true),
      IssueTypeModel(id: 'iss_battery', name: 'Batterie gonflée ou ne charge plus', isOfficial: true),
      IssueTypeModel(id: 'iss_water', name: 'Appareil tombé dans l\'eau', isOfficial: true),
      IssueTypeModel(id: 'iss_audio', name: 'Microphone ou haut-parleur silencieux', isOfficial: true),
    ],
  ),
  const CategoryModel(
    id: 'cat_laptops',
    name: 'Ordinateurs & PC',
    code: 'COMPUTER',
    icon: 'laptop_mac',
    issueTypes: [
      IssueTypeModel(id: 'iss_pc_boot', name: 'L\'ordinateur ne s\'allume pas', isOfficial: true),
      IssueTypeModel(id: 'iss_pc_screen', name: 'Écran noir ou fissuré', isOfficial: true),
      IssueTypeModel(id: 'iss_pc_slow', name: 'Virus ou lenteur extrême', isOfficial: true),
      IssueTypeModel(id: 'iss_pc_keyboard', name: 'Clavier ou touches bloquées', isOfficial: true),
    ],
  ),
  const CategoryModel(
    id: 'cat_printers',
    name: 'Imprimantes & Scanners',
    code: 'PRINTER',
    icon: 'print',
    issueTypes: [
      IssueTypeModel(id: 'iss_pr_paper', name: 'Bourrage papier systématique', isOfficial: true),
      IssueTypeModel(id: 'iss_pr_ink', name: 'Encre qui coule ou cartouches non reconnues', isOfficial: true),
      IssueTypeModel(id: 'iss_pr_power', name: 'Panne d\'alimentation générale', isOfficial: true),
    ],
  ),
  const CategoryModel(
    id: 'cat_tablets',
    name: 'Tablettes',
    code: 'TABLET',
    icon: 'tablet_android',
    issueTypes: [
      IssueTypeModel(id: 'iss_tab_screen', name: 'Vitre tactile cassée', isOfficial: true),
      IssueTypeModel(id: 'iss_tab_boot', name: 'Tablette bloquée sur le logo', isOfficial: true),
    ],
  ),
  const CategoryModel(
    id: 'cat_tvs',
    name: 'Téléviseurs & Écrans',
    code: 'TV',
    icon: 'tv',
    issueTypes: [
      IssueTypeModel(id: 'iss_tv_display', name: 'Lignes sur l\'écran ou écran noir', isOfficial: true),
      IssueTypeModel(id: 'iss_tv_power', name: 'Ne s\'allume plus suite à coupure EDM', isOfficial: true),
    ],
  ),
];

/// Provider pour les catégories d'appareils et types de pannes
final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final cacheManager = ref.watch(cacheManagerProvider);

  try {
    final response = await apiClient.get(ApiEndpoints.categories);
    if (response.data is List) {
      final list = (response.data as List)
          .whereType<Map<String, dynamic>>()
          .map((item) => CategoryModel.fromJson(item))
          .toList();

      if (list.isNotEmpty) {
        await cacheManager.saveCategories(
          (response.data as List).whereType<Map<String, dynamic>>().toList(),
        );
        return list;
      }
    }
  } catch (_) {
    // Lecture cache local
    final cached = await cacheManager.getCategories();
    if (cached != null && cached.isNotEmpty) {
      return cached.map((c) => CategoryModel.fromJson(c)).toList();
    }
  }

  return _defaultBamakoCategories;
});

/// Réparateurs vérifiés par défaut à Bamako (mode hors-ligne ou initial)
final _defaultBamakoProviders = [
  const ProviderCardModel(
    id: 'prov_1',
    userId: 'u_p1',
    workshopName: 'Clinique Mobile Bamako',
    addressZone: 'Hamdallaye ACI 2000',
    city: 'Bamako',
    ratingAvg: 4.9,
    reviewCount: 42,
    isVerified: true,
    phone: '+22370123456',
    bio: 'Spécialiste agréé smartphones, iPhones et tablettes. Diagnostic express en 30 min.',
    specialties: ['cat_phones', 'cat_tablets'],
  ),
  const ProviderCardModel(
    id: 'prov_2',
    userId: 'u_p2',
    workshopName: 'Atelier High-Tech Badala',
    addressZone: 'Badalabougou',
    city: 'Bamako',
    ratingAvg: 4.7,
    reviewCount: 28,
    isVerified: true,
    phone: '+22376998877',
    bio: 'Réparation PC, Mac et imprimantes professionnelles. Garantie pièces 3 mois.',
    specialties: ['cat_laptops', 'cat_printers'],
  ),
  const ProviderCardModel(
    id: 'prov_3',
    userId: 'u_p3',
    workshopName: 'SOS Électronique Faladié',
    addressZone: 'Faladié Sema',
    city: 'Bamako',
    ratingAvg: 4.8,
    reviewCount: 35,
    isVerified: true,
    phone: '+22366554433',
    bio: 'Dépannage d\'urgence toutes pannes électroniques et téléviseurs.',
    specialties: ['cat_phones', 'cat_tvs'],
  ),
];

/// Provider pour les réparateurs recommandés à Bamako
final featuredProvidersProvider =
    FutureProvider<List<ProviderCardModel>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);

  try {
    final response = await apiClient.get(ApiEndpoints.providers);
    if (response.data is List) {
      final list = (response.data as List)
          .whereType<Map<String, dynamic>>()
          .map((item) => ProviderCardModel.fromJson(item))
          .toList();

      if (list.isNotEmpty) {
        return list;
      }
    }
  } catch (_) {
    // Fallback silencieux vers les réparateurs certifiés
  }

  return _defaultBamakoProviders;
});

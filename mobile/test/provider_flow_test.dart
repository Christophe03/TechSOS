import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tech_sos/app.dart';
import 'package:tech_sos/core/network/api_client.dart';
import 'package:tech_sos/core/network/api_endpoints.dart';
import 'package:tech_sos/core/offline/cache_manager.dart';
import 'package:tech_sos/core/theme/app_theme.dart';
import 'package:tech_sos/features/auth/models/user_model.dart';
import 'package:tech_sos/features/auth/providers/auth_provider.dart';
import 'package:tech_sos/features/client/models/repair_model.dart';
import 'package:tech_sos/features/provider/models/workshop_entry_model.dart';
import 'package:tech_sos/features/provider/screens/my_offers_screen.dart';
import 'package:tech_sos/features/provider/screens/provider_feed_screen.dart';
import 'package:tech_sos/features/provider/screens/provider_main_screen.dart';
import 'package:tech_sos/features/provider/screens/quick_client_entry_dialog.dart';
import 'package:tech_sos/features/provider/screens/submit_offer_dialog.dart';
import 'package:tech_sos/features/provider/screens/workshop_journal_screen.dart';
import 'package:tech_sos/features/subscription/models/subscription_model.dart';
import 'package:tech_sos/features/subscription/screens/subscription_screen.dart';

/// Fake API Client pour simuler les endpoints Provider/Workshop/Subscription
class FakeProviderApiClient extends ApiClient {
  FakeProviderApiClient({required super.cache});

  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    dynamic responseData;

    if (path == ApiEndpoints.providerFeed) {
      responseData = [
        {
          'id': 'rep_feed_1',
          'categoryId': 'cat_phones',
          'categoryName': 'Smartphones',
          'descriptionText': 'Écran cassé Samsung Galaxy A52 suite à une chute.',
          'status': 'PENDING',
          'locationAddress': 'Hamdallaye ACI 2000',
          'createdAt': '2026-09-28T10:00:00.000Z',
          'offersCount': 1,
          'voiceAudioUrl': '/uploads/voice_test.m4a',
        },
        {
          'id': 'rep_feed_2',
          'categoryId': 'cat_computers',
          'categoryName': 'Ordinateurs',
          'descriptionText': 'PC HP Pavilion ne s\'allume plus du tout.',
          'status': 'PENDING',
          'locationAddress': 'Badalabougou',
          'createdAt': '2026-09-28T11:00:00.000Z',
          'offersCount': 0,
        },
      ];
    } else if (path == ApiEndpoints.myOffers) {
      responseData = [
        {
          'id': 'off_1',
          'repairRequestId': 'rep_feed_1',
          'providerId': 'prov_test',
          'workshopName': 'Atelier Électro Bamako',
          'priceCfa': 12500,
          'estimatedDuration': '3 heures',
          'comment': 'Écran d\'origine avec garantie 3 mois',
          'status': 'PENDING',
          'createdAt': '2026-09-28T10:30:00.000Z',
        },
        {
          'id': 'off_2',
          'repairRequestId': 'rep_feed_old',
          'providerId': 'prov_test',
          'workshopName': 'Atelier Électro Bamako',
          'priceCfa': 25000,
          'estimatedDuration': '24h',
          'comment': 'Remplacement puce graphique',
          'status': 'ACCEPTED',
          'createdAt': '2026-09-27T15:00:00.000Z',
        },
      ];
    } else if (path == ApiEndpoints.workshop) {
      responseData = [
        {
          'id': 'ws_1',
          'providerId': 'prov_test',
          'origin': 'WALK_IN_OFFLINE',
          'clientName': 'Mamadou Diarra',
          'clientPhone': '+22370123456',
          'deviceModel': 'Tecno Spark 10',
          'issueSummary': 'Changement de connecteur de charge',
          'status': 'IN_REPAIR',
          'priceCfa': 7500,
          'whatsappNotifiedAt': '2026-09-28T09:00:00.000Z',
          'createdAt': '2026-09-28T09:00:00.000Z',
        },
        {
          'id': 'ws_2',
          'providerId': 'prov_test',
          'origin': 'FROM_APP',
          'clientName': 'Fatoumata Coulibaly',
          'clientPhone': '+22376998877',
          'deviceModel': 'iPhone 11',
          'issueSummary': 'Batterie gonflée à remplacer',
          'status': 'READY_FOR_PICKUP',
          'priceCfa': 18000,
          'whatsappNotifiedAt': '2026-09-28T14:00:00.000Z',
          'createdAt': '2026-09-28T11:00:00.000Z',
        },
        {
          'id': 'ws_3',
          'providerId': 'prov_test',
          'origin': 'WALK_IN_OFFLINE',
          'clientName': 'Bakary Sissoko',
          'clientPhone': '+22366554433',
          'deviceModel': 'HP Laptop 15',
          'issueSummary': 'Écran cassé',
          'status': 'DEPOSITED',
          'priceCfa': 35000,
          'createdAt': '2026-09-28T15:00:00.000Z',
        },
      ];
    } else if (path == ApiEndpoints.workshopStats) {
      responseData = {
        'total': 3,
        'deposited': 1,
        'diagnostic': 0,
        'inRepair': 1,
        'readyForPickup': 1,
        'delivered': 0,
      };
    } else if (path == ApiEndpoints.currentSubscription) {
      responseData = {
        'status': 'ACTIVE',
        'subscriptionStatus': 'ACTIVE',
        'planName': 'Standard Pro',
        'amountCfa': 5000,
        'startDate': '2026-09-01T00:00:00.000Z',
        'endDate': '2026-10-01T00:00:00.000Z',
        'remainingDays': 23,
        'isTrial': false,
      };
    } else {
      responseData = {};
    }

    return Response<T>(
      requestOptions: RequestOptions(path: path),
      statusCode: 200,
      data: responseData as T?,
    );
  }

  @override
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    dynamic responseData;

    if (path.contains('/offers')) {
      responseData = {
        'id': 'off_new_123',
        'repairRequestId': 'rep_feed_1',
        'providerId': 'prov_test',
        'priceCfa': data?['priceCfa'] ?? 10000,
        'estimatedDuration': data?['estimatedDuration'] ?? '2h',
        'comment': data?['comment'],
        'status': 'PENDING',
        'createdAt': DateTime.now().toIso8601String(),
      };
    } else if (path == ApiEndpoints.workshopQuickEntry) {
      responseData = {
        'id': 'ws_new_456',
        'providerId': 'prov_test',
        'origin': 'WALK_IN_OFFLINE',
        'clientName': data?['clientName'] ?? 'Client Test',
        'clientPhone': data?['clientPhone'] ?? '+22370000000',
        'deviceModel': data?['deviceModel'] ?? 'Appareil Test',
        'issueSummary': data?['issueSummary'] ?? 'Panne Test',
        'status': 'DEPOSITED',
        'priceCfa': data?['priceCfa'],
        'whatsappNotifiedAt': DateTime.now().toIso8601String(),
        'createdAt': DateTime.now().toIso8601String(),
      };
    } else if (path == ApiEndpoints.payMobileMoney) {
      responseData = {
        'success': true,
        'message': 'Abonnement activé avec succès',
        'transactionRef': 'TECHSOS-OM-TEST-999',
        'subscription': {
          'planName': 'Standard Pro',
          'amountCfa': 5000,
          'status': 'ACTIVE',
        },
      };
    } else {
      responseData = {'success': true};
    }

    return Response<T>(
      requestOptions: RequestOptions(path: path),
      statusCode: 200,
      data: responseData as T?,
    );
  }

  @override
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      statusCode: 200,
      data: {
        'id': 'ws_1',
        'status': data?['status'] ?? 'READY_FOR_PICKUP',
        'priceCfa': data?['priceCfa'] ?? 7500,
        'whatsappNotifiedAt': DateTime.now().toIso8601String(),
      } as T?,
    );
  }
}

const _testProviderUser = UserModel(
  id: 'u_prov_1',
  phone: '+22370123456',
  fullName: 'Amadou Konaté',
  role: 'PROVIDER',
  city: 'Bamako',
  workshopName: 'Atelier Électro Bamako',
  addressZone: 'Hamdallaye ACI 2000',
  isVerified: true,
  ratingAvg: 4.8,
  reviewCount: 35,
  subscriptionStatus: 'ACTIVE',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final fakeClient = FakeProviderApiClient(cache: CacheManager());

  Widget buildTestableWidget(
    Widget child, {
    List<Override> overrides = const [],
  }) {
    return ProviderScope(
      overrides: [
        apiClientProvider.overrideWithValue(fakeClient),
        ...overrides,
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: child,
      ),
    );
  }

  group('WorkshopEntryModel Serialization & Status Tests', () {
    test('WorkshopEntryModel fromJson, toJson and helpers', () {
      final json = {
        'id': 'ws_100',
        'providerId': 'prov_99',
        'origin': 'WALK_IN_OFFLINE',
        'clientName': 'Oumar Traoré',
        'clientPhone': '+22370112233',
        'deviceModel': 'Samsung A12',
        'issueSummary': 'Connecteur de charge dessoudé',
        'voiceNoteUrl': '/uploads/note_1.m4a',
        'status': 'DEPOSITED',
        'priceCfa': 5000,
        'whatsappNotifiedAt': '2026-09-28T08:00:00.000Z',
        'createdAt': '2026-09-28T08:00:00.000Z',
        'updatedAt': '2026-09-28T08:30:00.000Z',
      };

      final entry = WorkshopEntryModel.fromJson(json);

      expect(entry.id, 'ws_100');
      expect(entry.providerId, 'prov_99');
      expect(entry.origin, 'WALK_IN_OFFLINE');
      expect(entry.clientName, 'Oumar Traoré');
      expect(entry.clientPhone, '+22370112233');
      expect(entry.deviceModel, 'Samsung A12');
      expect(entry.issueSummary, 'Connecteur de charge dessoudé');
      expect(entry.voiceNoteUrl, '/uploads/note_1.m4a');
      expect(entry.priceCfa, 5000);
      expect(entry.isWalkIn, isTrue);
      expect(entry.isFromApp, isFalse);
      expect(entry.isDeposited, isTrue);

      final encoded = entry.toJson();
      expect(encoded['id'], 'ws_100');
      expect(encoded['deviceModel'], 'Samsung A12');
      expect(encoded['status'], 'DEPOSITED');
      expect(encoded['priceCfa'], 5000);
    });

    test('WorkshopEntryModel exact status labels and color mapping', () {
      // 1. DEPOSITED: 'Déposé' (Ambre #D9A441)
      expect(WorkshopEntryModel.getStatusLabel('DEPOSITED'), 'Déposé');
      expect(WorkshopEntryModel.getStatusColor('DEPOSITED'),
          const Color(0xFFD9A441));

      // 2. DIAGNOSTIC: 'Diagnostic' (Bleu nuit #1F3A5F)
      expect(WorkshopEntryModel.getStatusLabel('DIAGNOSTIC'), 'Diagnostic');
      expect(WorkshopEntryModel.getStatusColor('DIAGNOSTIC'),
          const Color(0xFF1F3A5F));

      // 3. IN_REPAIR: 'En réparation' (Orange #E8641C)
      expect(WorkshopEntryModel.getStatusLabel('IN_REPAIR'), 'En réparation');
      expect(WorkshopEntryModel.getStatusColor('IN_REPAIR'),
          const Color(0xFFE8641C));

      // 4. READY_FOR_PICKUP: 'Prêt à récupérer' (Vert #2E8B57)
      expect(WorkshopEntryModel.getStatusLabel('READY_FOR_PICKUP'),
          'Prêt à récupérer');
      expect(WorkshopEntryModel.getStatusColor('READY_FOR_PICKUP'),
          const Color(0xFF2E8B57));

      // 5. DELIVERED: 'Appareil rendu' (Gris #595959)
      expect(WorkshopEntryModel.getStatusLabel('DELIVERED'), 'Appareil rendu');
      expect(WorkshopEntryModel.getStatusColor('DELIVERED'),
          const Color(0xFF595959));
    });

    test('SubscriptionModel fromJson and helper getters', () {
      final json = {
        'status': 'ACTIVE',
        'subscriptionStatus': 'ACTIVE',
        'planName': 'Standard Pro',
        'amountCfa': 5000,
        'remainingDays': 25,
        'isTrial': false,
        'transactionRef': 'TECHSOS-OM-1234',
        'paymentMethod': 'ORANGE_MONEY',
      };

      final sub = SubscriptionModel.fromJson(json);

      expect(sub.isActive, isTrue);
      expect(sub.isTrialPeriod, isFalse);
      expect(sub.isExpired, isFalse);
      expect(sub.statusLabel, 'Actif');
      expect(sub.amountCfa, 5000);
      expect(sub.remainingDays, 25);
      expect(sub.planName, 'Standard Pro');
      expect(sub.transactionRef, 'TECHSOS-OM-1234');
    });
  });

  group('SubmitOfferDialog Widget & Form Validation Tests', () {
    final testRepair = RepairModel(
      id: 'rep_test_dialog',
      categoryId: 'cat_phones',
      categoryName: 'Smartphones',
      descriptionText: 'Écran tactile fissuré sur Xiaomi Redmi Note 11.',
      status: 'PENDING',
      locationAddress: 'Hamdallaye ACI 2000',
      createdAt: DateTime(2026, 9, 28),
    );

    testWidgets('SubmitOfferDialog renders fields and duration chips',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          Scaffold(
            body: SubmitOfferDialog(repair: testRepair),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Faire une offre de devis'), findsOneWidget);
      expect(find.text('Prix proposé (FCFA) *'), findsOneWidget);
      expect(find.text('Délai estimé de réparation *'), findsOneWidget);
      expect(find.text('1 heure'), findsOneWidget);
      expect(find.text('3 heures'), findsWidgets);
      expect(find.text('24h'), findsOneWidget);
      expect(find.text('Envoyer mon offre'), findsOneWidget);
    });

    testWidgets('SubmitOfferDialog validates minimum price >= 500 FCFA',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          Scaffold(
            body: SubmitOfferDialog(repair: testRepair),
          ),
        ),
      );
      await tester.pump();

      // Soumission sans prix
      await tester.ensureVisible(find.text('Envoyer mon offre'));
      await tester.tap(find.text('Envoyer mon offre'));
      await tester.pump();

      expect(find.text('Veuillez saisir un tarif'), findsOneWidget);

      // Saisie d'un prix invalide (< 500)
      final priceField = find.byType(TextFormField).first;
      await tester.enterText(priceField, '200');
      await tester.ensureVisible(find.text('Envoyer mon offre'));
      await tester.tap(find.text('Envoyer mon offre'));
      await tester.pump();

      expect(find.text('Le prix minimum est de 500 FCFA'), findsOneWidget);

      // Saisie d'un prix valide (>= 500)
      await tester.enterText(priceField, '8500');
      await tester.ensureVisible(find.text('Envoyer mon offre'));
      await tester.tap(find.text('Envoyer mon offre'));
      await tester.pump();

      expect(find.text('Le prix minimum est de 500 FCFA'), findsNothing);
    });
  });

  group('ProviderFeedScreen & MyOffersScreen Widget Tests', () {
    testWidgets('ProviderFeedScreen renders header, search and breakdown cards',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(const ProviderFeedScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Fil des pannes à Bamako'), findsOneWidget);
      expect(find.text('Tous'), findsOneWidget);
      expect(find.text('Smartphones'), findsWidgets);
      expect(find.text('Ordinateurs'), findsWidgets);

      // Vérifie la présence des pannes du FakeApiClient
      expect(find.textContaining('Samsung Galaxy A52'), findsOneWidget);
      expect(find.textContaining('HP Pavilion'), findsOneWidget);
      expect(find.text('Faire une offre'), findsNWidgets(2));
    });

    testWidgets('MyOffersScreen renders sent offers and status pills',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(const MyOffersScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mes Offres & Devis'), findsOneWidget);
      expect(find.text('12500 FCFA'), findsOneWidget);
      expect(find.text('25000 FCFA'), findsOneWidget);
      expect(find.text('En attente'), findsWidgets);
      expect(find.text('Acceptée par le client'), findsOneWidget);
    });
  });

  group('WorkshopJournalScreen & QuickClientEntryDialog Widget Tests', () {
    testWidgets('WorkshopJournalScreen renders stats, filter tabs and ticket cards',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(const WorkshopJournalScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Journal d\'atelier'), findsOneWidget);
      expect(find.text('Total appareils'), findsOneWidget);
      expect(find.text('En cours'), findsWidgets);
      expect(find.text('Prêt à récupérer'), findsWidgets);
      expect(find.text('Nouveau client'), findsOneWidget);

      // Cartes d'atelier
      expect(find.text('Tecno Spark 10'), findsOneWidget);
      expect(find.text('Mamadou Diarra • +22370123456'), findsOneWidget);
      expect(find.text('iPhone 11'), findsOneWidget);
      expect(find.text('Fatoumata Coulibaly • +22376998877'), findsOneWidget);
    });

    testWidgets('QuickClientEntryDialog renders WhatsApp banner and intake form',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const Scaffold(
            body: QuickClientEntryDialog(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Entrée atelier (Comptoir)'), findsOneWidget);
      expect(
        find.text(
            "Un message WhatsApp de confirmation sera automatiquement envoyé au client à l'enregistrement."),
        findsOneWidget,
      );
      expect(find.text('Nom complet du client *'), findsOneWidget);
      expect(find.text('Numéro de téléphone Malien (WhatsApp) *'), findsOneWidget);
      expect(find.text('Modèle de l\'appareil déposé *'), findsOneWidget);
      expect(find.text('Description de la panne constatée *'), findsOneWidget);
      expect(find.text('Enregistrer et notifier'), findsOneWidget);
    });
  });

  group('SubscriptionScreen Widget Tests', () {
    testWidgets('SubscriptionScreen renders plan, unlocked features and Mobile Money options',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(const SubscriptionScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mon Abonnement'), findsOneWidget);
      expect(find.text('Standard Pro'), findsOneWidget);
      expect(find.text('5 000 FCFA / mois'), findsOneWidget);
      expect(find.text('Actif'), findsOneWidget);

      // Avantages débloqués
      expect(find.text('Journal d\'atelier illimité'), findsOneWidget);
      expect(find.text('Notifications WhatsApp automatiques'), findsOneWidget);
      expect(find.text('Fil prioritaire des pannes'), findsOneWidget);

      // Moyens de paiement
      expect(find.text('Orange Money'), findsOneWidget);
      expect(find.text('Moov Money'), findsOneWidget);
      expect(find.text('Renouveler pour 5 000 FCFA'), findsOneWidget);
    });
  });

  group('ProviderMainScreen & Navigation Tests', () {
    testWidgets('ProviderMainScreen renders bottom navigation and allows tab switching',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(const ProviderMainScreen()),
      );
      await tester.pumpAndSettle();

      // Vérifie les 5 onglets de la BottomNavigationBar
      expect(find.text('Fil pannes'), findsOneWidget);
      expect(find.text('Mes Offres'), findsOneWidget);
      expect(find.text('Atelier'), findsOneWidget);
      expect(find.text('Abonnement'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);

      // Navigation vers Atelier
      await tester.tap(find.text('Atelier'));
      await tester.pumpAndSettle();

      expect(find.text('Journal d\'atelier'), findsOneWidget);

      // Navigation vers Abonnement
      await tester.tap(find.text('Abonnement'));
      await tester.pumpAndSettle();

      expect(find.text('Mon Abonnement'), findsOneWidget);

      // Navigation vers Profil
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();

      expect(find.text('Profil Réparateur'), findsOneWidget);
    });

    testWidgets('TechSosApp navigates to ProviderMainScreen when user is provider',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiClientProvider.overrideWithValue(fakeClient),
            authProvider.overrideWith(
              (ref) => _MockAuthNotifier(
                const AuthState(
                  isAuthenticated: true,
                  user: _testProviderUser,
                ),
              ),
            ),
          ],
          child: const TechSosApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ProviderMainScreen), findsOneWidget);
      expect(find.text('Fil pannes'), findsOneWidget);
      expect(find.text('Atelier'), findsOneWidget);
    });
  });
}

/// Mock simple de AuthNotifier pour les tests UI
class _MockAuthNotifier extends StateNotifier<AuthState>
    implements AuthNotifier {
  _MockAuthNotifier(super.initialState);

  @override
  ApiClient get apiClient => throw UnimplementedError();

  @override
  CacheManager get cacheManager => throw UnimplementedError();

  @override
  void clearError() {}

  @override
  Future<void> init() async {}

  @override
  Future<bool> login(String identifier, String password) async => true;

  @override
  Future<void> logout() async {
    state = AuthState.unauthenticated();
  }

  @override
  Future<bool> registerClient({
    required String fullName,
    required String phone,
    required String password,
    String? email,
    String? city,
    String? address,
  }) async =>
      true;

  @override
  Future<bool> registerProvider({
    required String fullName,
    required String phone,
    required String password,
    required String workshopName,
    required String addressZone,
    String? email,
    String? bio,
    List<String>? specialties,
  }) async =>
      true;
}

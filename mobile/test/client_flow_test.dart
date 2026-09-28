import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tech_sos/app.dart';
import 'package:tech_sos/core/network/api_client.dart';
import 'package:tech_sos/core/network/api_endpoints.dart';
import 'package:tech_sos/core/offline/cache_manager.dart';
import 'package:tech_sos/core/theme/app_theme.dart';
import 'package:tech_sos/core/widgets/audio_recorder_widget.dart';
import 'package:tech_sos/features/auth/models/user_model.dart';
import 'package:tech_sos/features/auth/providers/auth_provider.dart';
import 'package:tech_sos/features/client/models/category_model.dart';
import 'package:tech_sos/features/client/models/offer_model.dart';
import 'package:tech_sos/features/client/models/provider_card_model.dart';
import 'package:tech_sos/features/client/models/repair_model.dart';
import 'package:tech_sos/features/client/providers/client_repairs_provider.dart';
import 'package:tech_sos/features/client/screens/client_home_screen.dart';
import 'package:tech_sos/features/client/screens/client_main_screen.dart';
import 'package:tech_sos/features/client/screens/leave_review_dialog.dart';
import 'package:tech_sos/features/client/screens/my_requests_screen.dart';
import 'package:tech_sos/features/client/screens/publish_repair_screen.dart';
import 'package:tech_sos/features/client/screens/request_detail_screen.dart';

/// Fake API client pour éviter les requêtes réseau réelles et les timeouts en tests
class FakeApiClient extends ApiClient {
  FakeApiClient({required super.cache});

  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    dynamic responseData;
    if (path == ApiEndpoints.categories) {
      responseData = [
        {
          'id': 'cat_phones',
          'name': 'Smartphones & Téléphones',
          'code': 'SMARTPHONE',
          'icon': 'phone_android',
          'issueTypes': [
            {'id': 'iss_screen', 'name': 'Écran cassé', 'isOfficial': true},
            {'id': 'iss_battery', 'name': 'Batterie défaillante', 'isOfficial': true},
          ],
        },
        {
          'id': 'cat_computers',
          'name': 'Ordinateurs & PC',
          'code': 'COMPUTER',
          'icon': 'laptop_mac',
          'issueTypes': [
            {'id': 'iss_boot', 'name': 'Ne s\'allume pas', 'isOfficial': true},
          ],
        },
      ];
    } else if (path == ApiEndpoints.providers) {
      responseData = [
        {
          'id': 'prov_1',
          'userId': 'u_p1',
          'workshopName': 'Clinique Mobile Bamako',
          'addressZone': 'Hamdallaye ACI 2000',
          'city': 'Bamako',
          'ratingAvg': 4.9,
          'reviewCount': 42,
          'isVerified': true,
          'specialties': ['cat_phones'],
        }
      ];
    } else if (path == ApiEndpoints.myRepairs) {
      responseData = [];
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
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      statusCode: 200,
      data: {
        'id': 'rep_new',
        'categoryId': 'cat_phones',
        'descriptionText': 'Test description',
        'status': 'PENDING',
        'createdAt': DateTime.now().toIso8601String(),
      } as T?,
    );
  }

  @override
  Future<Response<T>> uploadFile<T>(
    String path, {
    required File file,
    String fileFieldName = 'file',
    Map<String, dynamic>? extraData,
  }) async {
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      statusCode: 200,
      data: {'url': '/uploads/test_audio.m4a'} as T?,
    );
  }
}

final _testCategories = [
  const CategoryModel(
    id: 'cat_phones',
    name: 'Smartphones & Téléphones',
    code: 'SMARTPHONE',
    icon: 'phone_android',
    issueTypes: [
      IssueTypeModel(id: 'iss_screen', name: 'Écran cassé', isOfficial: true),
      IssueTypeModel(id: 'iss_battery', name: 'Batterie défaillante', isOfficial: true),
    ],
  ),
  const CategoryModel(
    id: 'cat_computers',
    name: 'Ordinateurs & PC',
    code: 'COMPUTER',
    icon: 'laptop_mac',
    issueTypes: [
      IssueTypeModel(id: 'iss_boot', name: 'Ne s\'allume pas', isOfficial: true),
    ],
  ),
];

final _testProviders = [
  const ProviderCardModel(
    id: 'prov_1',
    userId: 'u_p1',
    workshopName: 'Clinique Mobile Bamako',
    addressZone: 'Hamdallaye ACI 2000',
    city: 'Bamako',
    ratingAvg: 4.9,
    reviewCount: 42,
    isVerified: true,
    specialties: ['cat_phones'],
  ),
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final fakeClient = FakeApiClient(cache: CacheManager());

  Widget buildTestableWidget(
    Widget child, {
    List<Override> overrides = const [],
  }) {
    return ProviderScope(
      overrides: [
        apiClientProvider.overrideWithValue(fakeClient),
        categoriesProvider.overrideWith((ref) => _testCategories),
        featuredProvidersProvider.overrideWith((ref) => _testProviders),
        ...overrides,
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: child,
      ),
    );
  }

  group('RepairModel & OfferModel Serialization Tests', () {
    test('OfferModel fromJson and toJson serialization', () {
      final json = {
        'id': 'off_123',
        'repairRequestId': 'rep_456',
        'providerId': 'prov_789',
        'priceCfa': 15000,
        'estimatedDuration': '2 heures',
        'comment': 'Écran original disponible en stock',
        'status': 'PENDING',
        'createdAt': '2026-09-28T14:30:00.000Z',
        'provider': {
          'workshopName': 'Clinique Mobile ACI 2000',
          'ratingAvg': 4.8,
          'reviewCount': 34,
          'user': {
            'phone': '+22370123456',
          },
        },
      };

      final offer = OfferModel.fromJson(json);

      expect(offer.id, 'off_123');
      expect(offer.repairRequestId, 'rep_456');
      expect(offer.workshopName, 'Clinique Mobile ACI 2000');
      expect(offer.providerRating, 4.8);
      expect(offer.providerReviewCount, 34);
      expect(offer.providerPhone, '+22370123456');
      expect(offer.priceCfa, 15000);
      expect(offer.estimatedDuration, '2 heures');
      expect(offer.isPending, isTrue);
      expect(offer.isAccepted, isFalse);

      final encoded = offer.toJson();
      expect(encoded['id'], 'off_123');
      expect(encoded['priceCfa'], 15000);
      expect(encoded['workshopName'], 'Clinique Mobile ACI 2000');
    });

    test('RepairModel fromJson, toJson and helper getters', () {
      final json = {
        'id': 'rep_1',
        'categoryId': 'cat_phones',
        'categoryName': 'Smartphones',
        'issueTypeId': 'iss_screen',
        'issueTypeName': 'Écran fissuré',
        'descriptionText': 'L\'écran est complètement noir après une chute.',
        'voiceAudioUrl': '/uploads/voice_1.m4a',
        'photoUrls': ['/uploads/pic1.jpg'],
        'status': 'OFFERS_RECEIVED',
        'locationAddress': 'Hamdallaye ACI 2000, Bamako',
        'createdAt': '2026-09-28T12:00:00.000Z',
        'offersCount': 2,
        'offers': [
          {
            'id': 'off_1',
            'repairRequestId': 'rep_1',
            'providerId': 'p_1',
            'workshopName': 'Atelier Express',
            'priceCfa': 12000,
            'estimatedDuration': '1h',
            'status': 'PENDING',
            'createdAt': '2026-09-28T12:30:00.000Z',
          }
        ],
      };

      final repair = RepairModel.fromJson(json);

      expect(repair.id, 'rep_1');
      expect(repair.displayTitle, 'Écran fissuré');
      expect(repair.displayIssue, 'Écran fissuré');
      expect(repair.categoryName, 'Smartphones');
      expect(repair.hasOffers, isTrue);
      expect(repair.isPending, isFalse);
      expect(repair.offersCount, 2);
      expect(repair.offers?.length, 1);
      expect(repair.offers?.first.workshopName, 'Atelier Express');
      expect(repair.voiceAudioUrl, '/uploads/voice_1.m4a');

      final serialized = repair.toJson();
      expect(serialized['id'], 'rep_1');
      expect(serialized['categoryId'], 'cat_phones');
      expect(serialized['offersCount'], 2);
    });
  });

  group('AudioRecorderWidget UI & Lifecycle Tests', () {
    testWidgets('AudioRecorderWidget starts in idle state and transitions to recording then recorded',
        (WidgetTester tester) async {
      String? recordedPath;
      bool removedCalled = false;

      await tester.pumpWidget(
        buildTestableWidget(
          AudioRecorderWidget(
            onAudioRecorded: (path) => recordedPath = path,
            onAudioRemoved: () => removedCalled = true,
          ),
        ),
      );

      // État initial (idle)
      expect(find.text('Message vocal (Recommandé)'), findsOneWidget);
      expect(find.text('Touchez pour enregistrer'), findsOneWidget);
      expect(find.byKey(const ValueKey('audio_record_button')), findsOneWidget);

      // Démarrage de l'enregistrement
      await tester.tap(find.byKey(const ValueKey('audio_record_button')));
      await tester.pump();

      expect(find.text('Enregistrement vocal en cours...'), findsOneWidget);
      expect(find.byKey(const ValueKey('audio_stop_button')), findsOneWidget);
      expect(find.byKey(const ValueKey('audio_timer_text')), findsOneWidget);

      // Arrêt de l'enregistrement
      await tester.tap(find.byKey(const ValueKey('audio_stop_button')));
      await tester.pump();

      // État enregistré (recorded)
      expect(find.text('Note vocale prête'), findsOneWidget);
      expect(find.text('Stockage local OK'), findsOneWidget);
      expect(find.byKey(const ValueKey('audio_play_button')), findsOneWidget);
      expect(find.byKey(const ValueKey('audio_delete_button')), findsOneWidget);
      expect(recordedPath, isNotNull);
      expect(recordedPath, contains('/local/recordings/techsos_audio_'));

      // Suppression de l'enregistrement
      await tester.tap(find.byKey(const ValueKey('audio_delete_button')));
      await tester.pump();

      expect(removedCalled, isTrue);
      expect(find.text('Touchez pour enregistrer'), findsOneWidget);
    });

    testWidgets('AudioPlayerCard renders properly with audio controls',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const AudioPlayerCard(
            audioUrl: 'https://api.techsos.ml/uploads/audio_sample.m4a',
            title: 'Note vocale de test',
          ),
        ),
      );

      expect(find.text('Note vocale de test'), findsOneWidget);
      expect(find.byIcon(Icons.play_circle_fill), findsOneWidget);
    });
  });

  group('Client Screens Widget Tests', () {
    testWidgets('ClientHomeScreen renders emergency banner, specialties and recommended providers',
        (WidgetTester tester) async {
      bool publishTapped = false;

      await tester.pumpWidget(
        buildTestableWidget(
          ClientHomeScreen(
            onPublishSosPressed: () => publishTapped = true,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // En-tête & branding
      expect(find.text('TechSOS Bamako'), findsOneWidget);

      // Bannière d'urgence
      expect(find.text('Un appareil en panne ? Lancer un SOS en 1 minute !'), findsOneWidget);
      expect(find.text('URGENCE PANNE'), findsOneWidget);
      expect(find.byKey(const ValueKey('hero_publish_sos_button')), findsOneWidget);

      // Spécialités
      expect(find.text('Smartphones'), findsOneWidget);
      expect(find.text('Ordinateurs'), findsOneWidget);
      expect(find.text('Imprimantes'), findsOneWidget);

      // Section réparateurs recommandés
      expect(find.text('Réparateurs recommandés à Bamako'), findsOneWidget);
      expect(find.text('Clinique Mobile Bamako'), findsOneWidget);

      // Clic sur CTA d'urgence
      await tester.tap(find.byKey(const ValueKey('hero_publish_sos_button')));
      expect(publishTapped, isTrue);
    });

    testWidgets('PublishRepairScreen renders categories, mixed description zone and submit button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const PublishRepairScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Publier un SOS Dépannage'), findsOneWidget);
      expect(find.text('1. Sélectionnez votre appareil *'), findsOneWidget);
      expect(find.text('3. Décrivez la panne (Texte ou Voix) *'), findsOneWidget);
      expect(find.text('OU ENREGISTREMENT VOCAL'), findsOneWidget);
      expect(find.byKey(const ValueKey('publish_audio_recorder')), findsOneWidget);
      expect(find.text('4. Localisation à Bamako'), findsOneWidget);
      expect(find.byKey(const ValueKey('submit_sos_button')), findsOneWidget);

      // Sélection d'une catégorie
      final phoneTile = find.byKey(const ValueKey('category_tile_cat_phones'));
      expect(phoneTile, findsOneWidget);
      await tester.tap(phoneTile);
      await tester.pumpAndSettle();

      // Vérification de l'apparition des types de pannes
      expect(find.text('2. Type de problème / Panne'), findsOneWidget);
      expect(find.text('Autre panne...'), findsOneWidget);
    });

    testWidgets('MyRequestsScreen renders requests list with status badges and offers count',
        (WidgetTester tester) async {
      final sampleRepair = RepairModel(
        id: 'rep_test_1',
        categoryId: 'cat_phones',
        categoryName: 'Smartphones',
        issueTypeName: 'Batterie gonflée',
        descriptionText: 'La batterie chauffe et s\'éteint à 40%.',
        voiceAudioUrl: '/local/sample.m4a',
        status: 'OFFERS_RECEIVED',
        locationAddress: 'Badalabougou, Bamako',
        createdAt: DateTime.now(),
        offersCount: 3,
      );

      await tester.pumpWidget(
        buildTestableWidget(
          const MyRequestsScreen(),
          overrides: [
            clientRepairsProvider.overrideWith(
              (ref) => _MockClientRepairsNotifier([sampleRepair]),
            ),
          ],
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Mes Annonces SOS'), findsOneWidget);
      expect(find.text('Batterie gonflée'), findsOneWidget);
      expect(find.text('Offres reçues'), findsOneWidget);
      expect(find.text('3 offres reçues'), findsOneWidget);
      expect(find.text('Note vocale attachée'), findsOneWidget);
    });

    testWidgets('RequestDetailScreen displays breakdown info and allows offer comparison & acceptance',
        (WidgetTester tester) async {
      final sampleOffer = OfferModel(
        id: 'off_99',
        repairRequestId: 'rep_sample',
        providerId: 'prov_1',
        workshopName: 'Atelier Clinique Mobile',
        providerRating: 4.8,
        providerReviewCount: 15,
        priceCfa: 15000,
        estimatedDuration: '2 heures',
        comment: 'Pièce neuve d\'origine avec 3 mois de garantie',
        status: 'PENDING',
        createdAt: DateTime.now(),
      );

      final sampleRepair = RepairModel(
        id: 'rep_sample',
        categoryId: 'cat_phones',
        categoryName: 'Smartphones',
        issueTypeName: 'Écran tactile fissuré',
        descriptionText: 'Chute sur le goudron à l\'ACI 2000.',
        voiceAudioUrl: '/sample_audio.m4a',
        status: 'OFFERS_RECEIVED',
        locationAddress: 'Hamdallaye ACI 2000, Bamako',
        createdAt: DateTime.now(),
        offersCount: 1,
        offers: [sampleOffer],
      );

      await tester.pumpWidget(
        buildTestableWidget(
          RequestDetailScreen(repair: sampleRepair),
          overrides: [
            clientRepairsProvider.overrideWith(
              (ref) => _MockClientRepairsNotifier([sampleRepair]),
            ),
          ],
        ),
      );

      await tester.pumpAndSettle();

      // En-tête
      expect(find.text('Écran tactile fissuré'), findsWidgets);
      expect(find.text('Hamdallaye ACI 2000, Bamako'), findsOneWidget);

      // Description & lecteur audio
      expect(find.text('Chute sur le goudron à l\'ACI 2000.'), findsOneWidget);
      expect(find.text('Note vocale du client attachée'), findsOneWidget);

      // Section des offres
      expect(find.text('Offres des réparateurs (1)'), findsOneWidget);
      expect(find.text('Atelier Clinique Mobile'), findsOneWidget);
      expect(find.text('15 000 FCFA'), findsOneWidget);
      expect(find.text('2 heures'), findsOneWidget);
      expect(find.byKey(const ValueKey('accept_offer_off_99')), findsOneWidget);
    });

    testWidgets('LeaveReviewDialog renders 1-5 stars and comment input',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const LeaveReviewDialog(
            repairId: 'rep_completed',
            workshopName: 'Atelier Clinique Mobile',
          ),
          overrides: [
            clientRepairsProvider.overrideWith(
              (ref) => _MockClientRepairsNotifier([]),
            ),
          ],
        ),
      );

      expect(find.text('Évaluer la réparation'), findsOneWidget);
      expect(find.text('Comment s\'est passé le dépannage avec Atelier Clinique Mobile ?'), findsOneWidget);
      expect(find.byKey(const ValueKey('dialog_interactive_stars')), findsOneWidget);
      expect(find.text('Excellent travail !'), findsOneWidget);
      expect(find.byKey(const ValueKey('review_comment_input')), findsOneWidget);
      expect(find.byKey(const ValueKey('submit_review_button')), findsOneWidget);
    });

    testWidgets('ClientMainScreen renders bottom navigation and navigates between tabs',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const ClientMainScreen(),
          overrides: [
            clientRepairsProvider.overrideWith(
              (ref) => _MockClientRepairsNotifier([]),
            ),
          ],
        ),
      );

      await tester.pumpAndSettle();

      // Vérification des onglets
      expect(find.text('Accueil'), findsOneWidget);
      expect(find.text('Publier SOS'), findsOneWidget);
      expect(find.text('Mes Annonces'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);

      // Bascule vers l'onglet Publier SOS
      await tester.tap(find.text('Publier SOS'));
      await tester.pumpAndSettle();

      expect(find.text('Publier un SOS Dépannage'), findsOneWidget);

      // Bascule vers l'onglet Profil
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();

      expect(find.text('Mon Profil Client'), findsOneWidget);
    });

    testWidgets('TechSosApp navigates to ClientMainScreen when authenticated user is client',
        (WidgetTester tester) async {
      const authenticatedClient = UserModel(
        id: 'client_1',
        fullName: 'Fousseyni Traoré',
        phone: '+22370001122',
        role: 'CLIENT',
        city: 'Bamako',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiClientProvider.overrideWithValue(fakeClient),
            categoriesProvider.overrideWith((ref) => _testCategories),
            featuredProvidersProvider.overrideWith((ref) => _testProviders),
            authProvider.overrideWith(
              (ref) => _MockAuthNotifier(
                const AuthState(
                  isAuthenticated: true,
                  user: authenticatedClient,
                ),
              ),
            ),
            clientRepairsProvider.overrideWith(
              (ref) => _MockClientRepairsNotifier([]),
            ),
          ],
          child: const TechSosApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Doit afficher l'écran principal client (avec ses onglets)
      expect(find.byType(ClientMainScreen), findsOneWidget);
      expect(find.text('Bonjour, Fousseyni Traoré 👋'), findsOneWidget);
    });
  });
}

/// Mock explicite et complet de ClientRepairsNotifier pour les tests UI
class _MockClientRepairsNotifier extends StateNotifier<ClientRepairsState>
    implements ClientRepairsNotifier {
  _MockClientRepairsNotifier(List<RepairModel> repairs)
      : super(ClientRepairsState(repairs: repairs));

  @override
  ApiClient get apiClient => throw UnimplementedError();

  @override
  CacheManager get cacheManager => throw UnimplementedError();

  @override
  Future<void> loadMyRequests({bool refresh = false}) async {}

  @override
  Future<RepairModel?> getRepairDetail(String repairId) async {
    return state.repairs.where((r) => r.id == repairId).firstOrNull;
  }

  @override
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
    final created = RepairModel(
      id: 'rep_mock_created',
      categoryId: categoryId,
      categoryName: categoryName,
      issueTypeId: issueTypeId,
      issueTypeName: issueTypeName,
      customIssueTitle: customIssueTitle,
      descriptionText: descriptionText,
      voiceAudioUrl: voiceAudioPath,
      status: 'PENDING',
      createdAt: DateTime.now(),
    );
    state = state.copyWith(repairs: [created, ...state.repairs]);
    return created;
  }

  @override
  Future<bool> acceptOffer({required String repairId, required String offerId}) async {
    return true;
  }

  @override
  Future<bool> submitReview({required String repairId, required int rating, String? comment}) async {
    return true;
  }

  @override
  void clearMessages() {}
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
  }) async => true;

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
  }) async => true;
}

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tech_sos/core/network/api_client.dart';
import 'package:tech_sos/core/network/api_endpoints.dart';
import 'package:tech_sos/core/network/api_exception.dart';
import 'package:tech_sos/core/offline/cache_manager.dart';
import 'package:tech_sos/features/auth/models/user_model.dart';
import 'package:tech_sos/features/auth/providers/auth_provider.dart';

class FakeApiClient extends ApiClient {
  FakeApiClient({required super.cache});

  Map<String, dynamic>? nextPostResponse;
  Map<String, dynamic>? nextGetResponse;
  ApiException? errorToThrow;
  String? lastPath;
  dynamic lastData;

  @override
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    lastPath = path;
    lastData = data;
    if (errorToThrow != null) {
      throw errorToThrow!;
    }
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      statusCode: 200,
      data: nextPostResponse as T?,
    );
  }

  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    lastPath = path;
    if (errorToThrow != null) {
      throw errorToThrow!;
    }
    return Response<T>(
      requestOptions: RequestOptions(path: path),
      statusCode: 200,
      data: nextGetResponse as T?,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UserModel Serialization Tests', () {
    test('fromJson & toJson with Client payload (flat)', () {
      final clientJson = {
        'id': 'client-uuid-1',
        'phone': '+22370000001',
        'fullName': 'Moussa Traoré',
        'role': 'CLIENT',
        'email': 'moussa@techsos.ml',
        'city': 'Bamako',
      };

      final user = UserModel.fromJson(clientJson);

      expect(user.id, 'client-uuid-1');
      expect(user.phone, '+22370000001');
      expect(user.fullName, 'Moussa Traoré');
      expect(user.role, 'CLIENT');
      expect(user.isClient, isTrue);
      expect(user.isProvider, isFalse);
      expect(user.city, 'Bamako');

      final serialized = user.toJson();
      expect(serialized['id'], 'client-uuid-1');
      expect(serialized['phone'], '+22370000001');
      expect(serialized['role'], 'CLIENT');
    });

    test('fromJson & toJson with Provider payload (nested providerProfile)', () {
      final providerJson = {
        'id': 'prov-uuid-2',
        'phone': '+22370000002',
        'fullName': 'Oumar Cissé',
        'role': 'PROVIDER',
        'email': 'oumar@techsos.ml',
        'city': 'Bamako',
        'providerProfile': {
          'workshopName': 'Cissé Électronique',
          'addressZone': 'Hamdallaye ACI 2000',
          'bio': 'Spécialiste cartes mères et écrans AMOLED',
          'isVerified': true,
          'ratingAvg': 4.9,
          'reviewCount': 28,
          'subscriptionStatus': 'ACTIVE',
        },
      };

      final user = UserModel.fromJson(providerJson);

      expect(user.id, 'prov-uuid-2');
      expect(user.isProvider, isTrue);
      expect(user.isClient, isFalse);
      expect(user.workshopName, 'Cissé Électronique');
      expect(user.addressZone, 'Hamdallaye ACI 2000');
      expect(user.bio, contains('cartes mères'));
      expect(user.isVerified, isTrue);
      expect(user.ratingAvg, 4.9);
      expect(user.reviewCount, 28);
      expect(user.subscriptionStatus, 'ACTIVE');

      final serialized = user.toJson();
      expect(serialized['workshopName'], 'Cissé Électronique');
      expect(serialized['addressZone'], 'Hamdallaye ACI 2000');
      expect(serialized['ratingAvg'], 4.9);
    });
  });

  group('ApiException French Error Mapping Tests', () {
    test('maps 401 Unauthorized to French message', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/auth/login'),
        response: Response(
          requestOptions: RequestOptions(path: '/auth/login'),
          statusCode: 401,
        ),
        type: DioExceptionType.badResponse,
      );

      final apiException = ApiException.fromDioException(dioException);
      expect(apiException.message, 'Identifiants invalides ou session expirée.');
      expect(apiException.statusCode, 401);
    });

    test('maps 403 Forbidden to French message', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/users/secret'),
        response: Response(
          requestOptions: RequestOptions(path: '/users/secret'),
          statusCode: 403,
        ),
        type: DioExceptionType.badResponse,
      );

      final apiException = ApiException.fromDioException(dioException);
      expect(apiException.message, 'Action non autorisée.');
    });

    test('maps 404 Not Found to French message', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/repairs/not-found'),
        response: Response(
          requestOptions: RequestOptions(path: '/repairs/not-found'),
          statusCode: 404,
        ),
        type: DioExceptionType.badResponse,
      );

      final apiException = ApiException.fromDioException(dioException);
      expect(apiException.message, 'Ressource introuvable.');
    });

    test('maps 409 Conflict to custom backend or default French message', () {
      final dioExceptionWithMsg = DioException(
        requestOptions: RequestOptions(path: '/auth/register-client'),
        response: Response(
          requestOptions: RequestOptions(path: '/auth/register-client'),
          statusCode: 409,
          data: {'message': 'Ce numéro de téléphone est déjà utilisé'},
        ),
        type: DioExceptionType.badResponse,
      );

      final apiException = ApiException.fromDioException(dioExceptionWithMsg);
      expect(apiException.message, 'Ce numéro de téléphone est déjà utilisé');

      final dioExceptionDefault = DioException(
        requestOptions: RequestOptions(path: '/auth/register-client'),
        response: Response(
          requestOptions: RequestOptions(path: '/auth/register-client'),
          statusCode: 409,
        ),
        type: DioExceptionType.badResponse,
      );

      final apiExceptionDefault = ApiException.fromDioException(dioExceptionDefault);
      expect(apiExceptionDefault.message, 'Cet élément existe déjà.');
    });

    test('maps 500 Server Error to French message', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/api'),
        response: Response(
          requestOptions: RequestOptions(path: '/api'),
          statusCode: 500,
        ),
        type: DioExceptionType.badResponse,
      );

      final apiException = ApiException.fromDioException(dioException);
      expect(apiException.message, 'Erreur serveur. Veuillez réessayer plus tard.');
    });

    test('maps connection timeout and connection error to French message', () {
      final dioExceptionTimeout = DioException(
        requestOptions: RequestOptions(path: '/api'),
        type: DioExceptionType.connectionTimeout,
      );
      expect(
        ApiException.fromDioException(dioExceptionTimeout).message,
        'Connexion impossible. Vérifiez votre accès internet.',
      );

      final dioExceptionError = DioException(
        requestOptions: RequestOptions(path: '/api'),
        type: DioExceptionType.connectionError,
      );
      expect(
        ApiException.fromDioException(dioExceptionError).message,
        'Connexion impossible. Vérifiez votre accès internet.',
      );
    });
  });

  group('CacheManager Tests', () {
    late CacheManager cacheManager;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      cacheManager = CacheManager();
    });

    test('saves and retrieves token', () async {
      expect(await cacheManager.getToken(), isNull);
      await cacheManager.saveToken('jwt-token-xyz');
      expect(await cacheManager.getToken(), 'jwt-token-xyz');
    });

    test('saves, retrieves and clears user and categories', () async {
      final userMap = {
        'id': 'usr-1',
        'phone': '+22370000000',
        'fullName': 'Test User',
        'role': 'CLIENT',
      };

      await cacheManager.saveUser(userMap);
      final retrievedUser = await cacheManager.getUser();
      expect(retrievedUser?['fullName'], 'Test User');

      final categories = [
        {'id': 'cat-1', 'name': 'Téléphones'},
        {'id': 'cat-2', 'name': 'Ordinateurs'},
      ];
      await cacheManager.saveCategories(categories);
      final retrievedCategories = await cacheManager.getCategories();
      expect(retrievedCategories?.length, 2);
      expect(retrievedCategories?[0]['name'], 'Téléphones');

      await cacheManager.clear();
      expect(await cacheManager.getToken(), isNull);
      expect(await cacheManager.getUser(), isNull);
      expect(await cacheManager.getCategories(), isNull);
    });
  });

  group('AuthNotifier State & Flow Tests', () {
    late CacheManager cacheManager;
    late FakeApiClient fakeApiClient;
    late AuthNotifier authNotifier;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      cacheManager = CacheManager();
      fakeApiClient = FakeApiClient(cache: cacheManager);
      authNotifier = AuthNotifier(
        apiClient: fakeApiClient,
        cacheManager: cacheManager,
      );
    });

    test('initial state is unauthenticated and not loading', () {
      expect(authNotifier.state.isLoading, isFalse);
      expect(authNotifier.state.isAuthenticated, isFalse);
      expect(authNotifier.state.user, isNull);
      expect(authNotifier.state.errorMessage, isNull);
    });

    test('login success updates state and persists token & user', () async {
      fakeApiClient.nextPostResponse = {
        'access_token': 'test-token-123',
        'user': {
          'id': 'user-100',
          'phone': '+22371234567',
          'fullName': 'Awa Diallo',
          'role': 'CLIENT',
          'city': 'Bamako',
        },
      };

      final result = await authNotifier.login('+22371234567', 'password123');

      expect(result, isTrue);
      expect(fakeApiClient.lastPath, ApiEndpoints.login);
      expect(fakeApiClient.lastData['identifier'], '+22371234567');

      expect(authNotifier.state.isLoading, isFalse);
      expect(authNotifier.state.isAuthenticated, isTrue);
      expect(authNotifier.state.user?.fullName, 'Awa Diallo');
      expect(authNotifier.state.errorMessage, isNull);

      expect(await cacheManager.getToken(), 'test-token-123');
      final cachedUser = await cacheManager.getUser();
      expect(cachedUser?['fullName'], 'Awa Diallo');
    });

    test('login failure updates state with error message and keeps unauthenticated', () async {
      fakeApiClient.errorToThrow = const ApiException(
        message: 'Identifiants invalides ou session expirée.',
        statusCode: 401,
      );

      final result = await authNotifier.login('+22370000000', 'wrongpassword');

      expect(result, isFalse);
      expect(authNotifier.state.isLoading, isFalse);
      expect(authNotifier.state.isAuthenticated, isFalse);
      expect(authNotifier.state.user, isNull);
      expect(authNotifier.state.errorMessage, 'Identifiants invalides ou session expirée.');
      expect(await cacheManager.getToken(), isNull);
    });

    test('registerClient success updates state with client profile', () async {
      fakeApiClient.nextPostResponse = {
        'access_token': 'token-client-abc',
        'user': {
          'id': 'client-200',
          'phone': '+22376543210',
          'fullName': 'Bakary Sanogo',
          'role': 'CLIENT',
          'city': 'Bamako',
        },
      };

      final result = await authNotifier.registerClient(
        fullName: 'Bakary Sanogo',
        phone: '+223 76 54 32 10',
        password: 'securePassword123',
        address: 'Badalabougou',
      );

      expect(result, isTrue);
      expect(fakeApiClient.lastPath, ApiEndpoints.registerClient);
      expect(authNotifier.state.isAuthenticated, isTrue);
      expect(authNotifier.state.user?.isClient, isTrue);
      expect(await cacheManager.getToken(), 'token-client-abc');
    });

    test('registerProvider success updates state with provider workshop details', () async {
      fakeApiClient.nextPostResponse = {
        'access_token': 'token-provider-xyz',
        'user': {
          'id': 'prov-300',
          'phone': '+22378998877',
          'fullName': 'Modibo Keita',
          'role': 'PROVIDER',
          'city': 'Bamako',
          'providerProfile': {
            'workshopName': 'Keita Dépannage Pro',
            'addressZone': 'Lafiabougou',
            'isVerified': false,
            'ratingAvg': 5.0,
            'reviewCount': 0,
            'subscriptionStatus': 'FREE_TRIAL',
          },
        },
      };

      final result = await authNotifier.registerProvider(
        fullName: 'Modibo Keita',
        phone: '+223 78 99 88 77',
        password: 'providerSecretPass',
        workshopName: 'Keita Dépannage Pro',
        addressZone: 'Lafiabougou',
      );

      expect(result, isTrue);
      expect(fakeApiClient.lastPath, ApiEndpoints.registerProvider);
      expect(authNotifier.state.isAuthenticated, isTrue);
      expect(authNotifier.state.user?.isProvider, isTrue);
      expect(authNotifier.state.user?.workshopName, 'Keita Dépannage Pro');
      expect(authNotifier.state.user?.addressZone, 'Lafiabougou');
      expect(await cacheManager.getToken(), 'token-provider-xyz');
    });

    test('init restores session when token exists and /users/me succeeds', () async {
      await cacheManager.saveToken('existing-token');
      fakeApiClient.nextGetResponse = {
        'id': 'user-restored',
        'phone': '+22370112233',
        'fullName': 'Saliou Diop',
        'role': 'CLIENT',
        'city': 'Bamako',
      };

      await authNotifier.init();

      expect(authNotifier.state.isAuthenticated, isTrue);
      expect(authNotifier.state.user?.fullName, 'Saliou Diop');
    });

    test('logout clears storage and resets state to unauthenticated', () async {
      fakeApiClient.nextPostResponse = {
        'access_token': 'token-to-clear',
        'user': {
          'id': 'user-temp',
          'phone': '+22370000000',
          'fullName': 'Temp User',
          'role': 'CLIENT',
        },
      };

      await authNotifier.login('+22370000000', 'password');
      expect(authNotifier.state.isAuthenticated, isTrue);

      await authNotifier.logout();

      expect(authNotifier.state.isAuthenticated, isFalse);
      expect(authNotifier.state.user, isNull);
      expect(await cacheManager.getToken(), isNull);
      expect(await cacheManager.getUser(), isNull);
    });
  });
}

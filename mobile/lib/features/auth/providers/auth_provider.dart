import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/offline/cache_manager.dart';
import '../models/user_model.dart';

/// État immuable de l'authentification
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final UserModel? user;
  final String? errorMessage;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.errorMessage,
  });

  factory AuthState.initial() => const AuthState();

  factory AuthState.unauthenticated() => const AuthState(
        isLoading: false,
        isAuthenticated: false,
        user: null,
        errorMessage: null,
      );

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    UserModel? user,
    String? errorMessage,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

/// Gestionnaire d'état de l'authentification TechSOS
class AuthNotifier extends StateNotifier<AuthState> {
  final ApiClient apiClient;
  final CacheManager cacheManager;

  AuthNotifier({
    required this.apiClient,
    required this.cacheManager,
  }) : super(AuthState.initial());

  /// Initialise la session : vérifie le cache local puis synchronise avec /users/me
  Future<void> init() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final token = await cacheManager.getToken();
      if (token == null || token.isEmpty) {
        state = AuthState.unauthenticated();
        return;
      }

      final cachedUserMap = await cacheManager.getUser();
      UserModel? cachedUser;
      if (cachedUserMap != null) {
        cachedUser = UserModel.fromJson(cachedUserMap);
      }

      try {
        final response = await apiClient.get(ApiEndpoints.me);
        final user = UserModel.fromJson(response.data as Map<String, dynamic>);
        await cacheManager.saveUser(user.toJson());

        state = AuthState(
          isLoading: false,
          isAuthenticated: true,
          user: user,
          errorMessage: null,
        );
      } catch (_) {
        // En cas de coupure réseau, on conserve l'utilisateur en cache pour le mode hors-ligne
        if (cachedUser != null) {
          state = AuthState(
            isLoading: false,
            isAuthenticated: true,
            user: cachedUser,
            errorMessage: null,
          );
        } else {
          await cacheManager.clear();
          state = AuthState.unauthenticated();
        }
      }
    } catch (_) {
      state = AuthState.unauthenticated();
    }
  }

  /// Connexion par téléphone ou email avec mot de passe
  Future<bool> login(String identifier, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await apiClient.post(
        ApiEndpoints.login,
        data: {
          'identifier': identifier.trim(),
          'password': password,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final token = data['access_token'] as String;
      final userData = data['user'] as Map<String, dynamic>;
      final user = UserModel.fromJson(userData);

      await cacheManager.saveToken(token);
      await cacheManager.saveUser(user.toJson());

      state = AuthState(
        isLoading: false,
        isAuthenticated: true,
        user: user,
        errorMessage: null,
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Une erreur inattendue est survenue.',
      );
      return false;
    }
  }

  /// Inscription d'un utilisateur Client
  Future<bool> registerClient({
    required String fullName,
    required String phone,
    required String password,
    String? email,
    String? city,
    String? address,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await apiClient.post(
        ApiEndpoints.registerClient,
        data: {
          'fullName': fullName.trim(),
          'phone': phone.trim(),
          'password': password,
          if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
          'city': city?.trim().isNotEmpty == true ? city!.trim() : 'Bamako',
          if (address != null && address.trim().isNotEmpty) 'address': address.trim(),
        },
      );

      final data = response.data as Map<String, dynamic>;
      final token = data['access_token'] as String;
      final userData = data['user'] as Map<String, dynamic>;
      final user = UserModel.fromJson(userData);

      await cacheManager.saveToken(token);
      await cacheManager.saveUser(user.toJson());

      state = AuthState(
        isLoading: false,
        isAuthenticated: true,
        user: user,
        errorMessage: null,
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Une erreur inattendue est survenue lors de l\'inscription.',
      );
      return false;
    }
  }

  /// Inscription d'un Prestataire / Atelier de réparation
  Future<bool> registerProvider({
    required String fullName,
    required String phone,
    required String password,
    required String workshopName,
    required String addressZone,
    String? email,
    String? bio,
    List<String>? specialties,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await apiClient.post(
        ApiEndpoints.registerProvider,
        data: {
          'fullName': fullName.trim(),
          'phone': phone.trim(),
          'password': password,
          'workshopName': workshopName.trim(),
          'addressZone': addressZone.trim(),
          if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
          if (bio != null && bio.trim().isNotEmpty) 'bio': bio.trim(),
          if (specialties != null && specialties.isNotEmpty) 'specialties': specialties,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final token = data['access_token'] as String;
      final userData = data['user'] as Map<String, dynamic>;
      final user = UserModel.fromJson(userData);

      await cacheManager.saveToken(token);
      await cacheManager.saveUser(user.toJson());

      state = AuthState(
        isLoading: false,
        isAuthenticated: true,
        user: user,
        errorMessage: null,
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Une erreur inattendue est survenue lors de l\'inscription de l\'atelier.',
      );
      return false;
    }
  }

  /// Déconnexion complète
  Future<void> logout() async {
    await cacheManager.clear();
    state = AuthState.unauthenticated();
  }

  /// Réinitialise les erreurs affichées
  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }
}

/// Provider pour le gestionnaire de cache
final cacheManagerProvider = Provider<CacheManager>((ref) {
  return CacheManager();
});

/// Provider pour le client HTTP Dio
final apiClientProvider = Provider<ApiClient>((ref) {
  final cacheManager = ref.watch(cacheManagerProvider);
  return ApiClient(cache: cacheManager);
});

/// Provider global pour l'état d'authentification
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final cacheManager = ref.watch(cacheManagerProvider);
  return AuthNotifier(apiClient: apiClient, cacheManager: cacheManager);
});

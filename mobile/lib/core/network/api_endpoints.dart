/// Endpoints de l'API REST TechSOS
class ApiEndpoints {
  ApiEndpoints._();

  /// URL de base de l'API avec fallback vers l'émulateur Android (10.0.2.2) ou localhost
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/api',
  );

  // Authentification
  static const String login = '/auth/login';
  static const String registerClient = '/auth/register-client';
  static const String registerProvider = '/auth/register-provider';

  // Utilisateurs & Profils
  static const String me = '/users/me';
  static const String providers = '/users/providers';

  // Catégories de pannes
  static const String categories = '/categories';

  // Demandes de réparation & SOS
  static const String repairs = '/repairs';
  static const String myRepairs = '/repairs/my-requests';
  static const String providerFeed = '/repairs/feed';
  static String repairDetail(String id) => '/repairs/$id';
  static String repairOffers(String repairId) => '/repairs/$repairId/offers';
  static String acceptOffer(String offerId) => '/offers/$offerId/accept';
  static String repairReviews(String repairId) => '/repairs/$repairId/reviews';

  // Gestion Atelier, Abonnements & Médias
  static const String workshop = '/workshop';
  static const String subscriptions = '/subscriptions';
  static const String storageUpload = '/storage/upload';
}

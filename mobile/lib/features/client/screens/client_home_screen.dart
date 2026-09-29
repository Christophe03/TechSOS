import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/styles.dart';
import '../../../core/widgets/star_rating.dart';
import '../../../core/widgets/techsos_button.dart';
import '../../../core/widgets/techsos_logo.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/provider_card_model.dart';
import '../providers/client_repairs_provider.dart';

/// Écran d'accueil Client avec Bannière SOS d'urgence, filtres et réparateurs recommandés à Bamako
class ClientHomeScreen extends ConsumerStatefulWidget {
  final VoidCallback? onPublishSosPressed;

  const ClientHomeScreen({
    super.key,
    this.onPublishSosPressed,
  });

  @override
  ConsumerState<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends ConsumerState<ClientHomeScreen> {
  String _selectedCategory = 'Tous';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _specialties = [
    'Tous',
    'Smartphones',
    'Ordinateurs',
    'Imprimantes',
    'Tablettes',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showProviderContactSheet(ProviderCardModel provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: TechSosColors.primary.withValues(alpha: 0.1),
                  child: const Icon(
                    Icons.build_circle_rounded,
                    color: TechSosColors.primary,
                    size: 34,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.workshopName,
                        style: TechSosStyles.headingMedium,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          StarRating(
                            rating: provider.ratingAvg,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${provider.ratingAvg.toStringAsFixed(1)} (${provider.reviewCount} avis)',
                            style: TechSosStyles.caption.copyWith(fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (provider.addressZone != null) ...[
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: TechSosColors.accent, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${provider.addressZone}, ${provider.city}',
                    style: TechSosStyles.body.copyWith(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
            if (provider.bio != null) ...[
              Text(
                provider.bio!,
                style: TechSosStyles.bodySecondary,
              ),
              const SizedBox(height: 16),
            ],
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: TechSosColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: TechSosColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.phone_rounded, color: TechSosColors.success, size: 22),
                  const SizedBox(width: 12),
                  Text(
                    provider.phone ?? '+223 70 00 00 00',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: TechSosColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TechSosButton(
              label: 'Demander un dépannage express',
              icon: Icons.flash_on_rounded,
              onPressed: () {
                Navigator.of(ctx).pop();
                widget.onPublishSosPressed?.call();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final providersAsync = ref.watch(featuredProvidersProvider);
    final myRepairsState = ref.watch(clientRepairsProvider);

    return Scaffold(
      backgroundColor: TechSosColors.background,
      appBar: AppBar(
        title: const Row(
          children: [
            TechSosLogo(size: 32, variant: TechSosLogoVariant.white),
            SizedBox(width: 10),
            Text(
              'TechSOS Bamako',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            tooltip: 'Notifications',
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Déconnexion',
            onPressed: () {
              ref.read(authProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(featuredProvidersProvider);
          await ref.read(clientRepairsProvider.notifier).loadMyRequests(refresh: true);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Salutation client
              Text(
                user != null ? 'Bonjour, ${user.fullName} 👋' : 'Bonjour et bienvenue 👋',
                style: TechSosStyles.headingLarge,
              ),
              const SizedBox(height: 4),
              const Text(
                'Trouvez un réparateur certifié pour votre appareil en panne à Bamako',
                style: TextStyle(
                  fontSize: 14,
                  color: TechSosColors.textSecondary,
                ),
              ),
              const SizedBox(height: 18),

              // Hero Emergency Banner
              _buildHeroBanner(),
              const SizedBox(height: 24),

              // Résumé des demandes en cours (si existantes)
              if (myRepairsState.repairs.isNotEmpty) ...[
                _buildActiveRequestsSummary(myRepairsState),
                const SizedBox(height: 24),
              ],

              // Filtres par Spécialité d'appareil
              const Text(
                'Catégories d\'appareils',
                style: TechSosStyles.headingMedium,
              ),
              const SizedBox(height: 12),
              _buildSpecialtyChips(),
              const SizedBox(height: 24),

              // Section Réparateurs Recommandés à Bamako
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Réparateurs recommandés à Bamako',
                    style: TechSosStyles.headingMedium,
                  ),
                  Text(
                    'Vérifiés',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: TechSosColors.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              providersAsync.when(
                data: (providers) => _buildProvidersList(providers),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (_, __) => const Center(
                  child: Text(
                    'Impossible de charger les réparateurs.',
                    style: TextStyle(fontSize: 14, color: TechSosColors.textSecondary),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// Bannière d'urgence SOS
  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            TechSosColors.primary,
            Color(0xFF284C7A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: TechSosColors.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: TechSosColors.accent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'URGENCE PANNE',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Text(
                'Réponse en ~15 min',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Un appareil en panne ? Lancer un SOS en 1 minute !',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Décrivez le problème par texte ou note vocale. Les ateliers qualifiés de Bamako vous envoient leurs devis.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              key: const ValueKey('hero_publish_sos_button'),
              icon: const Icon(Icons.add_alert_rounded, color: Colors.white),
              label: const Text(
                'Lancer un SOS maintenant',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: TechSosColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
              onPressed: widget.onPublishSosPressed,
            ),
          ),
        ],
      ),
    );
  }

  /// Chips horizontaux des spécialités
  Widget _buildSpecialtyChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _specialties.map((spec) {
          final isSelected = _selectedCategory == spec;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(
                spec,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Colors.white : TechSosColors.textPrimary,
                ),
              ),
              selected: isSelected,
              selectedColor: TechSosColors.primary,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? TechSosColors.primary : TechSosColors.border,
                ),
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedCategory = spec;
                  });
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Résumé des demandes actives du client
  Widget _buildActiveRequestsSummary(ClientRepairsState repairsState) {
    final pendingCount = repairsState.repairs.where((r) => r.isPending || r.hasOffers).length;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TechSosColors.alert.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TechSosColors.alert.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: TechSosColors.alert, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$pendingCount demande(s) en attente ou avec devis',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: TechSosColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Consultez vos annonces pour comparer les offres reçues.',
                  style: TextStyle(
                    fontSize: 14,
                    color: TechSosColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Liste des réparateurs recommandés à Bamako
  Widget _buildProvidersList(List<ProviderCardModel> providers) {
    if (providers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: TechSosColors.border),
        ),
        child: const Center(
          child: Text(
            'Aucun réparateur trouvé dans cette zone.',
            style: TextStyle(fontSize: 14, color: TechSosColors.textSecondary),
          ),
        ),
      );
    }

    return Column(
      children: providers.map((provider) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: TechSosColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: TechSosColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: TechSosColors.primary.withValues(alpha: 0.1),
                    child: const Icon(
                      Icons.storefront_rounded,
                      color: TechSosColors.primary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                provider.workshopName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: TechSosColors.textPrimary,
                                ),
                              ),
                            ),
                            if (provider.isVerified)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: TechSosColors.success.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.verified_rounded,
                                      color: TechSosColors.success,
                                      size: 14,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Certifié',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: TechSosColors.success,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 16,
                              color: TechSosColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              provider.addressZone ?? provider.city,
                              style: const TextStyle(
                                fontSize: 14,
                                color: TechSosColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            StarRating(
                              rating: provider.ratingAvg,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${provider.ratingAvg.toStringAsFixed(1)} (${provider.reviewCount} avis)',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: TechSosColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (provider.bio != null) ...[
                const SizedBox(height: 10),
                Text(
                  provider.bio!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: TechSosColors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _showProviderContactSheet(provider),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: TechSosColors.primary,
                    side: const BorderSide(color: TechSosColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text(
                    'Voir / Contacter',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

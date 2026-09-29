import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/styles.dart';
import '../../../core/widgets/star_rating.dart';
import '../../../core/widgets/techsos_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../../subscription/screens/subscription_screen.dart';
import 'my_offers_screen.dart';
import 'provider_feed_screen.dart';
import 'workshop_journal_screen.dart';

/// Écran principal pour les réparateurs avec barre de navigation inférieure (5 onglets)
class ProviderMainScreen extends ConsumerStatefulWidget {
  final int initialTabIndex;

  const ProviderMainScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  ConsumerState<ProviderMainScreen> createState() => _ProviderMainScreenState();
}

class _ProviderMainScreenState extends ConsumerState<ProviderMainScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
  }

  void _switchTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const ProviderFeedScreen(),
      const MyOffersScreen(),
      const WorkshopJournalScreen(),
      const SubscriptionScreen(),
      _ProviderProfileTab(
        onViewOffers: () => _switchTab(1),
        onViewWorkshop: () => _switchTab(2),
        onViewSubscription: () => _switchTab(3),
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            top: BorderSide(
              color: TechSosColors.border,
              width: 1.0,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _switchTab,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: TechSosColors.accent,
          unselectedItemColor: TechSosColors.textSecondary,
          selectedFontSize: 14,
          unselectedFontSize: 14,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dynamic_feed_rounded),
              activeIcon: Icon(Icons.dynamic_feed_rounded),
              label: 'Fil pannes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_offer_outlined),
              activeIcon: Icon(Icons.local_offer_rounded),
              label: 'Mes Offres',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.handyman_outlined),
              activeIcon: Icon(Icons.handyman_rounded),
              label: 'Atelier',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.verified_outlined),
              activeIcon: Icon(Icons.verified_rounded),
              label: 'Abonnement',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}

/// Onglet Profil et paramètres de l'atelier réparateur
class _ProviderProfileTab extends ConsumerWidget {
  final VoidCallback onViewOffers;
  final VoidCallback onViewWorkshop;
  final VoidCallback onViewSubscription;

  const _ProviderProfileTab({
    required this.onViewOffers,
    required this.onViewWorkshop,
    required this.onViewSubscription,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: TechSosColors.background,
      appBar: AppBar(
        title: const Text('Profil Réparateur'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Carte de présentation de l'atelier
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: TechSosColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: TechSosColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.storefront_rounded,
                      size: 38,
                      color: TechSosColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.workshopName ?? 'Atelier Réparateur',
                    style: TechSosStyles.headingLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${user?.fullName ?? "Réparateur"} • ${user?.phone ?? "+223 ..."}',
                    style: TechSosStyles.bodySecondary,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: TechSosColors.accent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${user?.addressZone ?? "Quartier non renseigné"}, ${user?.city ?? "Bamako"}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: TechSosColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const StarRating(rating: 4.8, size: 20),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E8B57).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'Forfait Standard Pro • Actif',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E8B57),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Raccourcis et gestion
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: TechSosColors.border),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.handyman_rounded, color: TechSosColors.primary),
                      title: const Text(
                        'Gestion du Journal d\'Atelier',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: onViewWorkshop,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.local_offer_rounded, color: TechSosColors.accent),
                      title: const Text(
                        'Mes devis et offres envoyés',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: onViewOffers,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.card_membership_rounded, color: Color(0xFF2E8B57)),
                      title: const Text(
                        'Gérer mon abonnement (5 000 FCFA)',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: onViewSubscription,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Déconnexion
            TechSosButton(
              label: 'Se déconnecter',
              icon: Icons.logout_rounded,
              isSecondary: true,
              onPressed: () {
                ref.read(authProvider.notifier).logout();
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'TechSOS Bamako v1.0.0 (Espace Réparateur)\nGolden Innovation Tech',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: TechSosColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

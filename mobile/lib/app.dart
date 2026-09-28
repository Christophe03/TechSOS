import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/styles.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/star_rating.dart';
import 'core/widgets/status_badge.dart';
import 'core/widgets/techsos_button.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/role_selection_screen.dart';

/// Root application widget for TechSOS
class TechSosApp extends ConsumerWidget {
  const TechSosApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'TechSOS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: authState.isAuthenticated
          ? const TechSosHomeScreen()
          : const RoleSelectionScreen(),
    );
  }
}

/// Initial Home Screen showing design system components
class TechSosHomeScreen extends ConsumerWidget {
  const TechSosHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TechSOS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Se déconnecter',
            onPressed: () {
              ref.read(authProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user != null
                  ? 'Bonjour, ${user.fullName} !'
                  : 'Bienvenue sur TechSOS',
              style: TechSosStyles.headingLarge,
            ),
            const SizedBox(height: 8),
            Text(
              user != null && user.isProvider
                  ? 'Atelier : ${user.workshopName ?? "Non renseigné"} (${user.addressZone ?? user.city})'
                  : 'Dépannage d\'appareils électroniques à Bamako',
              style: TechSosStyles.bodySecondary,
            ),
            const SizedBox(height: 24),
            const Text(
              'Statuts de dépannage',
              style: TechSosStyles.headingMedium,
            ),
            const SizedBox(height: 12),
            const Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                StatusBadge(status: 'PENDING'),
                StatusBadge(status: 'OFFERS_RECEIVED'),
                StatusBadge(status: 'IN_PROGRESS'),
                StatusBadge(status: 'COMPLETED'),
                StatusBadge(status: 'CANCELLED'),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Évaluation',
              style: TechSosStyles.headingMedium,
            ),
            const SizedBox(height: 12),
            const StarRating(
              rating: 4.5,
              size: 24,
            ),
            const SizedBox(height: 24),
            const Text(
              'Actions',
              style: TechSosStyles.headingMedium,
            ),
            const SizedBox(height: 12),
            TechSosButton(
              label: 'Créer une demande SOS',
              icon: Icons.add_circle_outline,
              onPressed: () {},
            ),
            const SizedBox(height: 12),
            TechSosButton(
              label: 'Consulter l\'historique',
              isSecondary: true,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

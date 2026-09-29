import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/styles.dart';
import 'login_screen.dart';
import 'register_client_screen.dart';
import 'register_provider_screen.dart';

/// Écran d'accueil et de sélection de rôle pour TechSOS Bamako
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TechSosColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  // Logo / Marque TechSOS
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: TechSosColors.primary,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: TechSosColors.primary.withValues(alpha: 0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.build_circle_rounded,
                        color: Colors.white,
                        size: 42,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Titre et sous-titre
                  const Text(
                    'Bienvenue sur TechSOS',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: TechSosColors.primary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'La solution d\'urgence pour vos appareils en panne à Bamako',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                      color: TechSosColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 40),

                  const Text(
                    'Comment souhaitez-vous utiliser TechSOS ?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: TechSosColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Carte Mode Client
                  _RoleCard(
                    icon: Icons.person_rounded,
                    iconBackgroundColor: TechSosColors.accent.withValues(alpha: 0.12),
                    iconColor: TechSosColors.accent,
                    title: 'J\'ai un appareil en panne',
                    badgeText: 'Mode Client',
                    description:
                        'Trouvez un réparateur qualifié à proximité, comparez les offres et suivez votre réparation.',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const RegisterClientScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 18),

                  // Carte Mode Prestataire
                  _RoleCard(
                    icon: Icons.handyman_rounded,
                    iconBackgroundColor: TechSosColors.primary.withValues(alpha: 0.12),
                    iconColor: TechSosColors.primary,
                    title: 'Je suis réparateur / atelier',
                    badgeText: 'Mode Prestataire',
                    description:
                        'Rejoignez notre réseau professionnel, recevez des pannes en direct et développez votre atelier.',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const RegisterProviderScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 36),

                  // Lien vers Connexion
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Déjà un compte ?',
                        style: TextStyle(
                          fontSize: 14,
                          color: TechSosColors.textSecondary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Se connecter',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: TechSosColors.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconColor;
  final String title;
  final String badgeText;
  final String description;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.title,
    required this.badgeText,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TechSosColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: TechSosColors.border,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: iconBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: iconColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: iconColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          title,
                          style: TechSosStyles.headingMedium.copyWith(
                            fontSize: 15,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: TechSosColors.textSecondary,
                    size: 14,
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: TechSosColors.textSecondary,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

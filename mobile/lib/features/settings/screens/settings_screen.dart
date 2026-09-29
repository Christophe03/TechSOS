import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/styles.dart';
import '../../../core/widgets/techsos_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/widgets/change_password_dialog.dart';
import '../../auth/widgets/edit_profile_dialog.dart';
import '../providers/settings_provider.dart';

/// Écran des paramètres complet et professionnel de l'application TechSOS
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(settingsProvider.notifier).init());
  }

  void _showNotice(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: TechSosColors.primary),
            SizedBox(width: 10),
            Text('Se déconnecter ?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Voulez-vous vraiment vous déconnecter de votre compte TechSOS ?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler', style: TextStyle(color: TechSosColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      ref.read(authProvider.notifier).logout();
    }
  }

  Future<void> _confirmClearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.delete_sweep_rounded, color: TechSosColors.accent),
            SizedBox(width: 10),
            Text('Vider le cache ?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Les données hors-ligne temporaires seront libérées. Vos identifiants et annonces restent intacts.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler', style: TextStyle(color: TechSosColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: TechSosColors.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Vider'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(settingsProvider.notifier).clearCache();
      if (mounted) {
        _showNotice('Cache temporaire vidé avec succès !');
      }
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFE53935)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Supprimer mon compte ?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFE53935)),
              ),
            ),
          ],
        ),
        content: const Text(
          'Cette action est irréversible. Vos annonces, devis et informations personnelles associées à ce compte seront définitivement supprimés selon la réglementation en vigueur.',
          style: TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler', style: TextStyle(color: TechSosColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Confirmer la suppression'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      ref.read(authProvider.notifier).logout();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Votre demande de suppression de compte a été prise en compte.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: TechSosColors.primary)),
        content: SingleChildScrollView(
          child: Text(content, style: const TextStyle(fontSize: 14, height: 1.4)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Fermer', style: TextStyle(color: TechSosColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isProvider = user?.role == 'PROVIDER';
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      backgroundColor: TechSosColors.background,
      appBar: AppBar(
        title: const Text('Paramètres'),
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── MINI CARTE RÉSUMÉ PROFIL ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: TechSosColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: TechSosColors.primary.withValues(alpha: 0.1),
                        child: Icon(
                          isProvider ? Icons.storefront_rounded : Icons.person_rounded,
                          size: 32,
                          color: TechSosColors.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isProvider
                                  ? (user?.workshopName ?? user?.fullName ?? 'Atelier TechSOS')
                                  : (user?.fullName ?? 'Utilisateur TechSOS'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: TechSosColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user?.phone ?? '+223 ...',
                              style: TechSosStyles.bodySecondary,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: TechSosColors.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isProvider ? 'Compte Réparateur Pro' : 'Compte Client Bamako',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: TechSosColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Modifier mes informations',
                        icon: const Icon(Icons.edit_outlined, color: TechSosColors.primary),
                        onPressed: () => EditProfileDialog.show(context, isProvider: isProvider),
                      ),
                    ],
                  ),
                ),

                // ── 1. MON COMPTE ──
                _buildSectionHeader('MON COMPTE'),
                _buildCard([
                  _buildNavTile(
                    icon: Icons.person_outline_rounded,
                    title: 'Mon profil',
                    subtitle: 'Consulter et modifier vos coordonnées',
                    onTap: () => EditProfileDialog.show(context, isProvider: isProvider),
                  ),
                  const Divider(height: 1),
                  _buildNavTile(
                    icon: Icons.edit_outlined,
                    title: 'Modifier mes informations',
                    subtitle: isProvider ? 'Nom de l\'atelier, quartier, bio' : 'Nom, email, adresse',
                    onTap: () => EditProfileDialog.show(context, isProvider: isProvider),
                  ),
                  const Divider(height: 1),
                  _buildNavTile(
                    icon: Icons.lock_outline_rounded,
                    iconColor: TechSosColors.accent,
                    title: 'Modifier le mot de passe',
                    subtitle: 'Sécuriser votre accès avec un mot de passe robuste',
                    onTap: () => ChangePasswordDialog.show(context),
                  ),
                  const Divider(height: 1),
                  _buildInfoTile(
                    icon: Icons.phone_android_rounded,
                    title: 'Numéro de téléphone principal',
                    value: user?.phone ?? 'Non renseigné',
                  ),
                ]),

                // ── 2. NOTIFICATIONS ──
                _buildSectionHeader('NOTIFICATIONS'),
                _buildCard([
                  _buildSwitchTile(
                    icon: Icons.notifications_active_outlined,
                    title: 'Notifications push',
                    subtitle: 'Alertes en temps réel sur votre appareil',
                    value: settings.notifPush,
                    onChanged: (v) => settingsNotifier.setNotifPush(v),
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'Messages et devis',
                    subtitle: 'Nouvelles offres, réponses et statuts d\'atelier',
                    value: settings.notifMessages,
                    onChanged: (v) => settingsNotifier.setNotifMessages(v),
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    icon: Icons.alarm_rounded,
                    title: 'Rappels de dépannage',
                    subtitle: 'Appareils prêts au retrait, suivis en cours',
                    value: settings.notifRappels,
                    onChanged: (v) => settingsNotifier.setNotifRappels(v),
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    icon: Icons.campaign_outlined,
                    title: 'Actualités TechSOS',
                    subtitle: 'Nouveaux ateliers certifiés et guides techniques',
                    value: settings.notifActualites,
                    onChanged: (v) => settingsNotifier.setNotifActualites(v),
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    icon: Icons.local_offer_outlined,
                    title: 'Offres & Promotions',
                    subtitle: 'Bons plans sur les pièces et forfaits ateliers',
                    value: settings.notifPromos,
                    onChanged: (v) => settingsNotifier.setNotifPromos(v),
                  ),
                ]),

                // ── 3. APPARENCE ──
                _buildSectionHeader('APPARENCE'),
                _buildCard([
                  _buildThemeOptionTile(
                    icon: Icons.light_mode_rounded,
                    title: 'Thème clair',
                    subtitle: 'Interface lumineuse et contrastée (actif)',
                    isSelected: settings.theme == 'light',
                    badgeText: 'Actif',
                    badgeColor: TechSosColors.success,
                    onTap: () => settingsNotifier.setTheme('light'),
                  ),
                  const Divider(height: 1),
                  _buildThemeOptionTile(
                    icon: Icons.dark_mode_rounded,
                    title: 'Thème sombre',
                    subtitle: 'Réduit la fatigue oculaire la nuit',
                    isSelected: settings.theme == 'dark',
                    badgeText: 'Bientôt',
                    badgeColor: TechSosColors.alert,
                    onTap: () {
                      _showNotice('Le thème sombre complet arrive très prochainement dans la mise à jour !');
                    },
                  ),
                  const Divider(height: 1),
                  _buildThemeOptionTile(
                    icon: Icons.brightness_auto_rounded,
                    title: 'Thème automatique',
                    subtitle: 'S\'adapte aux paramètres de votre système Android / iOS',
                    isSelected: settings.theme == 'auto',
                    badgeText: 'Bientôt',
                    badgeColor: TechSosColors.alert,
                    onTap: () {
                      _showNotice('Le basculement automatique sera disponible avec le mode sombre.');
                    },
                  ),
                ]),

                // ── 4. LANGUE ET PRÉFÉRENCES ──
                _buildSectionHeader('LANGUE ET PRÉFÉRENCES'),
                _buildCard([
                  _buildNavTile(
                    icon: Icons.language_rounded,
                    title: 'Langue de l\'application',
                    subtitle: 'Français (Mali)',
                    trailingWidget: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Français', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: TechSosColors.primary)),
                        SizedBox(width: 4),
                        Icon(Icons.chevron_right_rounded, color: Colors.grey),
                      ],
                    ),
                    onTap: () => _showNotice('TechSOS est actuellement optimisé en Français. Le Bambara arrive bientôt !'),
                  ),
                  const Divider(height: 1),
                  _buildNavTile(
                    icon: Icons.location_on_outlined,
                    title: 'Ville et Région par défaut',
                    subtitle: 'Bamako (Communes I à VI)',
                    trailingWidget: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Bamako', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: TechSosColors.primary)),
                        SizedBox(width: 4),
                        Icon(Icons.chevron_right_rounded, color: Colors.grey),
                      ],
                    ),
                    onTap: () => _showNotice('Zone de couverture principale : District de Bamako, Mali.'),
                  ),
                  const Divider(height: 1),
                  _buildNavTile(
                    icon: Icons.payments_outlined,
                    iconColor: TechSosColors.success,
                    title: 'Devise monétaire',
                    subtitle: 'Franc CFA (FCFA) - XOF',
                    trailingWidget: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('FCFA', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: TechSosColors.success)),
                        SizedBox(width: 4),
                        Icon(Icons.chevron_right_rounded, color: Colors.grey),
                      ],
                    ),
                    onTap: () => _showNotice('La devise officielle appliquée à toutes les transactions est le FCFA.'),
                  ),
                ]),

                // ── 5. SÉCURITÉ ET CONFIDENTIALITÉ ──
                _buildSectionHeader('SÉCURITÉ ET CONFIDENTIALITÉ'),
                _buildCard([
                  _buildNavTile(
                    icon: Icons.lock_reset_rounded,
                    iconColor: TechSosColors.accent,
                    title: 'Changer le mot de passe',
                    subtitle: 'Mettre à jour vos clés d\'accès chiffrées (bcrypt)',
                    onTap: () => ChangePasswordDialog.show(context),
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    icon: Icons.fingerprint_rounded,
                    title: 'Déverrouillage biométrique',
                    subtitle: 'Empreinte digitale ou reconnaissance faciale',
                    value: settings.biometricsEnabled,
                    onChanged: (v) {
                      settingsNotifier.setBiometrics(v);
                      _showNotice(v ? 'Sécurité biométrique activée' : 'Sécurité biométrique désactivée');
                    },
                  ),
                  const Divider(height: 1),
                  _buildNavTile(
                    icon: Icons.security_rounded,
                    title: 'Sessions et sécurité',
                    subtitle: 'Authentification JWT sécurisée et stockage chiffré',
                    onTap: () {
                      _showInfoDialog(
                        'Sessions & Sécurité',
                        'Votre compte utilise une connexion sécurisée par jetons d\'accès JWT horodatés.\n\n'
                        'Toutes les communications vers l\'API TechSOS sont chiffrées et vos mots de passe sont protégés par un hachage unidirectionnel bcrypt avec sel fort.',
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildNavTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Données personnelles et RGPD / Mali',
                    subtitle: 'Gestion de vos informations et respect de la vie privée',
                    onTap: () {
                      _showInfoDialog(
                        'Données personnelles',
                        'Conformément aux lois applicables sur la protection des données personnelles au Mali :\n\n'
                        '• Vos coordonnées ne sont transmises qu\'aux réparateurs agréés lorsque vous acceptez un devis.\n'
                        '• Vous pouvez demander l\'export ou la suppression complète de vos données à tout moment.',
                      );
                    },
                  ),
                ]),

                // ── 6. DONNÉES ET STOCKAGE ──
                _buildSectionHeader('DONNÉES ET STOCKAGE'),
                _buildCard([
                  _buildSwitchTile(
                    icon: Icons.data_saver_on_outlined,
                    title: 'Économiseur de données mobiles',
                    subtitle: 'Réduit la qualité d\'affichage préalable des photos',
                    value: settings.dataSaver,
                    onChanged: (v) {
                      settingsNotifier.setDataSaver(v);
                      _showNotice(v ? 'Économiseur de données activé' : 'Économiseur de données désactivé');
                    },
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    icon: Icons.sync_rounded,
                    title: 'Synchronisation automatique hors-ligne',
                    subtitle: 'Télécharge les pannes et devis pour consultation hors-connexion',
                    value: settings.autoSync,
                    onChanged: (v) => settingsNotifier.setAutoSync(v),
                  ),
                  const Divider(height: 1),
                  _buildNavTile(
                    icon: Icons.delete_sweep_rounded,
                    iconColor: const Color(0xFFE53935),
                    title: 'Vider le cache applicatif',
                    subtitle: settings.isLoading ? 'Nettoyage en cours...' : 'Libérer l\'espace temporaire des images et requêtes',
                    trailingWidget: settings.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: TechSosColors.accent),
                          )
                        : const Icon(Icons.cleaning_services_outlined, color: Color(0xFFE53935), size: 20),
                    onTap: settings.isLoading ? null : _confirmClearCache,
                  ),
                ]),

                // ── 7. AIDE ET SUPPORT ──
                _buildSectionHeader('AIDE ET SUPPORT'),
                _buildCard([
                  _buildNavTile(
                    icon: Icons.help_outline_rounded,
                    title: 'Foire Aux Questions (FAQ)',
                    subtitle: 'Comment publier un SOS, accepter un devis, payer',
                    onTap: () {
                      _showInfoDialog(
                        'Foire Aux Questions',
                        '1. Comment publier un SOS ?\n'
                        'Allez dans l\'onglet "Publier SOS", enregistrez votre note vocale ou décrivez la panne avec photo, puis validez.\n\n'
                        '2. Comment choisir un réparateur ?\n'
                        'Les ateliers certifiés de Bamako vous envoient leurs devis (prix et délai). Vous choisissez l\'offre qui vous convient.\n\n'
                        '3. Quels sont les modes de paiement ?\n'
                        'Orange Money, Moov Money et règlement en espèces à l\'atelier.',
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildNavTile(
                    icon: Icons.support_agent_rounded,
                    iconColor: TechSosColors.primary,
                    title: 'Contacter l\'assistance client',
                    subtitle: 'Équipe support disponible 7j/7 à Bamako',
                    onTap: () {
                      _showInfoDialog(
                        'Assistance TechSOS Bamako',
                        'Notre équipe est à votre disposition :\n\n'
                        '📞 Téléphone : +223 70 00 00 00\n'
                        '💬 WhatsApp : +223 76 00 00 00\n'
                        '✉️ Email : support@techsos.ml\n\n'
                        'Horaires : Du lundi au samedi, de 8h00 à 19h00.',
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildNavTile(
                    icon: Icons.bug_report_outlined,
                    iconColor: const Color(0xFF795548),
                    title: 'Signaler un problème technique',
                    subtitle: 'Rapporter un dysfonctionnement ou une suggestion',
                    onTap: () {
                      _showNotice('Merci de contacter le support technique pour transmettre votre rapport de bug.');
                    },
                  ),
                ]),

                // ── 8. À PROPOS ──
                _buildSectionHeader('À PROPOS'),
                _buildCard([
                  _buildInfoTile(
                    icon: Icons.info_outline_rounded,
                    title: 'Version de l\'application',
                    value: 'TechSOS v1.0.0 (Build 2026)',
                  ),
                  const Divider(height: 1),
                  _buildInfoTile(
                    icon: Icons.domain_rounded,
                    title: 'Éditeur & Concepteur',
                    value: 'Golden Innovation Tech · Bamako',
                  ),
                  const Divider(height: 1),
                  _buildNavTile(
                    icon: Icons.article_outlined,
                    title: 'Conditions Générales d\'Utilisation (CGU)',
                    subtitle: 'Droits et devoirs des clients et réparateurs',
                    onTap: () {
                      _showInfoDialog(
                        'Conditions d\'Utilisation',
                        'Bienvenue sur TechSOS Bamako.\n\n'
                        'La plateforme met en relation des clients particuliers ou entreprises avec des ateliers de réparation électronique certifiés à Bamako.\n\n'
                        'Les réparateurs s\'engagent sur la conformité des pièces de rechange et les garanties annoncées dans leurs devis.',
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildNavTile(
                    icon: Icons.policy_outlined,
                    title: 'Politique de confidentialité',
                    subtitle: 'Protection des échanges et médias stockés',
                    onTap: () {
                      _showInfoDialog(
                        'Politique de Confidentialité',
                        'Vos données (notes vocales, photos des pannes, numéros de téléphone) sont exclusivement hébergées de manière sécurisée et ne sont en aucun cas revendues à des tiers.',
                      );
                    },
                  ),
                ]),

                // ── 9. GESTION DU COMPTE (ACTIONS SENSIBLES) ──
                _buildSectionHeader('GESTION DU COMPTE'),
                const SizedBox(height: 4),

                // Bouton Déconnexion
                TechSosButton(
                  label: 'Se déconnecter',
                  icon: Icons.logout_rounded,
                  isSecondary: true,
                  onPressed: _confirmLogout,
                ),
                const SizedBox(height: 12),

                // Bouton Supprimer le compte
                Center(
                  child: TextButton.icon(
                    onPressed: _confirmDeleteAccount,
                    icon: const Icon(Icons.delete_forever_outlined, color: Color(0xFFE53935), size: 20),
                    label: const Text(
                      'Supprimer mon compte définitivement',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFE53935),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Signature bas de page
                const Center(
                  child: Text(
                    'TechSOS Bamako v1.0.0\nGolden Innovation Tech · République du Mali',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: TechSosColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  COMPOSANTS VISUELS HELPER CONFORMES AU DESIGN SYSTEM EXISTANT
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 22),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: TechSosColors.textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: TechSosColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildNavTile({
    required IconData icon,
    Color iconColor = TechSosColors.primary,
    required String title,
    required String subtitle,
    Widget? trailingWidget,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: TechSosColors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: TechSosColors.textSecondary),
                  ),
                ],
              ),
            ),
            trailingWidget ?? const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    Color iconColor = TechSosColors.primary,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: TechSosColors.textPrimary),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: TechSosColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    Color iconColor = TechSosColors.primary,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: TechSosColors.textPrimary),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: TechSosColors.textSecondary),
      ),
      value: value,
      onChanged: onChanged,
      activeTrackColor: TechSosColors.accent,
      secondary: Icon(icon, color: iconColor, size: 22),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
      dense: true,
    );
  }

  Widget _buildThemeOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required String badgeText,
    required Color badgeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? TechSosColors.accent : TechSosColors.primary, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? TechSosColors.accent : TechSosColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: TechSosColors.textSecondary),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badgeText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: badgeColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: isSelected ? TechSosColors.accent : Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

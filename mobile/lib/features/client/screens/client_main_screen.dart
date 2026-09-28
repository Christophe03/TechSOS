import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/styles.dart';
import '../../../core/widgets/techsos_button.dart';
import '../../auth/providers/auth_provider.dart';
import 'client_home_screen.dart';
import 'my_requests_screen.dart';
import 'publish_repair_screen.dart';

/// Écran principal pour les clients avec barre de navigation inférieure (4 onglets)
class ClientMainScreen extends ConsumerStatefulWidget {
  final int initialTabIndex;

  const ClientMainScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  ConsumerState<ClientMainScreen> createState() => _ClientMainScreenState();
}

class _ClientMainScreenState extends ConsumerState<ClientMainScreen> {
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
      ClientHomeScreen(
        onPublishSosPressed: () => _switchTab(1),
      ),
      PublishRepairScreen(
        onPublishedSuccess: () => _switchTab(2),
      ),
      MyRequestsScreen(
        onNewRequestTap: () => _switchTab(1),
      ),
      _ClientProfileTab(
        onViewRequestsTap: () => _switchTab(2),
        onNewRequestTap: () => _switchTab(1),
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
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline_rounded),
              activeIcon: Icon(Icons.add_circle_rounded),
              label: 'Publier SOS',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.format_list_bulleted_rounded),
              activeIcon: Icon(Icons.list_alt_rounded),
              label: 'Mes Annonces',
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

/// Onglet profil du client
class _ClientProfileTab extends ConsumerWidget {
  final VoidCallback onViewRequestsTap;
  final VoidCallback onNewRequestTap;

  const _ClientProfileTab({
    required this.onViewRequestsTap,
    required this.onNewRequestTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: TechSosColors.background,
      appBar: AppBar(
        title: const Text(
          'Mon Profil Client',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: TechSosColors.primary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Carte d'identité client
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: TechSosColors.border),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: TechSosColors.primary.withValues(alpha: 0.1),
                    child: const Icon(
                      Icons.person,
                      size: 42,
                      color: TechSosColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.fullName ?? 'Utilisateur TechSOS',
                    style: TechSosStyles.headingLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.phone ?? '+223 ...',
                    style: TechSosStyles.bodySecondary,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: TechSosColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Compte Client • ${user?.city ?? "Bamako"}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: TechSosColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Actions rapides
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
                    leading: const Icon(Icons.history_rounded, color: TechSosColors.primary),
                    title: const Text('Mes demandes de dépannage', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: onViewRequestsTap,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.add_alert_rounded, color: TechSosColors.accent),
                    title: const Text('Lancer un nouveau SOS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: onNewRequestTap,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.help_outline_rounded, color: TechSosColors.primary),
                    title: const Text('Aide & Support Bamako', style: TextStyle(fontSize: 14)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
            const SizedBox(height: 24),

            // Bouton déconnexion
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
              'TechSOS Bamako v1.0.0\nGolden Innovation Tech',
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

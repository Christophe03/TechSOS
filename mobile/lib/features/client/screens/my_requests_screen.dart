import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/styles.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/techsos_button.dart';
import '../models/repair_model.dart';
import '../providers/client_repairs_provider.dart';
import 'request_detail_screen.dart';

/// Écran listant les annonces de pannes publiées par le client
/// avec badges de statut et compteurs d'offres reçues
class MyRequestsScreen extends ConsumerWidget {
  final VoidCallback? onNewRequestTap;

  const MyRequestsScreen({
    super.key,
    this.onNewRequestTap,
  });

  String _formatDate(DateTime date) {
    try {
      final formatter = DateFormat('dd/MM/yyyy à HH:mm', 'fr_FR');
      return formatter.format(date);
    } catch (_) {
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repairsState = ref.watch(clientRepairsProvider);
    final repairs = repairsState.repairs;

    return Scaffold(
      backgroundColor: TechSosColors.background,
      appBar: AppBar(
        title: const Text(
          'Mes Annonces SOS',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: TechSosColors.primary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualiser',
            onPressed: () {
              ref.read(clientRepairsProvider.notifier).loadMyRequests(refresh: true);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(clientRepairsProvider.notifier).loadMyRequests(refresh: true);
        },
        child: repairsState.isLoading && repairs.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : repairs.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: repairs.length,
                    itemBuilder: (context, index) {
                      final item = repairs[index];
                      return _buildRepairCard(context, item);
                    },
                  ),
      ),
      floatingActionButton: repairs.isNotEmpty
          ? FloatingActionButton.extended(
              key: const ValueKey('my_requests_new_fab'),
              backgroundColor: TechSosColors.accent,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Nouveau SOS',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: onNewRequestTap,
            )
          : null,
    );
  }

  /// Vue vide lorsqu'aucune annonce n'a encore été publiée
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: TechSosColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment_outlined,
                size: 54,
                color: TechSosColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Aucune demande en cours',
              style: TechSosStyles.headingLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Vous n\'avez pas encore publié de demande de dépannage. Décrivez votre panne pour recevoir des devis des réparateurs.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: TechSosColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            TechSosButton(
              key: const ValueKey('empty_new_request_button'),
              label: 'Lancer un SOS de dépannage',
              icon: Icons.add_circle_outline,
              onPressed: onNewRequestTap,
            ),
          ],
        ),
      ),
    );
  }

  /// Carte d'une demande avec badge de statut et offres
  Widget _buildRepairCard(BuildContext context, RepairModel item) {
    final count = item.offersCount;
    final hasOffers = count > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          key: ValueKey('request_card_${item.id}'),
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => RequestDetailScreen(repair: item),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête : Catégorie & Badge de statut
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.displayTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: TechSosColors.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusBadge(
                      status: item.status,
                      fontSize: 14,
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Extrait de description
                Text(
                  item.descriptionText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: TechSosColors.textPrimary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),

                // Note vocale attachée
                if (item.voiceAudioUrl != null && item.voiceAudioUrl!.isNotEmpty) ...[
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: TechSosColors.accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.mic, size: 14, color: TechSosColors.accent),
                            SizedBox(width: 4),
                            Text(
                              'Note vocale attachée',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: TechSosColors.accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],

                const Divider(height: 18),

                // Pied de carte : Date + Badge offres reçues
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDate(item.createdAt),
                      style: const TextStyle(
                        fontSize: 14,
                        color: TechSosColors.textSecondary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: hasOffers
                            ? TechSosColors.accent.withValues(alpha: 0.15)
                            : TechSosColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            hasOffers ? Icons.local_offer_rounded : Icons.hourglass_empty_rounded,
                            size: 14,
                            color: hasOffers ? TechSosColors.accent : TechSosColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            hasOffers
                                ? '$count offre${count > 1 ? 's' : ''} reçue${count > 1 ? 's' : ''}'
                                : '0 offre',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: hasOffers ? TechSosColors.accent : TechSosColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

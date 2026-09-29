import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/styles.dart';
import '../../client/models/offer_model.dart';
import '../providers/provider_workshop_provider.dart';

/// Écran de suivi des devis / offres soumis par le réparateur
class MyOffersScreen extends ConsumerStatefulWidget {
  const MyOffersScreen({super.key});

  @override
  ConsumerState<MyOffersScreen> createState() => _MyOffersScreenState();
}

class _MyOffersScreenState extends ConsumerState<MyOffersScreen> {
  String _filter = 'ALL'; // 'ALL', 'PENDING', 'ACCEPTED', 'REJECTED'

  @override
  Widget build(BuildContext context) {
    final offersAsync = ref.watch(providerOffersProvider);

    return Scaffold(
      backgroundColor: TechSosColors.background,
      appBar: AppBar(
        title: const Text('Mes Offres & Devis'),
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              // Filtres par statut scrollables horizontalement
              Container(
                color: Colors.white,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('ALL', 'Toutes'),
                      const SizedBox(width: 8),
                      _buildFilterChip('PENDING', 'En attente'),
                      const SizedBox(width: 8),
                      _buildFilterChip('ACCEPTED', 'Acceptées'),
                      const SizedBox(width: 8),
                      _buildFilterChip('REJECTED', 'Refusées'),
                    ],
                  ),
                ),
              ),

              // Liste des offres
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(providerOffersProvider);
                  },
                  child: offersAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
                            const SizedBox(height: 12),
                            const Text(
                              'Erreur de chargement',
                              style: TechSosStyles.headingMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              error.toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 14, color: TechSosColors.textSecondary),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => ref.invalidate(providerOffersProvider),
                              child: const Text('Réessayer', style: TextStyle(fontSize: 14)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    data: (offers) {
                      final filtered = offers.where((offer) {
                        if (_filter == 'ALL') return true;
                        return offer.status.toUpperCase() == _filter;
                      }).toList();

                      if (filtered.isEmpty) {
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            const SizedBox(height: 60),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: TechSosColors.border),
                                      ),
                                      child: const Icon(
                                        Icons.local_offer_outlined,
                                        size: 48,
                                        color: TechSosColors.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Aucune offre trouvée',
                                      style: TechSosStyles.headingMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Consultez le fil des pannes pour soumettre des devis aux clients de Bamako.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: TechSosColors.textSecondary,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final offer = filtered[index];
                          return _OfferCard(offer: offer);
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _filter == key;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : TechSosColors.textPrimary,
        ),
      ),
      selected: isSelected,
      selectedColor: TechSosColors.primary,
      backgroundColor: TechSosColors.background,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _filter = key;
          });
        }
      },
    );
  }
}

/// Carte d'une offre soumise
class _OfferCard extends StatelessWidget {
  final OfferModel offer;

  const _OfferCard({required this.offer});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy à HH:mm');
    final formattedDate = dateFormat.format(offer.createdAt);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: TechSosColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge Panne / Catégorie si disponible
            if (offer.categoryName != null || offer.issueTypeName != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: TechSosColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.devices_other_rounded, size: 14, color: TechSosColors.primary),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '${offer.categoryName ?? "Appareil"} • ${offer.issueTypeName ?? "Panne"}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: TechSosColors.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],

            // Titre de la panne si disponible
            if (offer.repairTitle != null && offer.repairTitle!.isNotEmpty) ...[
              Text(
                offer.repairTitle!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: TechSosColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
            ],

            // Statut de l'offre et date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _OfferStatusPill(status: offer.status),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 13,
                    color: TechSosColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Prix et Délai
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: TechSosColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: TechSosColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: TechSosColors.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.payments_rounded,
                      color: TechSosColors.accent,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${offer.priceCfa} FCFA',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: TechSosColors.primary,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.timer_outlined,
                              size: 14,
                              color: TechSosColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Délai : ${offer.estimatedDuration}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: TechSosColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Commentaire / Message du réparateur
            if (offer.comment != null && offer.comment!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: TechSosColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '"${offer.comment}"',
                  style: const TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: TechSosColors.textPrimary,
                  ),
                ),
              ),
            ],

            // Encart Contact Client lorsque l'offre est ACCEPTÉE
            if (offer.isAccepted && (offer.clientName != null || offer.clientPhone != null)) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E8B57).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF2E8B57).withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF2E8B57),
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Offre acceptée ! Contactez le client :',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E8B57),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Client : ${offer.clientName ?? "Client"} • ${offer.clientCity ?? "Bamako"}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: TechSosColors.textPrimary,
                      ),
                    ),
                    if (offer.clientPhone != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Téléphone : ${offer.clientPhone}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: TechSosColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.tag_rounded,
                  size: 16,
                  color: TechSosColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Demande #${offer.repairRequestId.substring(0, offer.repairRequestId.length > 8 ? 8 : offer.repairRequestId.length)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: TechSosColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Pill de statut pour une offre
class _OfferStatusPill extends StatelessWidget {
  final String status;

  const _OfferStatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    String label;
    Color color;

    switch (status.toUpperCase()) {
      case 'ACCEPTED':
        label = 'Acceptée par le client';
        color = const Color(0xFF2E8B57); // Vert #2E8B57
        break;
      case 'REJECTED':
        label = 'Refusée';
        color = const Color(0xFF595959); // Gris #595959
        break;
      case 'PENDING':
      default:
        label = 'En attente';
        color = const Color(0xFFD9A441); // Ambre #D9A441
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

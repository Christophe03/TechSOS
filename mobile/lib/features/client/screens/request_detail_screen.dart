import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/styles.dart';
import '../../../core/widgets/audio_recorder_widget.dart';
import '../../../core/widgets/star_rating.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/techsos_button.dart';
import '../models/offer_model.dart';
import '../models/repair_model.dart';
import '../providers/client_repairs_provider.dart';
import 'leave_review_dialog.dart';

/// Écran de détail d'une demande SOS : affichage de la panne, lecteur audio,
/// liste comparative des offres reçues avec acceptation et évaluation finale.
class RequestDetailScreen extends ConsumerStatefulWidget {
  final RepairModel repair;

  const RequestDetailScreen({
    super.key,
    required this.repair,
  });

  @override
  ConsumerState<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends ConsumerState<RequestDetailScreen> {
  late RepairModel _currentRepair;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentRepair = widget.repair;
    _refreshDetail();
  }

  Future<void> _refreshDetail() async {
    setState(() {
      _isLoading = true;
    });

    final updated = await ref
        .read(clientRepairsProvider.notifier)
        .getRepairDetail(_currentRepair.id);

    if (mounted) {
      setState(() {
        if (updated != null) {
          _currentRepair = updated;
        }
        _isLoading = false;
      });
    }
  }

  String _formatPrice(int amount) {
    final str = amount.toString();
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return '${str.replaceAllMapped(reg, (m) => '${m[1]} ')} FCFA';
  }

  String _formatDate(DateTime date) {
    try {
      final formatter = DateFormat('dd MMMM yyyy à HH:mm', 'fr_FR');
      return formatter.format(date);
    } catch (_) {
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    }
  }

  Future<void> _handleAcceptOffer(OfferModel offer) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirmer l\'offre', style: TechSosStyles.headingMedium),
        content: Text(
          'Accepter le devis de ${offer.workshopName} pour un montant de ${_formatPrice(offer.priceCfa)} et un délai de ${offer.estimatedDuration} ?',
          style: TechSosStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler', style: TextStyle(color: TechSosColors.textSecondary, fontSize: 14)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: TechSosColors.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Accepter cette offre', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final success = await ref.read(clientRepairsProvider.notifier).acceptOffer(
          repairId: _currentRepair.id,
          offerId: offer.id,
        );

    if (!mounted) return;

    if (success) {
      await _refreshDetail();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Offre de ${offer.workshopName} acceptée avec succès !'),
          backgroundColor: TechSosColors.success,
        ),
      );
    }
  }

  Future<void> _openReviewDialog() async {
    final result = await LeaveReviewDialog.show(
      context,
      repairId: _currentRepair.id,
      workshopName: _currentRepair.offers?.firstWhere(
        (o) => o.id == _currentRepair.selectedOfferId,
        orElse: () => _currentRepair.offers!.first,
      ).workshopName,
    );

    if (result == true) {
      _refreshDetail();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Si la liste globale est mise à jour, synchroniser l'affichage
    final globalRepairs = ref.watch(clientRepairsProvider).repairs;
    final synced = globalRepairs.where((r) => r.id == _currentRepair.id).firstOrNull;
    if (synced != null) {
      _currentRepair = synced;
    }

    final offers = _currentRepair.offers ?? [];
    final canAcceptOffer =
        _currentRepair.isPending || _currentRepair.status == 'OFFERS_RECEIVED';
    final isCompleted = _currentRepair.isCompleted;

    return Scaffold(
      backgroundColor: TechSosColors.background,
      appBar: AppBar(
        title: Text(
          _currentRepair.displayTitle,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: TechSosColors.primary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualiser',
            onPressed: _refreshDetail,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshDetail,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Carte d'en-tête de la demande
              _buildHeaderCard(),
              const SizedBox(height: 20),

              // Description textuelle et note vocale
              _buildDescriptionCard(),
              const SizedBox(height: 24),

              // Bouton d'évaluation si la réparation est terminée
              if (isCompleted) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: TechSosColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: TechSosColors.success.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.check_circle_rounded, color: TechSosColors.success, size: 24),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Réparation terminée avec succès !',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: TechSosColors.success,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TechSosButton(
                        key: const ValueKey('leave_review_button'),
                        label: 'Évaluer la réparation',
                        icon: Icons.star_rate_rounded,
                        onPressed: _openReviewDialog,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Section Offres des Réparateurs
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Offres des réparateurs (${offers.length})',
                    style: TechSosStyles.headingMedium,
                  ),
                  if (_isLoading)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              if (offers.isEmpty)
                _buildNoOffersPlaceholder()
              else
                Column(
                  children: offers.map((offer) {
                    final isThisOfferAccepted =
                        offer.isAccepted || _currentRepair.selectedOfferId == offer.id;

                    return _buildOfferCard(
                      offer: offer,
                      isAccepted: isThisOfferAccepted,
                      canAccept: canAcceptOffer,
                    );
                  }).toList(),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// Carte d'en-tête de la demande (statut, catégorie, date, localisation)
  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: TechSosColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TechSosColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatusBadge(
                key: const ValueKey('detail_status_badge'),
                status: _currentRepair.status,
                fontSize: 14,
              ),
              Text(
                'SOS #${_currentRepair.id.length > 6 ? _currentRepair.id.substring(0, 6) : _currentRepair.id}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: TechSosColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _currentRepair.displayIssue,
            style: TechSosStyles.headingLarge,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.devices_other_rounded, size: 16, color: TechSosColors.primary),
              const SizedBox(width: 6),
              Text(
                _currentRepair.categoryName ?? 'Appareil',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: TechSosColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (_currentRepair.locationAddress != null) ...[
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: TechSosColors.accent),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _currentRepair.locationAddress!,
                    style: const TextStyle(fontSize: 14, color: TechSosColors.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
          Row(
            children: [
              const Icon(Icons.access_time_rounded, size: 16, color: TechSosColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                'Publiée le ${_formatDate(_currentRepair.createdAt)}',
                style: const TextStyle(fontSize: 14, color: TechSosColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Carte contenant la description textuelle et le lecteur audio
  Widget _buildDescriptionCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: TechSosColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TechSosColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description du problème',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: TechSosColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _currentRepair.descriptionText,
            style: const TextStyle(
              fontSize: 15,
              color: TechSosColors.textPrimary,
              height: 1.4,
            ),
          ),

          // Lecteur de note vocale si disponible
          if (_currentRepair.voiceAudioUrl != null &&
              _currentRepair.voiceAudioUrl!.isNotEmpty) ...[
            const SizedBox(height: 16),
            AudioPlayerCard(
              audioUrl: _currentRepair.voiceAudioUrl!,
              title: 'Note vocale du client attachée',
            ),
          ],
        ],
      ),
    );
  }

  /// Placeholder lorsqu'aucune offre n'a encore été reçue
  Widget _buildNoOffersPlaceholder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: TechSosColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TechSosColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: TechSosColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.hourglass_top_rounded,
              color: TechSosColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'En attente des devis des réparateurs',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: TechSosColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Votre SOS a été notifié aux ateliers proches de votre quartier à Bamako. Dès qu\'une offre arrive, vous pourrez la comparer et l\'accepter ici.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: TechSosColors.textSecondary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  /// Carte comparative d'une offre reçue d'un réparateur
  Widget _buildOfferCard({
    required OfferModel offer,
    required bool isAccepted,
    required bool canAccept,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: TechSosColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAccepted ? TechSosColors.success : TechSosColors.border,
          width: isAccepted ? 2.0 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isAccepted
                ? TechSosColors.success.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête de l'atelier & Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: isAccepted
                    ? TechSosColors.success.withValues(alpha: 0.15)
                    : TechSosColors.primary.withValues(alpha: 0.1),
                child: Icon(
                  Icons.build_circle_rounded,
                  color: isAccepted ? TechSosColors.success : TechSosColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.workshopName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: TechSosColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        StarRating(rating: offer.providerRating, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${offer.providerRating.toStringAsFixed(1)} (${offer.providerReviewCount} avis)',
                          style: const TextStyle(
                            fontSize: 14,
                            color: TechSosColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isAccepted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: TechSosColors.success,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check, size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'Retenue',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Prix mis en avant et Délai
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: TechSosColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: TechSosColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PRIX PROPOSÉ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: TechSosColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatPrice(offer.priceCfa),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: TechSosColors.accent,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'DÉLAI ESTIMÉ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: TechSosColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined, size: 16, color: TechSosColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          offer.estimatedDuration,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: TechSosColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Commentaire du réparateur
          if (offer.comment != null && offer.comment!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              '« ${offer.comment} »',
              style: const TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: TechSosColors.textSecondary,
                height: 1.3,
              ),
            ),
          ],

          // Bouton d'action "Accepter cette offre"
          if (canAccept && !isAccepted) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                key: ValueKey('accept_offer_${offer.id}'),
                icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
                label: const Text(
                  'Accepter cette offre',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TechSosColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => _handleAcceptOffer(offer),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

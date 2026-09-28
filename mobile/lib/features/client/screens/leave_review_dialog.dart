import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/styles.dart';
import '../../../core/widgets/star_rating.dart';
import '../../../core/widgets/techsos_button.dart';
import '../providers/client_repairs_provider.dart';

/// Dialogue modal permettant au client de noter et commenter une réparation terminée (1 à 5 étoiles)
class LeaveReviewDialog extends ConsumerStatefulWidget {
  final String repairId;
  final String? workshopName;

  const LeaveReviewDialog({
    super.key,
    required this.repairId,
    this.workshopName,
  });

  /// Méthode statique utilitaire pour afficher le dialogue
  static Future<bool?> show(
    BuildContext context, {
    required String repairId,
    String? workshopName,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => LeaveReviewDialog(
        repairId: repairId,
        workshopName: workshopName,
      ),
    );
  }

  @override
  ConsumerState<LeaveReviewDialog> createState() => _LeaveReviewDialogState();
}

class _LeaveReviewDialogState extends ConsumerState<LeaveReviewDialog> {
  int _selectedRating = 5;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _isSubmitting = true;
    });

    final success = await ref.read(clientRepairsProvider.notifier).submitReview(
          repairId: widget.repairId,
          rating: _selectedRating,
          comment: _commentController.text.trim(),
        );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Merci pour votre avis !'),
          backgroundColor: TechSosColors.success,
        ),
      );
    } else {
      final error = ref.read(clientRepairsProvider).errorMessage ?? 'Erreur lors de l\'envoi de l\'avis.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  String _getRatingLabel(int rating) {
    switch (rating) {
      case 1:
        return 'Très insatisfait';
      case 2:
        return 'Peu satisfait';
      case 3:
        return 'Moyen / Acceptable';
      case 4:
        return 'Très satisfait';
      case 5:
        return 'Excellent travail !';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: TechSosColors.alert.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.star_rounded,
                color: TechSosColors.alert,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Évaluer la réparation',
              style: TechSosStyles.headingLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              widget.workshopName != null
                  ? 'Comment s\'est passé le dépannage avec ${widget.workshopName} ?'
                  : 'Partagez votre expérience pour aider la communauté de Bamako.',
              style: TechSosStyles.bodySecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Étoiles interactives de 1 à 5
            StarRating(
              key: const ValueKey('dialog_interactive_stars'),
              rating: _selectedRating.toDouble(),
              size: 40,
              isInteractive: true,
              onRatingChanged: (newRating) {
                setState(() {
                  _selectedRating = newRating;
                });
              },
            ),
            const SizedBox(height: 10),
            Text(
              _getRatingLabel(_selectedRating),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: TechSosColors.primary,
              ),
            ),
            const SizedBox(height: 20),

            // Champ commentaire
            TextFormField(
              key: const ValueKey('review_comment_input'),
              controller: _commentController,
              minLines: 3,
              maxLines: 4,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Votre commentaire (délais respectés, qualité, accueil...)',
                hintStyle: const TextStyle(fontSize: 14, color: Colors.black38),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: TechSosColors.border),
                ),
                filled: true,
                fillColor: TechSosColors.background,
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 24),

            // Boutons d'action
            TechSosButton(
              key: const ValueKey('submit_review_button'),
              label: 'Envoyer mon avis',
              icon: Icons.send_rounded,
              isLoading: _isSubmitting,
              onPressed: _handleSubmit,
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(false),
              child: const Text(
                'Plus tard',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: TechSosColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

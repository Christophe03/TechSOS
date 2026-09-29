import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/techsos_button.dart';
import '../../client/models/repair_model.dart';
import '../providers/provider_workshop_provider.dart';

/// Boîte de dialogue ou Bottom Sheet pour soumettre une offre / devis pour une panne
class SubmitOfferDialog extends ConsumerStatefulWidget {
  final RepairModel repair;

  const SubmitOfferDialog({
    super.key,
    required this.repair,
  });

  /// Méthode d'aide pour afficher la modale
  static Future<bool?> show(BuildContext context, RepairModel repair) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SubmitOfferDialog(repair: repair),
    );
  }

  @override
  ConsumerState<SubmitOfferDialog> createState() => _SubmitOfferDialogState();
}

class _SubmitOfferDialogState extends ConsumerState<SubmitOfferDialog> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController(text: '3 heures');
  final _commentController = TextEditingController();

  final List<String> _durationChips = [
    '1 heure',
    '3 heures',
    '24h',
    '48h',
    '3 jours',
  ];

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _priceController.dispose();
    _durationController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final price = int.parse(_priceController.text.trim());
    final duration = _durationController.text.trim();
    final comment = _commentController.text.trim();

    try {
      await ref.read(providerWorkshopProvider).submitOffer(
            widget.repair.id,
            price,
            duration,
            comment.isEmpty ? null : comment,
          );

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Offre de $price FCFA envoyée au client avec succès !',
              style: const TextStyle(fontSize: 14),
            ),
            backgroundColor: TechSosColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Poignée de glissement
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // En-tête
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Faire une offre de devis',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: TechSosColors.primary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Rappel de la panne
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: TechSosColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: TechSosColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.repair.displayTitle,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: TechSosColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.repair.descriptionText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: TechSosColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Champ Prix
              const Text(
                'Prix proposé (FCFA) *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: TechSosColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                decoration: const InputDecoration(
                  hintText: 'Ex : 7500',
                  suffixText: 'FCFA',
                  suffixStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: TechSosColors.primary,
                  ),
                  prefixIcon: Icon(Icons.payments_outlined, color: TechSosColors.primary),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez saisir un tarif';
                  }
                  final parsed = int.tryParse(value.trim());
                  if (parsed == null || parsed < 500) {
                    return 'Le prix minimum est de 500 FCFA';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Délai estimé
              const Text(
                'Délai estimé de réparation *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: TechSosColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _durationChips.map((duration) {
                  final isSelected = _durationController.text == duration;
                  return ChoiceChip(
                    label: Text(
                      duration,
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
                          _durationController.text = duration;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _durationController,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Ou personnalisez le délai',
                  prefixIcon: Icon(Icons.timer_outlined, color: TechSosColors.primary),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez préciser un délai';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Commentaire / Note au client
              const Text(
                'Message ou précision pour le client (optionnel)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: TechSosColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _commentController,
                maxLines: 3,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Ex : Diagnostic gratuit, pièce d\'origine sous garantie 3 mois...',
                ),
              ),
              const SizedBox(height: 20),

              // Bouton Soumettre
              TechSosButton(
                label: 'Envoyer mon offre',
                icon: Icons.send_rounded,
                isLoading: _isSubmitting,
                onPressed: _handleSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

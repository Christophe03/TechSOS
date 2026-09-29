import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/techsos_button.dart';
import '../models/workshop_entry_model.dart';
import '../providers/provider_workshop_provider.dart';

/// Modal d'enregistrement rapide d'un client physique au comptoir de l'atelier
class QuickClientEntryDialog extends ConsumerStatefulWidget {
  const QuickClientEntryDialog({super.key});

  /// Méthode d'aide pour afficher la boîte de dialogue modale
  static Future<WorkshopEntryModel?> show(BuildContext context) {
    return showModalBottomSheet<WorkshopEntryModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const QuickClientEntryDialog(),
    );
  }

  @override
  ConsumerState<QuickClientEntryDialog> createState() =>
      _QuickClientEntryDialogState();
}

class _QuickClientEntryDialogState
    extends ConsumerState<QuickClientEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _clientNameController = TextEditingController();
  final _clientPhoneController = TextEditingController(text: '+223 ');
  final _deviceModelController = TextEditingController();
  final _issueSummaryController = TextEditingController();
  final _priceController = TextEditingController();

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _clientNameController.dispose();
    _clientPhoneController.dispose();
    _deviceModelController.dispose();
    _issueSummaryController.dispose();
    _priceController.dispose();
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

    final name = _clientNameController.text.trim();
    var phone = _clientPhoneController.text.trim();
    if (!phone.startsWith('+')) {
      phone = '+223$phone';
    }
    final device = _deviceModelController.text.trim();
    final issue = _issueSummaryController.text.trim();
    final price = _priceController.text.trim().isNotEmpty
        ? int.tryParse(_priceController.text.trim())
        : null;

    try {
      final entry = await ref.read(providerWorkshopProvider).createQuickEntry(
            name,
            phone,
            device,
            issue,
            price,
          );

      if (mounted) {
        Navigator.of(context).pop(entry);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Appareil $device enregistré ! Notification WhatsApp envoyée à $phone.',
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
                    'Entrée atelier (Comptoir)',
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
              const SizedBox(height: 12),

              // Bannière WhatsApp obligatoire selon le cahier des charges
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E8B57).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF2E8B57).withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('📱', style: TextStyle(fontSize: 20)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Un message WhatsApp de confirmation sera automatiquement envoyé au client à l'enregistrement.",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1F3A5F),
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
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

              // Nom du client
              const Text(
                'Nom complet du client *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: TechSosColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _clientNameController,
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Ex : Oumar Traoré',
                  prefixIcon: Icon(Icons.person_outline, color: TechSosColors.primary),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Veuillez saisir le nom du client';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Numéro WhatsApp / Téléphone Malien
              const Text(
                'Numéro de téléphone Malien (WhatsApp) *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: TechSosColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _clientPhoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: '+223 70 12 34 56',
                  prefixIcon: Icon(Icons.phone_android_rounded, color: TechSosColors.primary),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Veuillez saisir un numéro de téléphone';
                  }
                  final clean = val.replaceAll(RegExp(r'\s+'), '');
                  if (!clean.startsWith('+223') && clean.length != 8) {
                    return 'Format attendu : +223XXXXXXXX ou 8 chiffres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Modèle d'appareil
              const Text(
                'Modèle de l\'appareil déposé *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: TechSosColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _deviceModelController,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Ex : iPhone 12 Pro / Tecno Camon 20 / HP ProBook',
                  prefixIcon: Icon(Icons.devices_other_rounded, color: TechSosColors.primary),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Veuillez renseigner le modèle d\'appareil';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Description de la panne
              const Text(
                'Description de la panne constatée *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: TechSosColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _issueSummaryController,
                maxLines: 2,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Ex : Écran noir suite à une chute, vibre encore.',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Veuillez décrire le problème constaté';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Prix estimé (optionnel)
              const Text(
                'Prix estimé ou convenu (FCFA, optionnel)',
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
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Ex : 15000',
                  suffixText: 'FCFA',
                  prefixIcon: Icon(Icons.payments_outlined, color: TechSosColors.primary),
                ),
              ),
              const SizedBox(height: 20),

              // Bouton Enregistrer et notifier
              TechSosButton(
                label: 'Enregistrer et notifier',
                icon: Icons.send_to_mobile_rounded,
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/styles.dart';
import '../../../core/widgets/techsos_button.dart';
import '../providers/auth_provider.dart';

/// Boîte de dialogue pour modifier les informations de profil (Client ou Réparateur)
class EditProfileDialog extends ConsumerStatefulWidget {
  final bool isProvider;

  const EditProfileDialog({
    super.key,
    required this.isProvider,
  });

  static Future<void> show(BuildContext context, {required bool isProvider}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => EditProfileDialog(isProvider: isProvider),
    );
  }

  @override
  ConsumerState<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends ConsumerState<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _cityController;
  late TextEditingController _addressController;

  // Spécifique réparateur
  late TextEditingController _workshopNameController;
  late TextEditingController _addressZoneController;
  late TextEditingController _bioController;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;

    _fullNameController = TextEditingController(text: user?.fullName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _cityController = TextEditingController(text: user?.city ?? 'Bamako');
    _addressController = TextEditingController(text: user?.address ?? '');

    _workshopNameController = TextEditingController(text: user?.workshopName ?? '');
    _addressZoneController = TextEditingController(text: user?.addressZone ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _workshopNameController.dispose();
    _addressZoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final success = await ref.read(authProvider.notifier).updateProfile(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      city: _cityController.text.trim().isEmpty ? 'Bamako' : _cityController.text.trim(),
      address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      workshopName: widget.isProvider ? _workshopNameController.text.trim() : null,
      addressZone: widget.isProvider ? _addressZoneController.text.trim() : null,
      bio: widget.isProvider ? _bioController.text.trim() : null,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: TechSosColors.success,
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Profil mis à jour avec succès !',
            style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      );
    } else {
      final error = ref.read(authProvider).errorMessage ?? 'Une erreur est survenue';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          content: Text(
            error,
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // En-tête
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: TechSosColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        widget.isProvider ? Icons.storefront_rounded : Icons.person_rounded,
                        color: TechSosColors.primary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.isProvider ? 'Modifier l\'Atelier' : 'Modifier mon profil',
                            style: TechSosStyles.headingMedium,
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Mettez à jour vos coordonnées à Bamako',
                            style: TextStyle(
                              fontSize: 14,
                              color: TechSosColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.grey),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Badge téléphone fixe / non modifiable directement
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: TechSosColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: TechSosColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.phone_android_rounded, size: 20, color: TechSosColors.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Numéro de téléphone vérifié (non modifiable)',
                              style: TextStyle(fontSize: 12, color: TechSosColors.textSecondary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user?.phone ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: TechSosColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.verified_rounded, size: 18, color: TechSosColors.success),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Nom complet / Gérant
                TextFormField(
                  controller: _fullNameController,
                  decoration: InputDecoration(
                    labelText: widget.isProvider ? 'Nom du gérant / technicien *' : 'Nom complet *',
                    labelStyle: const TextStyle(fontSize: 14),
                    prefixIcon: const Icon(Icons.person_outline_rounded, color: TechSosColors.primary, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  style: const TextStyle(fontSize: 14),
                  validator: (val) {
                    if (val == null || val.trim().length < 2) {
                      return 'Veuillez saisir au moins 2 caractères';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Spécifique Réparateur : Nom de l'atelier
                if (widget.isProvider) ...[
                  TextFormField(
                    controller: _workshopNameController,
                    decoration: InputDecoration(
                      labelText: 'Nom de l\'atelier de réparation *',
                      labelStyle: const TextStyle(fontSize: 14),
                      prefixIcon: const Icon(Icons.build_circle_outlined, color: TechSosColors.accent, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    style: const TextStyle(fontSize: 14),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Le nom de l\'atelier est obligatoire';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Zone / Quartier réparateur
                  TextFormField(
                    controller: _addressZoneController,
                    decoration: InputDecoration(
                      labelText: 'Quartier d\'implantation à Bamako *',
                      labelStyle: const TextStyle(fontSize: 14),
                      hintText: 'Ex: Hamdallaye ACI 2000, Badalabougou, Lafiabougou',
                      hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                      prefixIcon: const Icon(Icons.location_on_outlined, color: TechSosColors.accent, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    style: const TextStyle(fontSize: 14),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Le quartier d\'implantation est obligatoire';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Bio / Spécialités réparateur
                  TextFormField(
                    controller: _bioController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Présentation de l\'atelier & compétences',
                      labelStyle: const TextStyle(fontSize: 14),
                      hintText: 'Ex: Plus de 10 ans d\'expérience en micro-soudure, réparation iPhone et PC portables.',
                      hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                      alignLabelWithHint: true,
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(bottom: 40),
                        child: Icon(Icons.description_outlined, color: TechSosColors.primary, size: 20),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 14),
                ],

                // Adresse / Quartier pour Client
                if (!widget.isProvider) ...[
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Adresse ou Quartier à Bamako',
                      labelStyle: const TextStyle(fontSize: 14),
                      hintText: 'Ex: Badalabougou, Rue 12, Porte 45',
                      hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                      prefixIcon: const Icon(Icons.home_outlined, color: TechSosColors.primary, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 14),
                ],

                // Email (optionnel)
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Adresse email (optionnel)',
                    labelStyle: const TextStyle(fontSize: 14),
                    prefixIcon: const Icon(Icons.email_outlined, color: TechSosColors.primary, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  style: const TextStyle(fontSize: 14),
                  validator: (val) {
                    if (val != null && val.trim().isNotEmpty) {
                      if (!val.contains('@') || !val.contains('.')) {
                        return 'Veuillez saisir une adresse email valide';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Ville
                TextFormField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    labelText: 'Ville de résidence',
                    labelStyle: const TextStyle(fontSize: 14),
                    prefixIcon: const Icon(Icons.location_city_rounded, color: TechSosColors.primary, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 24),

                // Boutons d'action
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: TechSosColors.border),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'Annuler',
                          style: TextStyle(
                            fontSize: 14,
                            color: TechSosColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TechSosButton(
                        label: 'Enregistrer',
                        icon: Icons.check_circle_rounded,
                        isLoading: _isSubmitting,
                        onPressed: _isSubmitting ? null : _submit,
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/techsos_button.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

/// Écran d'inscription pour les réparateurs et ateliers à Bamako
class RegisterProviderScreen extends ConsumerStatefulWidget {
  const RegisterProviderScreen({super.key});

  @override
  ConsumerState<RegisterProviderScreen> createState() =>
      _RegisterProviderScreenState();
}

class _RegisterProviderScreenState
    extends ConsumerState<RegisterProviderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _managerNameController = TextEditingController();
  final _phoneController = TextEditingController(text: '+223 ');
  final _passwordController = TextEditingController();
  final _workshopNameController = TextEditingController();
  final _addressZoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _emailController = TextEditingController();
  bool _obscurePassword = true;

  static const List<String> _popularBamakoZones = [
    'Hamdallaye ACI 2000',
    'Badalabougou',
    'Lafiabougou',
    'Kalaban Coura',
    'Magnambougou',
    'Sébénikoro',
    'Dravela',
    'Medina Coura',
    'Daoudabougou',
    'Yirimadio',
    'Faladié',
    'Baco Djicoroni',
  ];

  @override
  void dispose() {
    _managerNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _workshopNameController.dispose();
    _addressZoneController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await ref.read(authProvider.notifier).registerProvider(
          fullName: _managerNameController.text,
          phone: _phoneController.text,
          password: _passwordController.text,
          workshopName: _workshopNameController.text,
          addressZone: _addressZoneController.text,
          bio: _bioController.text.trim().isNotEmpty
              ? _bioController.text
              : null,
          email: _emailController.text.trim().isNotEmpty
              ? _emailController.text
              : null,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Atelier enregistré avec succès ! Bienvenue dans le réseau TechSOS.',
            style: TextStyle(fontSize: 14),
          ),
          backgroundColor: TechSosColors.success,
        ),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: TechSosColors.background,
      appBar: AppBar(
        title: const Text(
          'Inscription Réparateur',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: TechSosColors.primary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: TechSosColors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Inscrire mon Atelier',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: TechSosColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Rejoignez les réparateurs professionnels certifiés de Bamako et augmentez vos revenus.',
                  style: TextStyle(
                    fontSize: 14,
                    color: TechSosColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),

                // Bannière d'erreur si présente
                if (authState.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            authState.errorMessage!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Champ Nom du gérant
                const Text(
                  'Nom et Prénom du gérant *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: TechSosColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _managerNameController,
                  style: const TextStyle(fontSize: 15),
                  decoration: _buildInputDecoration(
                    hintText: 'Ex: Mamadou Diarra',
                    icon: Icons.badge_outlined,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez saisir le nom du gérant';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Champ Nom de l'atelier
                const Text(
                  'Nom de l\'atelier ou boutique *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: TechSosColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _workshopNameController,
                  style: const TextStyle(fontSize: 15),
                  decoration: _buildInputDecoration(
                    hintText: 'Ex: Diarra Électronique & Dépannage',
                    icon: Icons.storefront_rounded,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez saisir le nom de votre atelier';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Champ Téléphone
                const Text(
                  'Numéro de téléphone (+223...) *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: TechSosColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(fontSize: 15),
                  decoration: _buildInputDecoration(
                    hintText: '+223 70 00 00 00',
                    icon: Icons.phone_outlined,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez renseigner votre numéro professionnel';
                    }
                    if (value.trim().replaceAll(RegExp(r'\s+'), '').length < 8) {
                      return 'Numéro de téléphone invalide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Champ Mot de passe
                const Text(
                  'Mot de passe de connexion *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: TechSosColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(fontSize: 15),
                  decoration: _buildInputDecoration(
                    hintText: 'Minimum 6 caractères',
                    icon: Icons.lock_outline_rounded,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: TechSosColors.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez choisir un mot de passe';
                    }
                    if (value.length < 6) {
                      return 'Le mot de passe doit comporter au moins 6 caractères';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Champ Quartier à Bamako avec suggestions
                const Text(
                  'Quartier à Bamako *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: TechSosColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _addressZoneController,
                  style: const TextStyle(fontSize: 15),
                  decoration: _buildInputDecoration(
                    hintText: 'Ex: Hamdallaye ACI 2000, Badalabougou...',
                    icon: Icons.location_on_outlined,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez préciser le quartier de votre atelier';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                // Puces de sélection rapide de quartiers
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _popularBamakoZones.take(6).map((zone) {
                    return ActionChip(
                      label: Text(
                        zone,
                        style: const TextStyle(
                          fontSize: 14,
                          color: TechSosColors.primary,
                        ),
                      ),
                      backgroundColor: TechSosColors.primary.withValues(alpha: 0.08),
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      onPressed: () {
                        setState(() {
                          _addressZoneController.text = zone;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),

                // Champ Bio / Description
                const Text(
                  'Description de vos services & spécialités (optionnel)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: TechSosColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _bioController,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 15),
                  decoration: _buildInputDecoration(
                    hintText:
                        'Ex: Réparation d\'écrans iPhone & Samsung, microsoudure, déblocage logiciel...',
                    icon: Icons.description_outlined,
                  ),
                ),
                const SizedBox(height: 32),

                // Bouton Inscription Atelier
                TechSosButton(
                  label: 'Inscrire mon atelier',
                  isLoading: authState.isLoading,
                  icon: Icons.build_circle_outlined,
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: 24),

                // Lien Se connecter
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Déjà inscrit ?',
                      style: TextStyle(
                        fontSize: 14,
                        color: TechSosColors.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
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
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        fontSize: 14,
        color: TechSosColors.textSecondary,
      ),
      prefixIcon: Icon(icon, color: TechSosColors.primary),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: TechSosColors.cardBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: TechSosColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: TechSosColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: TechSosColors.primary,
          width: 2,
        ),
      ),
    );
  }
}

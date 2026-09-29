import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/techsos_button.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

/// Écran d'inscription pour les utilisateurs clients à Bamako
class RegisterClientScreen extends ConsumerStatefulWidget {
  const RegisterClientScreen({super.key});

  @override
  ConsumerState<RegisterClientScreen> createState() => _RegisterClientScreenState();
}

class _RegisterClientScreenState extends ConsumerState<RegisterClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController(text: '+223 ');
  final _passwordController = TextEditingController();
  final _cityController = TextEditingController(text: 'Bamako');
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await ref.read(authProvider.notifier).registerClient(
          fullName: _fullNameController.text,
          phone: _phoneController.text,
          password: _passwordController.text,
          city: _cityController.text,
          address: _addressController.text.trim().isNotEmpty
              ? _addressController.text
              : null,
          email: _emailController.text.trim().isNotEmpty
              ? _emailController.text
              : null,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Compte client créé avec succès ! Bienvenue sur TechSOS.',
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
          'Créer un compte Client',
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
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                const Text(
                  'Inscription Client',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: TechSosColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Trouvez rapidement une solution d\'urgence pour votre appareil en panne',
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

                // Champ Nom complet
                const Text(
                  'Nom complet *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: TechSosColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _fullNameController,
                  style: const TextStyle(fontSize: 15),
                  decoration: _buildInputDecoration(
                    hintText: 'Ex: Amadou Diallo',
                    icon: Icons.person_outline_rounded,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez saisir votre nom complet';
                    }
                    if (value.trim().length < 2) {
                      return 'Le nom est trop court';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Champ Numéro de téléphone
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
                      return 'Veuillez renseigner votre numéro de téléphone';
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
                  'Mot de passe *',
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

                // Champ Quartier / Adresse
                const Text(
                  'Quartier / Zone à Bamako *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: TechSosColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _addressController,
                  style: const TextStyle(fontSize: 15),
                  decoration: _buildInputDecoration(
                    hintText: 'Ex: Badalabougou, Hamdallaye ACI 2000, Faladié...',
                    icon: Icons.location_on_outlined,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez préciser votre quartier';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Champ Email (optionnel)
                const Text(
                  'Adresse Email (optionnelle)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: TechSosColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(fontSize: 15),
                  decoration: _buildInputDecoration(
                    hintText: 'Ex: client@exemple.ml',
                    icon: Icons.mail_outline_rounded,
                  ),
                ),
                const SizedBox(height: 32),

                // Bouton Inscription
                TechSosButton(
                  label: 'Créer mon compte Client',
                  isLoading: authState.isLoading,
                  icon: Icons.person_add_alt_1_rounded,
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: 24),

                // Lien Se connecter
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
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

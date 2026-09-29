import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/techsos_button.dart';
import '../../provider/providers/provider_workshop_provider.dart';
import '../models/subscription_model.dart';

/// Écran de gestion de l'abonnement réparateur TechSOS (Standard Pro)
class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  String _selectedPaymentMethod = 'ORANGE_MONEY'; // 'ORANGE_MONEY' ou 'MOOV_MONEY'
  final _phoneController = TextEditingController(text: '+223 ');
  final _formKey = GlobalKey<FormState>();

  bool _isProcessing = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handlePayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    var phone = _phoneController.text.trim();
    if (!phone.startsWith('+')) {
      phone = '+223$phone';
    }

    try {
      final result = await ref.read(providerWorkshopProvider).payMobileMoney(
            phone,
            _selectedPaymentMethod,
          );

      if (mounted) {
        setState(() {
          _isProcessing = false;
        });

        final txRef = result['transactionRef'] ?? 'TECHSOS-OK';
        _showSuccessDialog(txRef.toString());
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  void _showSuccessDialog(String transactionRef) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Color(0xFF2E8B57), size: 28),
            SizedBox(width: 10),
            Text(
              'Abonnement activé',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: TechSosColors.primary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Félicitations ! Votre forfait Standard Pro (5 000 FCFA / mois) est désormais actif pour 30 jours supplémentaires.',
              style: TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: TechSosColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Réf. transaction : $transactionRef',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: TechSosColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Fermer',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: TechSosColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subAsync = ref.watch(subscriptionProvider);

    return Scaffold(
      backgroundColor: TechSosColors.background,
      appBar: AppBar(
        title: const Text('Mon Abonnement'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(subscriptionProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Bannière du plan Standard Pro
              subAsync.when(
                data: (sub) => _buildPlanBanner(sub),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (_, __) => _buildPlanBanner(null),
              ),
              const SizedBox(height: 20),

              // Avantages débloqués
              _buildUnlockedFeatures(),
              const SizedBox(height: 24),

              // Section de paiement Mobile Money
              _buildPaymentSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanBanner(SubscriptionModel? sub) {
    final isActive = sub?.isActive ?? false;
    final isTrial = sub?.isTrialPeriod ?? true;
    final remainingDays = sub?.remainingDays ?? 30;

    final dateFormat = DateFormat('dd/MM/yyyy');
    final expiryText = sub?.endDate != null
        ? 'Expire le ${dateFormat.format(sub!.endDate!)} ($remainingDays jours restants)'
        : '$remainingDays jours restants';

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [TechSosColors.primary, Color(0xFF2C5282)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: TechSosColors.primary.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Standard Pro',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Badge statut
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF2E8B57)
                      : (isTrial
                          ? const Color(0xFFD9A441)
                          : const Color(0xFF595959)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isActive
                      ? 'Actif'
                      : (isTrial ? "Période d'essai" : 'Expiré'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '5 000 FCFA / mois',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: TechSosColors.accent,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.timer_outlined, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  expiryText,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUnlockedFeatures() {
    return Card(
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
            const Text(
              'Fonctionnalités débloquées',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: TechSosColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            _buildFeatureItem(
              Icons.book_rounded,
              'Journal d\'atelier illimité',
              'Enregistrez toutes vos entrées clients physiques & comptoir.',
            ),
            const Divider(height: 16),
            _buildFeatureItem(
              Icons.mark_chat_read_rounded,
              'Notifications WhatsApp automatiques',
              'Le client est notifié à l\'enregistrement et dès que l\'appareil est prêt.',
            ),
            const Divider(height: 16),
            _buildFeatureItem(
              Icons.bolt_rounded,
              'Fil prioritaire des pannes',
              'Recevez les alertes de pannes à Bamako avant les réparateurs non-abonnés.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF2E8B57).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.check, color: Color(0xFF2E8B57), size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: TechSosColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: TechSosColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: TechSosColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Renouveler mon abonnement',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: TechSosColors.primary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Paiement instantané et sécurisé via Mobile Money Malien',
                style: TextStyle(
                  fontSize: 14,
                  color: TechSosColors.textSecondary,
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
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Sélection Mobile Money
              const Text(
                'Moyen de paiement Mobile Money *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: TechSosColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildPaymentMethodCard(
                      'ORANGE_MONEY',
                      'Orange Money',
                      '🟠',
                      const Color(0xFFFF7900),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPaymentMethodCard(
                      'MOOV_MONEY',
                      'Moov Money',
                      '🔵',
                      const Color(0xFF0066B2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Numéro de téléphone pour prélèvement
              const Text(
                'Numéro de compte Mobile Money *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: TechSosColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: '+223 70 12 34 56',
                  prefixIcon: Icon(Icons.phone_iphone_rounded, color: TechSosColors.primary),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Veuillez saisir votre numéro de compte Mobile Money';
                  }
                  final clean = val.replaceAll(RegExp(r'\s+'), '');
                  if (!clean.startsWith('+223') && clean.length != 8) {
                    return 'Format attendu : +223XXXXXXXX ou 8 chiffres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Bouton Renouveler pour 5 000 FCFA
              TechSosButton(
                label: 'Renouveler pour 5 000 FCFA',
                icon: Icons.flash_on_rounded,
                isLoading: _isProcessing,
                onPressed: _handlePayment,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(
    String key,
    String label,
    String emoji,
    Color brandColor,
  ) {
    final isSelected = _selectedPaymentMethod == key;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unselectedBg = isDark ? TechSosColors.cardBackgroundDark : Colors.white;
    final unselectedBorder = isDark ? TechSosColors.borderDark : TechSosColors.border;
    final unselectedText = isDark ? TechSosColors.textPrimaryDark : TechSosColors.textPrimary;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = key;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? brandColor.withValues(alpha: isDark ? 0.2 : 0.1) : unselectedBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? brandColor : unselectedBorder,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? brandColor : unselectedText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

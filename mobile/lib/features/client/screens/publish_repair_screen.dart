import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/styles.dart';
import '../../../core/widgets/audio_recorder_widget.dart';
import '../../../core/widgets/techsos_button.dart';
import '../models/category_model.dart';
import '../providers/client_repairs_provider.dart';

/// Écran de publication de panne SOS avec saisie mixte Texte + Note Vocale proéminente
class PublishRepairScreen extends ConsumerStatefulWidget {
  final VoidCallback? onPublishedSuccess;

  const PublishRepairScreen({
    super.key,
    this.onPublishedSuccess,
  });

  @override
  ConsumerState<PublishRepairScreen> createState() => _PublishRepairScreenState();
}

class _PublishRepairScreenState extends ConsumerState<PublishRepairScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedCategoryId;
  String? _selectedCategoryName;
  String? _selectedIssueId;
  String? _selectedIssueName;
  bool _isCustomIssue = false;

  final TextEditingController _customIssueController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController(text: 'Hamdallaye ACI 2000, Bamako');

  String? _recordedAudioPath;

  final List<String> _bamakoZones = [
    'Hamdallaye ACI 2000, Bamako',
    'Badalabougou, Bamako',
    'Baco Djicoroni, Bamako',
    'Faladié, Bamako',
    'Lafiabougou, Bamako',
    'Torokorobougou, Bamako',
    'Daoudabougou, Bamako',
    'Sabalibougou, Bamako',
    'Yirimadio, Bamako',
    'Autre quartier...',
  ];

  @override
  void dispose() {
    _customIssueController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  IconData _getCategoryIcon(String? code) {
    switch (code?.toUpperCase()) {
      case 'SMARTPHONE':
        return Icons.phone_android_rounded;
      case 'COMPUTER':
        return Icons.laptop_mac_rounded;
      case 'PRINTER':
        return Icons.print_rounded;
      case 'TABLET':
        return Icons.tablet_android_rounded;
      case 'TV':
        return Icons.tv_rounded;
      default:
        return Icons.devices_other_rounded;
    }
  }

  Future<void> _submitSos() async {
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner la catégorie de votre appareil en panne.'),
          backgroundColor: TechSosColors.accent,
        ),
      );
      return;
    }

    final hasText = _descriptionController.text.trim().isNotEmpty;
    final hasAudio = _recordedAudioPath != null && _recordedAudioPath!.isNotEmpty;

    if (!hasText && !hasAudio) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez décrire la panne soit par écrit, soit par note vocale.'),
          backgroundColor: TechSosColors.accent,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final issueTitle = _isCustomIssue
        ? _customIssueController.text.trim()
        : _selectedIssueName;

    // Si le client n'a renseigné qu'une note vocale, générer un texte descriptif par défaut
    final effectiveDescription = hasText
        ? _descriptionController.text.trim()
        : 'Panne détaillée par message vocal (voir note audio jointe).';

    final result = await ref.read(clientRepairsProvider.notifier).createRepair(
          categoryId: _selectedCategoryId!,
          categoryName: _selectedCategoryName,
          issueTypeId: _isCustomIssue ? null : _selectedIssueId,
          issueTypeName: _isCustomIssue ? null : _selectedIssueName,
          customIssueTitle: _isCustomIssue ? issueTitle : null,
          descriptionText: effectiveDescription,
          voiceAudioPath: _recordedAudioPath,
          locationAddress: _locationController.text.trim(),
        );

    if (!mounted) return;

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text('Votre demande SOS a été envoyée aux réparateurs de Bamako !'),
              ),
            ],
          ),
          backgroundColor: TechSosColors.success,
          duration: Duration(seconds: 3),
        ),
      );

      // Redirection vers "Mes Annonces"
      widget.onPublishedSuccess?.call();
    } else {
      final error = ref.read(clientRepairsProvider).errorMessage ?? 'Une erreur est survenue.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final repairsState = ref.watch(clientRepairsProvider);

    return Scaffold(
      backgroundColor: TechSosColors.background,
      appBar: AppBar(
        title: const Text(
          'Publier un SOS Dépannage',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: TechSosColors.primary,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Sélection de la catégorie d'appareil
              const Text(
                '1. Sélectionnez votre appareil *',
                style: TechSosStyles.headingMedium,
              ),
              const SizedBox(height: 4),
              const Text(
                'Quel type d\'équipement a besoin d\'une réparation ?',
                style: TextStyle(fontSize: 14, color: TechSosColors.textSecondary),
              ),
              const SizedBox(height: 12),

              categoriesAsync.when(
                data: (categories) => _buildCategorySelector(categories),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (_, __) => const Text('Erreur de chargement des catégories'),
              ),
              const SizedBox(height: 24),

              // 2. Sélection du type de panne
              if (_selectedCategoryId != null) ...[
                const Text(
                  '2. Type de problème / Panne',
                  style: TechSosStyles.headingMedium,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Choisissez le symptôme le plus proche ou précisez "Autre panne"',
                  style: TextStyle(fontSize: 14, color: TechSosColors.textSecondary),
                ),
                const SizedBox(height: 12),
                categoriesAsync.when(
                  data: (categories) {
                    final currentCat = categories.firstWhere(
                      (c) => c.id == _selectedCategoryId,
                      orElse: () => categories.first,
                    );
                    return _buildIssueSelector(currentCat);
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 24),
              ],

              // 3. Zone mixte : Description Texte + Enregistrement Vocal au même niveau
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: TechSosColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: TechSosColors.accent.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.record_voice_over_rounded,
                            color: TechSosColors.accent,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            '3. Décrivez la panne (Texte ou Voix) *',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: TechSosColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Vous pouvez écrire ou simplement laisser une note vocale pour les réparateurs.',
                      style: TextStyle(
                        fontSize: 14,
                        color: TechSosColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Champ texte descriptif
                    TextFormField(
                      controller: _descriptionController,
                      minLines: 3,
                      maxLines: 5,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Ex: L\'appareil est tombé dans l\'eau, l\'écran s\'allume brièvement puis devient noir...',
                        hintStyle: const TextStyle(fontSize: 14, color: Colors.black38),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: TechSosColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: TechSosColors.primary, width: 1.5),
                        ),
                        filled: true,
                        fillColor: TechSosColors.background,
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Séparateur visuel indiquant l'alternative égale
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            'OU ENREGISTREMENT VOCAL',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: TechSosColors.textSecondary,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Widget proéminent d'enregistrement audio avec sauvegarde locale
                    AudioRecorderWidget(
                      key: const ValueKey('publish_audio_recorder'),
                      initialAudioPath: _recordedAudioPath,
                      onAudioRecorded: (path) {
                        setState(() {
                          _recordedAudioPath = path;
                        });
                      },
                      onAudioRemoved: () {
                        setState(() {
                          _recordedAudioPath = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 4. Quartier / Adresse à Bamako
              const Text(
                '4. Localisation à Bamako',
                style: TechSosStyles.headingMedium,
              ),
              const SizedBox(height: 4),
              const Text(
                'Indiquez votre quartier pour que les réparateurs proches puissent vous répondre',
                style: TextStyle(fontSize: 14, color: TechSosColors.textSecondary),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: TechSosColors.border),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonFormField<String>(
                  initialValue: _locationController.text,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    icon: Icon(Icons.location_on_rounded, color: TechSosColors.accent),
                  ),
                  style: const TextStyle(fontSize: 14, color: TechSosColors.textPrimary),
                  isExpanded: true,
                  items: _bamakoZones.map((zone) {
                    return DropdownMenuItem(
                      value: zone,
                      child: Text(zone, style: const TextStyle(fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _locationController.text = val;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 32),

              // 5. Bouton d'action proéminent Orange technique : "Lancer mon SOS"
              TechSosButton(
                key: const ValueKey('submit_sos_button'),
                label: 'Lancer mon SOS',
                icon: Icons.bolt_rounded,
                isLoading: repairsState.isSubmitting,
                onPressed: _submitSos,
              ),
              const SizedBox(height: 16),
              const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield_outlined, size: 16, color: TechSosColors.success),
                    SizedBox(width: 6),
                    Text(
                      'Gratuit et sans engagement - Devis directs',
                      style: TextStyle(
                        fontSize: 14,
                        color: TechSosColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Sélecteur de catégorie d'appareils avec icônes
  Widget _buildCategorySelector(List<CategoryModel> categories) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          final isSelected = _selectedCategoryId == cat.id;
          return Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: InkWell(
              key: ValueKey('category_tile_${cat.id}'),
              onTap: () {
                setState(() {
                  _selectedCategoryId = cat.id;
                  _selectedCategoryName = cat.name;
                  _selectedIssueId = null;
                  _selectedIssueName = null;
                  _isCustomIssue = false;
                });
              },
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 110,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                decoration: BoxDecoration(
                  color: isSelected ? TechSosColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? TechSosColors.primary : TechSosColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: TechSosColors.primary.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getCategoryIcon(cat.code),
                      color: isSelected ? Colors.white : TechSosColors.primary,
                      size: 30,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cat.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.white : TechSosColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Sélecteur de type de panne (chips avec option "Autre panne...")
  Widget _buildIssueSelector(CategoryModel category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...category.issueTypes.map((issue) {
              final isSelected = !_isCustomIssue && _selectedIssueId == issue.id;
              return ChoiceChip(
                key: ValueKey('issue_chip_${issue.id}'),
                label: Text(
                  issue.name,
                  style: TextStyle(
                    fontSize: 14,
                    color: isSelected ? Colors.white : TechSosColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                selectedColor: TechSosColors.accent,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(
                    color: isSelected ? TechSosColors.accent : TechSosColors.border,
                  ),
                ),
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedIssueId = issue.id;
                      _selectedIssueName = issue.name;
                      _isCustomIssue = false;
                    });
                  }
                },
              );
            }),
            ChoiceChip(
              key: const ValueKey('issue_chip_other'),
              label: Text(
                'Autre panne...',
                style: TextStyle(
                  fontSize: 14,
                  color: _isCustomIssue ? Colors.white : TechSosColors.textPrimary,
                  fontWeight: _isCustomIssue ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              selected: _isCustomIssue,
              selectedColor: TechSosColors.accent,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(
                  color: _isCustomIssue ? TechSosColors.accent : TechSosColors.border,
                ),
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _isCustomIssue = true;
                    _selectedIssueId = null;
                    _selectedIssueName = null;
                  });
                }
              },
            ),
          ],
        ),
        if (_isCustomIssue) ...[
          const SizedBox(height: 12),
          TextFormField(
            key: const ValueKey('custom_issue_input'),
            controller: _customIssueController,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              labelText: 'Précisez votre panne *',
              hintText: 'Ex: Charnière cassée, surchauffe...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (val) {
              if (_isCustomIssue && (val == null || val.trim().isEmpty)) {
                return 'Veuillez préciser le titre de la panne';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }
}

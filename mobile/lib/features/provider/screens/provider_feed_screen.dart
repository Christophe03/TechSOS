import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/styles.dart';
import '../../../core/widgets/techsos_button.dart';
import '../../../core/widgets/techsos_logo.dart';
import '../../client/models/repair_model.dart';
import '../providers/provider_workshop_provider.dart';
import 'submit_offer_dialog.dart';

/// Fil d'actualité des pannes électroniques publiées à Bamako
class ProviderFeedScreen extends ConsumerStatefulWidget {
  const ProviderFeedScreen({super.key});

  @override
  ConsumerState<ProviderFeedScreen> createState() => _ProviderFeedScreenState();
}

class _ProviderFeedScreenState extends ConsumerState<ProviderFeedScreen> {
  String _selectedCategory = 'TOUS';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  final List<Map<String, String>> _categories = [
    {'code': 'TOUS', 'label': 'Tous'},
    {'code': 'SMARTPHONE', 'label': 'Smartphones'},
    {'code': 'COMPUTER', 'label': 'Ordinateurs'},
    {'code': 'TV', 'label': 'TV & Écrans'},
    {'code': 'TABLET', 'label': 'Tablettes'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedAsync = ref.watch(providerFeedProvider);

    return Scaffold(
      backgroundColor: TechSosColors.background,
      appBar: AppBar(
        title: const TechSosLogoHorizontal(
          height: 38,
          variant: TechSosLogoVariant.white,
          showSubtitle: false,
        ),
        titleSpacing: 0,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
          // Barre de recherche et filtres de catégorie
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  style: const TextStyle(fontSize: 14),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim().toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Rechercher une panne ou un modèle...',
                    prefixIcon: const Icon(Icons.search_rounded, color: TechSosColors.primary),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategory == cat['code'];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(
                            cat['label']!,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? Colors.white : TechSosColors.textPrimary,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: TechSosColors.primary,
                          backgroundColor: TechSosColors.background,
                          checkmarkColor: Colors.white,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = cat['code']!;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Liste des pannes
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(providerFeedProvider);
              },
              child: feedAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey),
                        const SizedBox(height: 12),
                        const Text(
                          'Erreur de chargement du fil',
                          style: TechSosStyles.headingMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14, color: TechSosColors.textSecondary),
                        ),
                        const SizedBox(height: 16),
                        TechSosButton(
                          label: 'Réessayer',
                          onPressed: () => ref.invalidate(providerFeedProvider),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (repairs) {
                  // Filtrage
                  final filtered = repairs.where((r) {
                    final matchesQuery = _searchQuery.isEmpty ||
                        r.displayTitle.toLowerCase().contains(_searchQuery) ||
                        r.descriptionText.toLowerCase().contains(_searchQuery) ||
                        (r.locationAddress?.toLowerCase().contains(_searchQuery) ?? false);

                    if (!matchesQuery) return false;

                    if (_selectedCategory == 'TOUS') return true;
                    final catCode = r.categoryName?.toUpperCase() ?? '';
                    final catId = r.categoryId.toUpperCase();
                    if (_selectedCategory == 'SMARTPHONE') {
                      return catCode.contains('PHONE') || catId.contains('PHONE');
                    }
                    if (_selectedCategory == 'COMPUTER') {
                      return catCode.contains('COMP') || catCode.contains('ORDI') || catId.contains('COMP');
                    }
                    if (_selectedCategory == 'TV') {
                      return catCode.contains('TV') || catId.contains('TV');
                    }
                    if (_selectedCategory == 'TABLET') {
                      return catCode.contains('TAB') || catId.contains('TAB');
                    }
                    return true;
                  }).toList();

                  if (filtered.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 80),
                        Center(
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
                                  Icons.build_circle_outlined,
                                  size: 48,
                                  color: TechSosColors.primary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Aucune panne trouvée',
                                style: TechSosStyles.headingMedium,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Les nouvelles demandes de clients à Bamako apparaîtront ici.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
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

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final repair = filtered[index];
                      return _ProviderFeedCard(
                        repair: repair,
                        onOfferSubmitted: () {
                          ref.invalidate(providerFeedProvider);
                        },
                      );
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
}

/// Carte d'une panne dans le fil d'actualité réparateur
class _ProviderFeedCard extends StatelessWidget {
  final RepairModel repair;
  final VoidCallback onOfferSubmitted;

  const _ProviderFeedCard({
    required this.repair,
    required this.onOfferSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy à HH:mm');
    final formattedDate = dateFormat.format(repair.createdAt);

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
            // Ligne du haut : Tag catégorie & Localisation
            Row(
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: TechSosColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      repair.categoryName ?? 'Électronique',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: TechSosColors.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: TechSosColors.accent,
                    ),
                    const SizedBox(width: 4),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 140),
                      child: Text(
                        repair.locationAddress ?? 'Bamako',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: TechSosColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Titre de la panne
            Text(
              repair.displayTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: TechSosColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),

            // Extrait de description
            Text(
              repair.descriptionText,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                color: TechSosColors.textPrimary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),

            // Note vocale si présente
            if (repair.voiceAudioUrl != null && repair.voiceAudioUrl!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: TechSosColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: TechSosColors.primary.withValues(alpha: 0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.mic, color: TechSosColors.primary, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Message vocal du client inclus',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: TechSosColors.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.play_circle_fill_rounded, color: TechSosColors.primary, size: 24),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],

            // Photos si présentes
            if (repair.photoUrls.isNotEmpty) ...[
              Row(
                children: [
                  const Icon(Icons.photo_library_outlined, size: 16, color: TechSosColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    '${repair.photoUrls.length} photo(s) jointe(s)',
                    style: const TextStyle(fontSize: 14, color: TechSosColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],

            // Date et nombre d'offres
            Row(
              children: [
                const Icon(Icons.access_time_rounded, size: 16, color: TechSosColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 14,
                    color: TechSosColors.textSecondary,
                  ),
                ),
                const Spacer(),
                if (repair.offersCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: TechSosColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${repair.offersCount} offre(s)',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: TechSosColors.accent,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),

            // Bouton Faire une offre
            TechSosButton(
              label: 'Faire une offre',
              icon: Icons.local_offer_outlined,
              onPressed: () async {
                final result = await SubmitOfferDialog.show(context, repair);
                if (result == true) {
                  onOfferSubmitted();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

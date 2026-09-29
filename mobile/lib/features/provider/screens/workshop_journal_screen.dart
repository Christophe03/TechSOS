import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/styles.dart';
import '../models/workshop_entry_model.dart';
import '../providers/provider_workshop_provider.dart';
import 'quick_client_entry_dialog.dart';

/// Journal de bord de l'atelier de réparation (Back-Office)
class WorkshopJournalScreen extends ConsumerStatefulWidget {
  const WorkshopJournalScreen({super.key});

  @override
  ConsumerState<WorkshopJournalScreen> createState() =>
      _WorkshopJournalScreenState();
}

class _WorkshopJournalScreenState extends ConsumerState<WorkshopJournalScreen> {
  String _selectedTab = 'TOUS'; // 'TOUS', 'DEPOSITED', 'IN_PROGRESS', 'READY', 'DELIVERED'

  final List<Map<String, String>> _tabs = [
    {'key': 'TOUS', 'label': 'Tous'},
    {'key': 'DEPOSITED', 'label': 'Déposé'},
    {'key': 'IN_PROGRESS', 'label': 'En cours'},
    {'key': 'READY', 'label': 'Prêt'},
    {'key': 'DELIVERED', 'label': 'Livré'},
  ];

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(workshopEntriesProvider);

    return Scaffold(
      backgroundColor: TechSosColors.background,
      appBar: AppBar(
        title: const Text('Journal d\'atelier'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualiser',
            onPressed: () {
              ref.invalidate(workshopEntriesProvider);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: TechSosColors.accent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Nouveau client',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        onPressed: () async {
          final result = await QuickClientEntryDialog.show(context);
          if (result != null) {
            ref.invalidate(workshopEntriesProvider);
          }
        },
      ),
      body: Column(
        children: [
          // En-tête statistique
          entriesAsync.when(
            data: (entries) => _buildStatsHeader(entries),
            loading: () => _buildStatsHeader([]),
            error: (_, __) => _buildStatsHeader([]),
          ),

          // Onglets de filtre
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _tabs.map((tab) {
                  final isSelected = _selectedTab == tab['key'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(
                        tab['label']!,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : TechSosColors.textPrimary,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: TechSosColors.primary,
                      backgroundColor: TechSosColors.background,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedTab = tab['key']!;
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Liste des tickets d'atelier
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(workshopEntriesProvider);
              },
              child: entriesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
                        const SizedBox(height: 12),
                        const Text(
                          'Erreur de chargement de l\'atelier',
                          style: TechSosStyles.headingMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14, color: TechSosColors.textSecondary),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => ref.invalidate(workshopEntriesProvider),
                          child: const Text('Réessayer', style: TextStyle(fontSize: 14)),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (entries) {
                  final filtered = entries.where((e) {
                    if (_selectedTab == 'TOUS') return true;
                    if (_selectedTab == 'DEPOSITED') return e.isDeposited;
                    if (_selectedTab == 'IN_PROGRESS') {
                      return e.isDiagnostic || e.isInRepair;
                    }
                    if (_selectedTab == 'READY') return e.isReadyForPickup;
                    if (_selectedTab == 'DELIVERED') return e.isDelivered;
                    return true;
                  }).toList();

                  if (filtered.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 70),
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
                                  Icons.handyman_outlined,
                                  size: 48,
                                  color: TechSosColors.primary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Aucun appareil dans cette catégorie',
                                style: TechSosStyles.headingMedium,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Appuyez sur "Nouveau client" pour enregistrer un appareil.',
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
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 80),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final entry = filtered[index];
                      return _WorkshopTicketCard(
                        entry: entry,
                        onStatusChanged: () {
                          ref.invalidate(workshopEntriesProvider);
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
    );
  }

  Widget _buildStatsHeader(List<WorkshopEntryModel> entries) {
    final total = entries.length;
    final ready = entries.where((e) => e.isReadyForPickup).length;
    final inProgress = entries.where((e) => e.isDiagnostic || e.isInRepair).length;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          _buildStatCard(
            'Total appareils',
            '$total',
            TechSosColors.primary,
            Icons.devices_other_rounded,
          ),
          const SizedBox(width: 10),
          _buildStatCard(
            'En cours',
            '$inProgress',
            TechSosColors.accent,
            Icons.build_rounded,
          ),
          const SizedBox(width: 10),
          _buildStatCard(
            'Prêt à récupérer',
            '$ready',
            const Color(0xFF2E8B57),
            Icons.check_circle_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String count, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              count,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: TechSosColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Carte de fiche d'atelier pour un ticket
class _WorkshopTicketCard extends ConsumerWidget {
  final WorkshopEntryModel entry;
  final VoidCallback onStatusChanged;

  const _WorkshopTicketCard({
    required this.entry,
    required this.onStatusChanged,
  });

  void _showChangeStatusDialog(BuildContext context, WidgetRef ref) {
    final statuses = [
      {'key': 'DEPOSITED', 'label': 'Déposé', 'color': const Color(0xFFD9A441)},
      {'key': 'DIAGNOSTIC', 'label': 'Diagnostic', 'color': const Color(0xFF1F3A5F)},
      {'key': 'IN_REPAIR', 'label': 'En réparation', 'color': const Color(0xFFE8641C)},
      {'key': 'READY_FOR_PICKUP', 'label': 'Prêt à récupérer', 'color': const Color(0xFF2E8B57)},
      {'key': 'DELIVERED', 'label': 'Appareil rendu', 'color': const Color(0xFF595959)},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Modifier le statut de réparation',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: TechSosColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                ...statuses.map((s) {
                  final isCurrent = entry.status == s['key'];
                  final isReady = s['key'] == 'READY_FOR_PICKUP';
                  return ListTile(
                    leading: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: s['color'] as Color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    title: Text(
                      s['label'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                    subtitle: isReady
                        ? const Text(
                            '📱 Notifiera automatiquement le client sur WhatsApp',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF2E8B57),
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        : null,
                    trailing: isCurrent
                        ? const Icon(Icons.check, color: TechSosColors.primary)
                        : null,
                    onTap: () async {
                      Navigator.of(ctx).pop();
                      try {
                        await ref
                            .read(providerWorkshopProvider)
                            .updateEntryStatus(entry.id, s['key'] as String);
                        onStatusChanged();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Statut mis à jour : ${s['label']}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              backgroundColor: TechSosColors.success,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Erreur : $e',
                                style: const TextStyle(fontSize: 14),
                              ),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      }
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('dd/MM/yyyy à HH:mm');
    final formattedDate = dateFormat.format(entry.createdAt);

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
            // Ligne supérieure : Statut badge + Origine
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusBadge(entry),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: entry.isWalkIn
                        ? TechSosColors.primary.withValues(alpha: 0.1)
                        : TechSosColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    entry.isWalkIn ? 'Comptoir / Atelier' : 'Demande Appli',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: entry.isWalkIn
                          ? TechSosColors.primary
                          : TechSosColors.accent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Appareil & Client
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: TechSosColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.devices_other_rounded,
                    color: TechSosColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.deviceModel,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: TechSosColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${entry.clientName} • ${entry.clientPhone}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: TechSosColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Panne / Problème
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: TechSosColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                entry.issueSummary,
                style: const TextStyle(
                  fontSize: 14,
                  color: TechSosColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Prix convenu & Date
            Row(
              children: [
                const Icon(Icons.payments_outlined, size: 16, color: TechSosColors.primary),
                const SizedBox(width: 4),
                Text(
                  entry.priceCfa != null ? '${entry.priceCfa} FCFA' : 'Prix non fixé',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: TechSosColors.primary,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.access_time_rounded, size: 14, color: TechSosColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 14,
                    color: TechSosColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Alerte WhatsApp
            if (entry.whatsappNotifiedAt != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E8B57).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Text('📱', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'WhatsApp envoyé le ${dateFormat.format(entry.whatsappNotifiedAt!)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2E8B57),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Bouton Action changement de statut
            OutlinedButton.icon(
              onPressed: () => _showChangeStatusDialog(context, ref),
              icon: const Icon(Icons.edit_note_rounded, size: 18),
              label: Text(
                'Changer le statut (${entry.statusLabel})',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: TechSosColors.primary,
                side: const BorderSide(color: TechSosColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(WorkshopEntryModel entry) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: entry.statusColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: entry.statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            entry.statusLabel,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: entry.statusColor,
            ),
          ),
        ],
      ),
    );
  }
}

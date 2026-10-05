import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../models/medicine.dart';
import '../providers/medicine_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/status_chip.dart';
import '../widgets/empty_state.dart';

class RefillAlertsScreen extends StatelessWidget {
  const RefillAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicineProvider>(context);
    final medicines = provider.medicines;

    // Group into Out of Stock, Low Stock, Sufficient
    final outOfStock = provider.outOfStockMedicines;
    final lowStock = provider.lowStockMedicines.where((m) => m.stock > 0).toList();
    final sufficient = medicines.where((m) => m.stock > m.refillThreshold).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'My Pillbox & Refills',
          style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: medicines.isEmpty
          ? const EmptyState(
              imagePath: 'assets/images/empty_state.jpg',
              title: 'Pillbox is Empty',
              description: 'Add your medicines to automatically monitor remaining pills and get timely refill reminders.',
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(LucideIcons.pill, color: AppColors.primary, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Personal Supply Tracker',
                                style: GoogleFonts.sora(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Days remaining calculated automatically from your daily intake schedule',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 1. Out of Stock Section
                  if (outOfStock.isNotEmpty) ...[
                    _buildSectionTitle('EMPTY PILLBOX (REFILL NOW)', AppColors.statusMissed),
                    const SizedBox(height: 10),
                    ...outOfStock.map((m) => _buildRefillCard(context, provider, m, RefillState.outOfStock)),
                    const SizedBox(height: 20),
                  ],

                  // 2. Low Stock Section
                  if (lowStock.isNotEmpty) ...[
                    _buildSectionTitle('REFILL NEEDED SOON', AppColors.statusUpcoming),
                    const SizedBox(height: 10),
                    ...lowStock.map((m) => _buildRefillCard(context, provider, m, RefillState.lowStock)),
                    const SizedBox(height: 20),
                  ],

                  // 3. Sufficient Supply Section
                  if (sufficient.isNotEmpty) ...[
                    _buildSectionTitle('WELL SUPPLIED', AppColors.primary),
                    const SizedBox(height: 10),
                    ...sufficient.map((m) => _buildRefillCard(context, provider, m, RefillState.sufficient)),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildRefillCard(
    BuildContext context,
    MedicineProvider provider,
    Medicine med,
    RefillState state,
  ) {
    final daysRemaining = provider.daysOfStockRemaining(med);

    StatusChip chip;
    switch (state) {
      case RefillState.outOfStock:
        chip = const StatusChip(
          label: 'Out of Pills',
          backgroundColor: AppColors.refillOutBg,
          textColor: AppColors.refillOut,
          icon: LucideIcons.alertCircle,
        );
        break;
      case RefillState.lowStock:
        chip = StatusChip(
          label: '~ $daysRemaining days left',
          backgroundColor: AppColors.refillLowBg,
          textColor: AppColors.refillLow,
          icon: LucideIcons.alertTriangle,
        );
        break;
      case RefillState.sufficient:
        chip = StatusChip(
          label: '~ $daysRemaining days left',
          backgroundColor: AppColors.refillSufficientBg,
          textColor: AppColors.refillSufficient,
          icon: LucideIcons.checkCircle2,
        );
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider, width: 0.8),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(LucideIcons.pill, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      med.name,
                      style: GoogleFonts.sora(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Pills left: ${med.stock} (Refill alert at: ${med.refillThreshold})',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              chip,
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bought a new pack?',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textTertiary),
              ),
              ElevatedButton.icon(
                onPressed: () => _showRestockDialog(context, provider, med),
                icon: const Icon(LucideIcons.plus, size: 16),
                label: const Text('Add Pills to Box'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showRestockDialog(BuildContext context, MedicineProvider provider, Medicine med) {
    final controller = TextEditingController(text: '30');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Refill ${med.name}',
          style: GoogleFonts.sora(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add pills to your pillbox (currently ${med.stock} pills remaining):',
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'e.g. 30',
                labelText: 'Number of pills bought',
                prefixIcon: const Icon(LucideIcons.pill, size: 18, color: AppColors.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final amt = int.tryParse(controller.text.trim()) ?? 0;
              if (amt > 0) {
                await provider.refillStock(med.id, amt);
              }
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Add Pills'),
          ),
        ],
      ),
    );
  }
}

enum RefillState { outOfStock, lowStock, sufficient }

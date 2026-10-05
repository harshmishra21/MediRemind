import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../providers/medicine_provider.dart';
import '../models/medicine.dart';
import '../theme/app_colors.dart';
import '../utils/date_time_helpers.dart';
import 'add_edit_medicine_screen.dart';

class MedicineDetailScreen extends StatelessWidget {
  final String medicineId;

  const MedicineDetailScreen({super.key, required this.medicineId});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicineProvider>(context);
    final med = provider.getMedicineById(medicineId);
    final schedule = provider.getScheduleForMedicine(medicineId);

    if (med == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Medicine Details')),
        body: const Center(child: Text('Medicine not found')),
      );
    }

    final daysRemaining = provider.daysOfStockRemaining(med);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          med.name,
          style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddEditMedicineScreen(medicine: med),
                ),
              );
            },
            icon: const Icon(LucideIcons.pencil, color: AppColors.primary),
          ),
          IconButton(
            onPressed: () => _confirmDelete(context, provider, med),
            icon: const Icon(LucideIcons.trash2, color: AppColors.statusMissed),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Top Overview Hero Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.divider),
                boxShadow: AppColors.cardShadow,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          LucideIcons.pill,
                          color: AppColors.primary,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              med.name,
                              style: GoogleFonts.sora(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '${med.strengthLabel} • ${med.type}',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn('Current Stock', '${med.stock} units'),
                      Container(width: 1, height: 36, color: AppColors.divider),
                      _buildStatColumn('Days Supply', '~ $daysRemaining days'),
                      Container(width: 1, height: 36, color: AppColors.divider),
                      _buildStatColumn('Refill Alert', '${med.refillThreshold} left'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Refill Action Banner
            if (med.stock <= med.refillThreshold) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.alertTriangle, color: AppColors.accent, size: 24),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Low Stock Warning',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accentDark,
                            ),
                          ),
                          Text(
                            med.stock == 0
                                ? 'Medicine is completely out of stock!'
                                : 'Only ${med.stock} units left in your medicine cabinet.',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.accentDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _showRefillDialog(context, provider, med),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                      child: const Text('Refill Now'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // 2. Dosage Schedule Summary Card
            Text(
              'DOSAGE SCHEDULE',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textTertiary,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.divider),
              ),
              child: schedule == null
                  ? const Text('No schedule configured.')
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(
                          LucideIcons.clock,
                          'Intake Times',
                          schedule.times.map((t) => DateTimeHelpers.formatTimeString(t)).join(', '),
                        ),
                        const Divider(height: 20),
                        _buildInfoRow(
                          LucideIcons.calendar,
                          'Active Days',
                          DateTimeHelpers.formatDaysOfWeek(schedule.daysOfWeek),
                        ),
                        const Divider(height: 20),
                        _buildInfoRow(
                          LucideIcons.calendarRange,
                          'Duration',
                          '${DateTimeHelpers.formatDate(schedule.startDate)} – ${DateTimeHelpers.formatDate(schedule.endDate)}',
                        ),
                        const Divider(height: 20),
                        _buildInfoRow(
                          LucideIcons.hash,
                          'Dose Quantity',
                          '${schedule.dosesPerIntake} ${med.type.toLowerCase()} per intake',
                        ),
                        if (schedule.instructions != null && schedule.instructions!.isNotEmpty) ...[
                          const Divider(height: 20),
                          _buildInfoRow(
                            LucideIcons.info,
                            'Instructions',
                            schedule.instructions!,
                          ),
                        ],
                      ],
                    ),
            ),
            const SizedBox(height: 24),

            // Refill & Edit Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showRefillDialog(context, provider, med),
                    icon: const Icon(LucideIcons.rotateCcw, size: 18),
                    label: const Text('Restock / Refill'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.sora(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textTertiary),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showRefillDialog(BuildContext context, MedicineProvider provider, Medicine med) {
    final controller = TextEditingController(text: '30');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Refill ${med.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter quantity of doses added to stock:',
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'e.g. 30',
                prefixIcon: Icon(LucideIcons.plusCircle, size: 18),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amt = int.tryParse(controller.text.trim()) ?? 0;
              if (amt > 0) {
                await provider.refillStock(med.id, amt);
              }
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Confirm Refill'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, MedicineProvider provider, Medicine med) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete ${med.name}?'),
        content: Text(
          'This will remove ${med.name} and cancel its active notifications.',
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await provider.deleteMedicine(med.id);
              if (ctx.mounted) {
                Navigator.of(ctx).pop();
                if (context.mounted) Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusMissed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

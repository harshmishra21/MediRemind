import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../models/medicine.dart';
import '../models/dosage_schedule.dart';
import '../theme/app_colors.dart';
import '../utils/date_time_helpers.dart';
import 'status_chip.dart';

class MedicineCard extends StatelessWidget {
  final Medicine medicine;
  final DosageSchedule? schedule;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MedicineCard({
    super.key,
    required this.medicine,
    this.schedule,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'capsule':
        return LucideIcons.pill;
      case 'syrup':
      case 'drops':
        return LucideIcons.droplet;
      case 'injection':
        return LucideIcons.syringe;
      case 'topical':
        return LucideIcons.sparkles;
      default:
        return LucideIcons.pill;
    }
  }

  Widget _buildRefillBadge() {
    if (medicine.stock == 0) {
      return const StatusChip(
        label: 'Out of Pills',
        backgroundColor: AppColors.refillOutBg,
        textColor: AppColors.refillOut,
        icon: LucideIcons.alertCircle,
      );
    } else if (medicine.stock <= medicine.refillThreshold) {
      return StatusChip(
        label: '${medicine.stock} pills left',
        backgroundColor: AppColors.refillLowBg,
        textColor: AppColors.refillLow,
        icon: LucideIcons.alertTriangle,
      );
    } else {
      return StatusChip(
        label: '${medicine.stock} pills',
        backgroundColor: AppColors.refillSufficientBg,
        textColor: AppColors.refillSufficient,
        icon: LucideIcons.checkCircle2,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final timesText = schedule != null && schedule!.times.isNotEmpty
        ? schedule!.times.map((t) => DateTimeHelpers.formatTimeString(t)).join(', ')
        : 'No schedule';

    final daysText = schedule != null
        ? DateTimeHelpers.formatDaysOfWeek(schedule!.daysOfWeek)
        : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Slidable(
        key: ValueKey(medicine.id),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.45,
          children: [
            SlidableAction(
              onPressed: (_) => onEdit(),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: LucideIcons.pencil,
              label: 'Edit',
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
            ),
            SlidableAction(
              onPressed: (_) => onDelete(),
              backgroundColor: AppColors.statusMissed,
              foregroundColor: Colors.white,
              icon: LucideIcons.trash2,
              label: 'Delete',
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(14)),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider, width: 0.8),
              boxShadow: AppColors.cardShadow,
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getTypeIcon(medicine.type),
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              medicine.name,
                              style: GoogleFonts.sora(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildRefillBadge(),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${medicine.strengthLabel} • ${medicine.type}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            LucideIcons.clock,
                            size: 13,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '$timesText ($daysText)',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.textTertiary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  LucideIcons.chevronRight,
                  color: AppColors.textTertiary,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

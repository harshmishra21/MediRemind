import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/medicine_provider.dart';
import '../models/dose_log.dart';
import '../services/notification_service.dart';
import '../theme/app_colors.dart';
import '../utils/date_time_helpers.dart';

class ReminderDialog extends StatefulWidget {
  final TodayDoseItem doseItem;

  const ReminderDialog({super.key, required this.doseItem});

  static Future<void> show(BuildContext context, TodayDoseItem doseItem) async {
    return showDialog(
      context: context,
      builder: (context) => ReminderDialog(doseItem: doseItem),
    );
  }

  @override
  State<ReminderDialog> createState() => _ReminderDialogState();
}

class _ReminderDialogState extends State<ReminderDialog> {
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.doseItem.log.notes != null) {
      _notesController.text = widget.doseItem.log.notes!;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final med = widget.doseItem.medicine;
    final schedule = widget.doseItem.schedule;
    final formattedTime = DateTimeHelpers.formatTimeString(widget.doseItem.timeStr);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.pill,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Medication Reminder',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          med.name,
                          style: GoogleFonts.sora(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(LucideIcons.x, size: 20, color: AppColors.textTertiary),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Dose Details Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(LucideIcons.clock, 'Scheduled Time', formattedTime),
                    const Divider(height: 16),
                    _buildDetailRow(
                      LucideIcons.activity,
                      'Dosage Strength',
                      '${med.strengthLabel} (${schedule.dosesPerIntake} ${med.type.toLowerCase()})',
                    ),
                    if (schedule.instructions != null && schedule.instructions!.isNotEmpty) ...[
                      const Divider(height: 16),
                      _buildDetailRow(
                        LucideIcons.info,
                        'Instructions',
                        schedule.instructions!,
                      ),
                    ],
                    const Divider(height: 16),
                    _buildDetailRow(
                      LucideIcons.box,
                      'Pills Remaining',
                      '${med.stock} pills remaining',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Optional Note Input
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  hintText: 'Add note (e.g. taken with glass of juice)',
                  prefixIcon: Icon(LucideIcons.stickyNote, size: 18),
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final provider = Provider.of<MedicineProvider>(context, listen: false);
                        await provider.markDoseStatus(
                          doseItem: widget.doseItem,
                          newStatus: DoseStatus.taken,
                          notes: _notesController.text.trim(),
                        );
                        if (context.mounted) Navigator.of(context).pop();
                      },
                      icon: const Icon(LucideIcons.check, size: 18),
                      label: const Text('Mark as Taken'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final provider = Provider.of<MedicineProvider>(context, listen: false);
                            await provider.markDoseStatus(
                              doseItem: widget.doseItem,
                              newStatus: DoseStatus.skipped,
                              notes: _notesController.text.trim(),
                            );
                            if (context.mounted) Navigator.of(context).pop();
                          },
                          icon: const Icon(LucideIcons.xCircle, size: 16),
                          label: const Text('Skip Dose'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            side: const BorderSide(color: AppColors.divider),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await NotificationService().showInstantNotification(
                              title: 'Snoozed: ${med.name}',
                              body: 'Reminder snoozed for 15 minutes.',
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Reminder snoozed for 15 minutes'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              Navigator.of(context).pop();
                            }
                          },
                          icon: const Icon(LucideIcons.bellRing, size: 16),
                          label: const Text('Snooze 15m'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.accent,
                            side: const BorderSide(color: AppColors.accent),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 5,
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

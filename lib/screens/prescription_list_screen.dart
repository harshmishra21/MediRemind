import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../models/prescription.dart';
import '../providers/report_provider.dart';
import '../theme/app_colors.dart';
import '../utils/date_time_helpers.dart';
import '../widgets/empty_state.dart';
import 'prescription_scan_screen.dart';

class PrescriptionListScreen extends StatelessWidget {
  const PrescriptionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ReportProvider>(context);
    final items = provider.prescriptions;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Prescriptions',
          style: GoogleFonts.sora(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PrescriptionScanScreen(),
                ),
              );
            },
            icon: const Icon(LucideIcons.plus, color: AppColors.primary),
          ),
        ],
      ),
      body: items.isEmpty
          ? EmptyState(
              icon: LucideIcons.fileText,
              title: 'No Prescriptions Scanned',
              description: 'Scan or upload doctor prescriptions to store them safely in one place.',
              buttonText: 'Scan Prescription',
              onButtonPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PrescriptionScanScreen(),
                  ),
                );
              },
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _buildPrescriptionCard(context, provider, item);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_prescription_list',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const PrescriptionScanScreen(),
            ),
          );
        },
        icon: const Icon(LucideIcons.camera, size: 20),
        label: Text(
          'Scan Rx',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildPrescriptionCard(
    BuildContext context,
    ReportProvider provider,
    Prescription item,
  ) {
    final isFileExist = File(item.imagePath).existsSync();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider, width: 0.8),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Banner
          GestureDetector(
            onTap: () => _viewFullPrescription(context, item),
            child: Container(
              height: 160,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: isFileExist
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                      child: Image.file(
                        File(item.imagePath),
                        fit: BoxFit.cover,
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.fileImage, size: 36, color: AppColors.primary),
                          const SizedBox(height: 6),
                          Text(
                            'Digital Rx Document',
                            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.doctorName ?? 'Prescription',
                        style: GoogleFonts.sora(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      DateTimeHelpers.formatDate(item.dateAdded),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                if (item.notes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    item.notes,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _viewFullPrescription(context, item),
                      icon: const Icon(LucideIcons.eye, size: 16),
                      label: const Text('View Document'),
                    ),
                    IconButton(
                      onPressed: () => _confirmDelete(context, provider, item),
                      icon: const Icon(LucideIcons.trash2, color: AppColors.statusMissed, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _viewFullPrescription(BuildContext context, Prescription item) {
    final isFileExist = File(item.imagePath).existsSync();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text(item.doctorName ?? 'Prescription'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(LucideIcons.x),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 450),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: isFileExist
                    ? Image.file(File(item.imagePath))
                    : const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text('Sample prescription file preview'),
                        ),
                      ),
              ),
            ),
            if (item.notes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  item.notes,
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, ReportProvider provider, Prescription item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Prescription?'),
        content: const Text('This will permanently delete the scanned prescription image.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await provider.deletePrescription(item.id);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusMissed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

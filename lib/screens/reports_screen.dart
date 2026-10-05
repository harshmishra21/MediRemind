import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/health_report.dart';
import '../providers/report_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/report_card.dart';
import '../widgets/empty_state.dart';
import 'report_view_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Blood Test',
    'Lab Test',
    'X-Ray',
    'General',
  ];

  Future<void> _uploadHealthReport() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(LucideIcons.filePlus, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Upload Health Report',
                          style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Store medical records, lab results & X-rays',
                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(LucideIcons.fileText, color: AppColors.primary, size: 20),
                ),
                title: Text('Select PDF or Document File', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                subtitle: Text('Pick PDF, PNG, or JPG from device storage', style: GoogleFonts.inter(fontSize: 12)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickFromFilePicker();
                },
              ),
              const Divider(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(LucideIcons.camera, color: AppColors.primary, size: 20),
                ),
                title: Text('Take Photo with Camera', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                subtitle: Text('Snap a picture of your lab result slip', style: GoogleFonts.inter(fontSize: 12)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickFromImagePicker(ImageSource.camera);
                },
              ),
              const Divider(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(LucideIcons.image, color: AppColors.primary, size: 20),
                ),
                title: Text('Choose Photo from Gallery', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                subtitle: Text('Select saved medical image from photos', style: GoogleFonts.inter(fontSize: 12)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickFromImagePicker(ImageSource.gallery);
                },
              ),
              const Divider(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.accentLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(LucideIcons.sparkles, color: AppColors.accent, size: 20),
                ),
                title: Text('Upload Sample Demo Report', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                subtitle: Text('Quickly test report features with sample data', style: GoogleFonts.inter(fontSize: 12)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _showReportMetadataDialog(context, 'assets/images/health_banner.jpg', ReportFileType.image);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickFromFilePicker() async {
    try {
      final files = await FilePickerPlatform.instance.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
      );

      if (files.isNotEmpty) {
        final filePath = files.first.path ?? '';
        final extension = files.first.extension?.toLowerCase() ?? '';
        final fileType = extension == 'pdf' ? ReportFileType.pdf : ReportFileType.image;

        if (mounted && filePath.isNotEmpty) {
          _showReportMetadataDialog(context, filePath, fileType);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to select file: $e'),
            backgroundColor: AppColors.statusMissed,
          ),
        );
      }
    }
  }

  Future<void> _pickFromImagePicker(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? photo = await picker.pickImage(source: source, imageQuality: 85);
      if (photo != null && mounted) {
        _showReportMetadataDialog(context, photo.path, ReportFileType.image);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not capture image: $e'),
            backgroundColor: AppColors.statusMissed,
          ),
        );
      }
    }
  }

  void _showReportMetadataDialog(BuildContext context, String filePath, ReportFileType type) {
    final titleController = TextEditingController();
    final notesController = TextEditingController();
    String category = 'Lab Test';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Add Health Report', style: GoogleFonts.sora(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Report Title *',
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    hintText: 'e.g. CBC Blood Test, Chest X-Ray',
                    prefixIcon: Icon(LucideIcons.fileText, size: 18),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Category',
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  items: ['Blood Test', 'Lab Test', 'X-Ray', 'General'].map((c) {
                    return DropdownMenuItem(value: c, child: Text(c));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() {
                        category = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 14),
                Text(
                  'Doctor Notes / Key Insights',
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Hemoglobin normal, cholesterol optimal',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final title = titleController.text.trim();
                if (title.isEmpty) return;

                final report = HealthReport(
                  id: const Uuid().v4(),
                  title: title,
                  category: category,
                  filePath: filePath,
                  type: type,
                  dateAdded: DateTime.now(),
                  notes: notesController.text.trim(),
                );

                final provider = Provider.of<ReportProvider>(context, listen: false);
                await provider.addReport(report);

                if (ctx.mounted) {
                  Navigator.of(ctx).pop();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Health report saved!'),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              child: const Text('Save Report'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ReportProvider>(context);
    final reports = provider.getReportsByCategory(_selectedCategory);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Health Reports',
          style: GoogleFonts.sora(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _uploadHealthReport,
            icon: const Icon(LucideIcons.upload, color: AppColors.primary),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter Chips
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = cat == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                    selectedColor: AppColors.primaryContainer,
                    backgroundColor: AppColors.surface,
                    checkmarkColor: AppColors.primary,
                    labelStyle: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Reports List
          Expanded(
            child: reports.isEmpty
                ? EmptyState(
                    icon: LucideIcons.clipboardList,
                    title: 'No Health Reports Found',
                    description: 'Store lab results, blood test PDFs, and X-ray images safely in your digital record cabinet.',
                    buttonText: 'Upload Document',
                    onButtonPressed: _uploadHealthReport,
                  )
                : AnimationLimiter(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      itemCount: reports.length,
                      itemBuilder: (context, index) {
                        final report = reports[index];
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 30.0,
                            child: FadeInAnimation(
                              child: ReportCard(
                                report: report,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ReportViewScreen(report: report),
                                    ),
                                  );
                                },
                                onDelete: () => _confirmDelete(context, provider, report),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_reports',
        onPressed: _uploadHealthReport,
        icon: const Icon(LucideIcons.filePlus, size: 20),
        label: Text(
          'Upload Report',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, ReportProvider provider, HealthReport report) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete ${report.title}?'),
        content: const Text('This will remove the report from your records.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await provider.deleteReport(report.id);
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

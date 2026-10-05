import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import '../models/medicine.dart';
import '../theme/app_colors.dart';
import '../utils/validators.dart';
import 'dosage_setup_screen.dart';

class AddEditMedicineScreen extends StatefulWidget {
  final Medicine? medicine;

  const AddEditMedicineScreen({super.key, this.medicine});

  @override
  State<AddEditMedicineScreen> createState() => _AddEditMedicineScreenState();
}

class _AddEditMedicineScreenState extends State<AddEditMedicineScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _strengthController;
  late TextEditingController _stockController;
  late TextEditingController _thresholdController;
  late String _selectedType;

  final List<String> _medicineTypes = [
    'Tablet',
    'Capsule',
    'Syrup',
    'Drops',
    'Injection',
    'Topical',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    final med = widget.medicine;
    _nameController = TextEditingController(text: med?.name ?? '');
    _strengthController = TextEditingController(text: med?.strengthLabel ?? '');
    _stockController = TextEditingController(text: med?.stock.toString() ?? '30');
    _thresholdController = TextEditingController(text: med?.refillThreshold.toString() ?? '7');
    _selectedType = med?.type ?? 'Tablet';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _strengthController.dispose();
    _stockController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  void _onNextStep() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final strength = _strengthController.text.trim();
    final stock = int.tryParse(_stockController.text.trim()) ?? 0;
    final threshold = int.tryParse(_thresholdController.text.trim()) ?? 0;

    final medId = widget.medicine?.id ?? const Uuid().v4();

    final tempMedicine = Medicine(
      id: medId,
      name: name,
      type: _selectedType,
      strengthLabel: strength,
      stock: stock,
      refillThreshold: threshold,
      createdAt: widget.medicine?.createdAt,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DosageSetupScreen(medicine: tempMedicine),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.medicine != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Medicine' : 'Add Medicine',
          style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step Header Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.pill, color: AppColors.primary, size: 28),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Step 1 of 2: Basic Info',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            'Enter medicine details & inventory stock',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Medicine Name Input
              Text(
                'Medicine Name *',
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                validator: (val) => Validators.requiredField(val, 'Medicine name'),
                decoration: const InputDecoration(
                  hintText: 'e.g. Metformin, Amoxicillin, Vitamin D3',
                  prefixIcon: Icon(LucideIcons.activity, size: 18),
                ),
              ),
              const SizedBox(height: 18),

              // Type & Strength Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Type *',
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedType,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          items: _medicineTypes.map((t) {
                            return DropdownMenuItem(
                              value: t,
                              child: Text(t, style: GoogleFonts.inter(fontSize: 14)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedType = val;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Strength *',
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _strengthController,
                          validator: (val) => Validators.requiredField(val, 'Strength'),
                          decoration: const InputDecoration(
                            hintText: 'e.g. 500 mg, 10 ml',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Stock & Refill Threshold Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pills in Box *',
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _stockController,
                          keyboardType: TextInputType.number,
                          validator: (val) => Validators.nonNegativeNumber(val, 'Stock'),
                          decoration: const InputDecoration(
                            hintText: 'e.g. 30',
                            prefixIcon: Icon(LucideIcons.box, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Refill Alert At *',
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _thresholdController,
                          keyboardType: TextInputType.number,
                          validator: (val) => Validators.nonNegativeNumber(val, 'Refill threshold'),
                          decoration: const InputDecoration(
                            hintText: 'e.g. 7',
                            prefixIcon: Icon(LucideIcons.bellRing, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Next Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _onNextStep,
                  icon: const Icon(LucideIcons.arrowRight, size: 18),
                  label: const Text('Continue to Dosage Setup'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
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

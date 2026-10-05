import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/medicine.dart';
import '../models/dosage_schedule.dart';
import '../providers/medicine_provider.dart';
import '../theme/app_colors.dart';
import '../utils/date_time_helpers.dart';
import '../utils/validators.dart';

class DosageSetupScreen extends StatefulWidget {
  final Medicine medicine;
  final DosageSchedule? existingSchedule;

  const DosageSetupScreen({
    super.key,
    required this.medicine,
    this.existingSchedule,
  });

  @override
  State<DosageSetupScreen> createState() => _DosageSetupScreenState();
}

class _DosageSetupScreenState extends State<DosageSetupScreen> {
  final _formKey = GlobalKey<FormState>();

  late List<String> _times; // List of "HH:mm" strings
  late List<int> _selectedDays; // 1 = Mon, 7 = Sun
  late DateTime _startDate;
  late DateTime _endDate;
  late int _dosesPerIntake;
  late TextEditingController _instructionsController;

  final List<Map<String, dynamic>> _weekdaysMap = [
    {'day': 1, 'label': 'Mon'},
    {'day': 2, 'label': 'Tue'},
    {'day': 3, 'label': 'Wed'},
    {'day': 4, 'label': 'Thu'},
    {'day': 5, 'label': 'Fri'},
    {'day': 6, 'label': 'Sat'},
    {'day': 7, 'label': 'Sun'},
  ];

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<MedicineProvider>(context, listen: false);
    final schedule = widget.existingSchedule ?? provider.getScheduleForMedicine(widget.medicine.id);

    if (schedule != null) {
      _times = List<String>.from(schedule.times);
      _selectedDays = List<int>.from(schedule.daysOfWeek);
      _startDate = schedule.startDate;
      _endDate = schedule.endDate;
      _dosesPerIntake = schedule.dosesPerIntake;
      _instructionsController = TextEditingController(text: schedule.instructions ?? '');
    } else {
      _times = ['08:00', '20:00'];
      _selectedDays = [1, 2, 3, 4, 5, 6, 7]; // All days default
      _startDate = DateTime.now();
      _endDate = DateTime.now().add(const Duration(days: 30));
      _dosesPerIntake = 1;
      _instructionsController = TextEditingController(text: 'Take after meals');
    }
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _addTimePicker() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
    );
    if (picked != null) {
      final hourStr = picked.hour.toString().padLeft(2, '0');
      final minuteStr = picked.minute.toString().padLeft(2, '0');
      final timeStr = '$hourStr:$minuteStr';
      if (!_times.contains(timeStr)) {
        setState(() {
          _times.add(timeStr);
          _times.sort();
        });
      }
    }
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate.add(const Duration(days: 7));
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    final timesError = Validators.validateReminderTimes(_times);
    if (timesError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(timesError),
          backgroundColor: AppColors.statusMissed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final dateError = Validators.validateDateRange(_startDate, _endDate);
    if (dateError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(dateError),
          backgroundColor: AppColors.statusMissed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one active day of the week'),
          backgroundColor: AppColors.statusMissed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final provider = Provider.of<MedicineProvider>(context, listen: false);

    final schedule = DosageSchedule(
      id: widget.existingSchedule?.id ?? const Uuid().v4(),
      medicineId: widget.medicine.id,
      times: _times,
      daysOfWeek: _selectedDays,
      startDate: _startDate,
      endDate: _endDate,
      dosesPerIntake: _dosesPerIntake,
      instructions: _instructionsController.text.trim(),
    );

    final isExisting = provider.getMedicineById(widget.medicine.id) != null;

    if (isExisting) {
      await provider.updateMedicine(widget.medicine);
      await provider.updateSchedule(schedule);
    } else {
      await provider.addMedicineWithSchedule(widget.medicine, schedule);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.medicine.name} saved successfully!'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Dosage & Reminders',
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
                    const Icon(LucideIcons.clock, color: AppColors.primary, size: 28),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Step 2 of 2: Schedule & Reminders',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            'Set daily intake times and reminder notifications',
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

              // 1. Intake Reminder Times Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Reminder Times *',
                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: _addTimePicker,
                    icon: const Icon(LucideIcons.plus, size: 16),
                    label: const Text('Add Time'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _times.map((t) {
                  final formattedTime = DateTimeHelpers.formatTimeString(t);
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary, width: 1.2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.clock, size: 15, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          formattedTime,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (_times.length > 1) ...[
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () {
                              setState(() {
                                _times.remove(t);
                              });
                            },
                            child: const Icon(
                              LucideIcons.x,
                              size: 16,
                              color: AppColors.statusMissed,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // 2. Active Days of Week Section
              Text(
                'Active Days *',
                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              Wrap(
                spacing: 8,
                children: _weekdaysMap.map((item) {
                  final dayInt = item['day'] as int;
                  final label = item['label'] as String;
                  final isSelected = _selectedDays.contains(dayInt);

                  return FilterChip(
                    label: Text(label),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedDays.add(dayInt);
                        } else {
                          _selectedDays.remove(dayInt);
                        }
                      });
                    },
                    selectedColor: AppColors.primaryContainer,
                    backgroundColor: AppColors.surface,
                    checkmarkColor: AppColors.primary,
                    labelStyle: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // 3. Start & End Date Selection
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _selectStartDate,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Start Date',
                              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textTertiary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateTimeHelpers.formatDate(_startDate),
                              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: InkWell(
                      onTap: _selectEndDate,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'End Date',
                              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textTertiary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateTimeHelpers.formatDate(_endDate),
                              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 4. Units per Intake Counter
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Units per Intake',
                        style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Number of ${widget.medicine.type.toLowerCase()}s taken at each scheduled time',
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton.filledTonal(
                        onPressed: _dosesPerIntake > 1
                            ? () {
                                setState(() {
                                  _dosesPerIntake--;
                                });
                              }
                            : null,
                        icon: const Icon(LucideIcons.minus, size: 16),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14.0),
                        child: Text(
                          '$_dosesPerIntake',
                          style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton.filledTonal(
                        onPressed: () {
                          setState(() {
                            _dosesPerIntake++;
                          });
                        },
                        icon: const Icon(LucideIcons.plus, size: 16),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 5. Intake Instructions Note
              Text(
                'Special Instructions (Optional)',
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _instructionsController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Take after breakfast, with a glass of water',
                  prefixIcon: Icon(LucideIcons.info, size: 18),
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _onSave,
                  icon: const Icon(LucideIcons.check, size: 18),
                  label: const Text('Save Medicine & Reminders'),
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

import '../providers/medicine_provider.dart';
import '../models/medicine.dart';
import '../theme/app_colors.dart';
import '../widgets/medicine_card.dart';
import '../widgets/empty_state.dart';
import 'add_edit_medicine_screen.dart';
import 'medicine_detail_screen.dart';

class MedicineListScreen extends StatefulWidget {
  const MedicineListScreen({super.key});

  @override
  State<MedicineListScreen> createState() => _MedicineListScreenState();
}

class _MedicineListScreenState extends State<MedicineListScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<String> _categories = [
    'All',
    'Tablet',
    'Capsule',
    'Syrup',
    'Drops',
    'Injection',
    'Topical',
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicineProvider>(context);
    final allMedicines = provider.medicines;

    final filteredMedicines = allMedicines.where((med) {
      final matchesCategory =
          _selectedCategory == 'All' || med.type.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesSearch = med.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          med.strengthLabel.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'My Medicines',
          style: GoogleFonts.sora(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AddEditMedicineScreen(),
                ),
              );
            },
            icon: const Icon(LucideIcons.plus, color: AppColors.primary),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: TextField(
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search medicines by name or strength...',
                prefixIcon: const Icon(LucideIcons.search, size: 18, color: AppColors.textTertiary),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(LucideIcons.x, size: 16),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
            ),
          ),

          // 2. Filter Chips Row
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : AppColors.divider,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // 3. Medicine List View
          Expanded(
            child: filteredMedicines.isEmpty
                ? EmptyState(
                    icon: LucideIcons.pill,
                    title: _searchQuery.isNotEmpty
                        ? 'No matching medicines'
                        : 'No medicines added yet',
                    description: _searchQuery.isNotEmpty
                        ? 'Try searching with a different name or clear the filter.'
                        : 'Tap the button below to add your first prescription medicine.',
                    buttonText: 'Add Medicine',
                    onButtonPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AddEditMedicineScreen(),
                        ),
                      );
                    },
                  )
                : AnimationLimiter(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      itemCount: filteredMedicines.length,
                      itemBuilder: (context, index) {
                        final med = filteredMedicines[index];
                        final schedule = provider.getScheduleForMedicine(med.id);
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 40.0,
                            child: FadeInAnimation(
                              child: MedicineCard(
                                medicine: med,
                                schedule: schedule,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => MedicineDetailScreen(medicineId: med.id),
                                    ),
                                  );
                                },
                                onEdit: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => AddEditMedicineScreen(medicine: med),
                                    ),
                                  );
                                },
                                onDelete: () => _confirmDelete(context, provider, med),
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
        heroTag: 'fab_medicine_list',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AddEditMedicineScreen(),
            ),
          );
        },
        icon: const Icon(LucideIcons.plus, size: 20),
        label: Text(
          'Add Medicine',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, MedicineProvider provider, Medicine med) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete ${med.name}?'),
        content: Text(
          'This will permanently remove ${med.name} and all its dosage schedules and reminder history.',
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
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusMissed,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

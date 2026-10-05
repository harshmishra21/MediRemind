import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dashboard_screen.dart';
import 'medicine_list_screen.dart';
import 'prescription_list_screen.dart';
import 'reports_screen.dart';
import '../theme/app_colors.dart';

class RootNavShell extends StatefulWidget {
  final int initialTab;

  const RootNavShell({super.key, this.initialTab = 0});

  @override
  State<RootNavShell> createState() => _RootNavShellState();
}

class _RootNavShellState extends State<RootNavShell> {
  late int _currentIndex;

  final List<Widget> _screens = const [
    DashboardScreen(),
    MedicineListScreen(),
    PrescriptionListScreen(),
    ReportsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  void navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false, // Child screens manage top padding for Dynamic Island
        child: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.divider, width: 0.8),
          ),
        ),
        child: SafeArea(
          top: false,
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(LucideIcons.home),
                selectedIcon: Icon(LucideIcons.home),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(LucideIcons.pill),
                selectedIcon: Icon(LucideIcons.pill),
                label: 'Medicines',
              ),
              NavigationDestination(
                icon: Icon(LucideIcons.fileText),
                selectedIcon: Icon(LucideIcons.fileText),
                label: 'Prescriptions',
              ),
              NavigationDestination(
                icon: Icon(LucideIcons.clipboardList),
                selectedIcon: Icon(LucideIcons.clipboardList),
                label: 'Reports',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

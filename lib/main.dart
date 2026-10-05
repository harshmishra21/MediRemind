import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme/app_theme.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'providers/medicine_provider.dart';
import 'providers/report_provider.dart';
import 'screens/root_nav_shell.dart';

import 'widgets/iphone_frame.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Services
  final storageService = await StorageService.init();
  await NotificationService().init();

  runApp(MediRemindApp(storageService: storageService));
}

class MediRemindApp extends StatelessWidget {
  final StorageService storageService;

  const MediRemindApp({super.key, required this.storageService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MedicineProvider(storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => ReportProvider(storageService),
        ),
      ],
      child: MaterialApp(
        title: 'MediRemind',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        builder: (context, child) => IPhoneFrame(child: child ?? const SizedBox.shrink()),
        home: const RootNavShell(),
      ),
    );
  }
}

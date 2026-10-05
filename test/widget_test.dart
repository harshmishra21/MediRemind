import 'package:flutter_test/flutter_test.dart';
import 'package:mediremind/main.dart';
import 'package:mediremind/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('MediRemind smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storageService = await StorageService.init();
    await tester.pumpWidget(MediRemindApp(storageService: storageService));
    expect(find.byType(MediRemindApp), findsOneWidget);
  });
}

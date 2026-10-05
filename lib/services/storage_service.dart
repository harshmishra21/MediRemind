import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/medicine.dart';
import '../models/dosage_schedule.dart';
import '../models/dose_log.dart';
import '../models/prescription.dart';
import '../models/health_report.dart';

class StorageService {
  static const String _keyMedicines = 'mediremind_medicines';
  static const String _keySchedules = 'mediremind_schedules';
  static const String _keyDoseLogs = 'mediremind_doselogs';
  static const String _keyPrescriptions = 'mediremind_prescriptions';
  static const String _keyReports = 'mediremind_reports';
  static const String _keyInitialized = 'mediremind_is_initialized_v2';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    final service = StorageService(prefs);
    await service._ensureSeedData();
    return service;
  }

  Future<void> _ensureSeedData() async {
    final isInit = _prefs.getBool(_keyInitialized) ?? false;
    if (!isInit) {
      await seedRichDummyData();
    }
  }

  Future<void> seedRichDummyData() async {
    const uuid = Uuid();
    final now = DateTime.now();

    // 1. Seed Medicines
    final med1Id = uuid.v4();
    final med2Id = uuid.v4();
    final med3Id = uuid.v4();
    final med4Id = uuid.v4();
    final med5Id = uuid.v4();

    final seedMedicines = [
      Medicine(
        id: med1Id,
        name: 'Metformin',
        type: 'Tablet',
        strengthLabel: '500 mg',
        stock: 24,
        refillThreshold: 10,
        createdAt: now.subtract(const Duration(days: 14)),
      ),
      Medicine(
        id: med2Id,
        name: 'Vitamin D3',
        type: 'Capsule',
        strengthLabel: '2000 IU',
        stock: 3, // Low stock demo!
        refillThreshold: 7,
        createdAt: now.subtract(const Duration(days: 20)),
      ),
      Medicine(
        id: med3Id,
        name: 'Amoxicillin',
        type: 'Capsule',
        strengthLabel: '500 mg',
        stock: 15,
        refillThreshold: 6,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      Medicine(
        id: med4Id,
        name: 'Omeprazole',
        type: 'Capsule',
        strengthLabel: '20 mg',
        stock: 30,
        refillThreshold: 5,
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      Medicine(
        id: med5Id,
        name: 'Atorvastatin',
        type: 'Tablet',
        strengthLabel: '10 mg',
        stock: 0, // Out of stock demo!
        refillThreshold: 5,
        createdAt: now.subtract(const Duration(days: 45)),
      ),
    ];

    // 2. Seed Dosage Schedules
    final seedSchedules = [
      DosageSchedule(
        id: uuid.v4(),
        medicineId: med1Id,
        times: ['08:00', '20:00'],
        daysOfWeek: [1, 2, 3, 4, 5, 6, 7],
        startDate: now.subtract(const Duration(days: 10)),
        endDate: now.add(const Duration(days: 60)),
        dosesPerIntake: 1,
        instructions: 'Take with morning and evening meals',
      ),
      DosageSchedule(
        id: uuid.v4(),
        medicineId: med2Id,
        times: ['09:00'],
        daysOfWeek: [1, 2, 3, 4, 5, 6, 7],
        startDate: now.subtract(const Duration(days: 15)),
        endDate: now.add(const Duration(days: 45)),
        dosesPerIntake: 1,
        instructions: 'Take after breakfast with water',
      ),
      DosageSchedule(
        id: uuid.v4(),
        medicineId: med3Id,
        times: ['08:00', '14:00', '20:00'],
        daysOfWeek: [1, 2, 3, 4, 5, 6, 7],
        startDate: now.subtract(const Duration(days: 2)),
        endDate: now.add(const Duration(days: 5)),
        dosesPerIntake: 1,
        instructions: 'Complete full prescribed 7-day antibiotic course',
      ),
      DosageSchedule(
        id: uuid.v4(),
        medicineId: med4Id,
        times: ['07:30'],
        daysOfWeek: [1, 2, 3, 4, 5, 6, 7],
        startDate: now.subtract(const Duration(days: 25)),
        endDate: now.add(const Duration(days: 90)),
        dosesPerIntake: 1,
        instructions: 'Take 30 minutes before breakfast',
      ),
      DosageSchedule(
        id: uuid.v4(),
        medicineId: med5Id,
        times: ['21:30'],
        daysOfWeek: [1, 2, 3, 4, 5, 6, 7],
        startDate: now.subtract(const Duration(days: 40)),
        endDate: now.add(const Duration(days: 120)),
        dosesPerIntake: 1,
        instructions: 'Take at night before bed',
      ),
    ];

    // 3. Seed Dose Logs for Today
    final todaySevenThirty = DateTime(now.year, now.month, now.day, 7, 30);
    final todayEight = DateTime(now.year, now.month, now.day, 8, 0);
    final todayNine = DateTime(now.year, now.month, now.day, 9, 0);
    final todayFourteen = DateTime(now.year, now.month, now.day, 14, 0);
    final todayTwenty = DateTime(now.year, now.month, now.day, 20, 0);
    final todayTwentyOneThirty = DateTime(now.year, now.month, now.day, 21, 30);

    final seedDoseLogs = [
      DoseLog(
        id: uuid.v4(),
        medicineId: med4Id,
        scheduledDateTime: todaySevenThirty,
        status: DoseStatus.taken,
        actionDateTime: todaySevenThirty.add(const Duration(minutes: 5)),
        notes: 'Taken before breakfast',
      ),
      DoseLog(
        id: uuid.v4(),
        medicineId: med1Id,
        scheduledDateTime: todayEight,
        status: DoseStatus.taken,
        actionDateTime: todayEight.add(const Duration(minutes: 10)),
        notes: 'Taken with breakfast',
      ),
      DoseLog(
        id: uuid.v4(),
        medicineId: med2Id,
        scheduledDateTime: todayNine,
        status: DoseStatus.taken,
        actionDateTime: todayNine.add(const Duration(minutes: 4)),
      ),
      DoseLog(
        id: uuid.v4(),
        medicineId: med3Id,
        scheduledDateTime: todayFourteen,
        status: DoseStatus.pending,
      ),
      DoseLog(
        id: uuid.v4(),
        medicineId: med1Id,
        scheduledDateTime: todayTwenty,
        status: DoseStatus.pending,
      ),
      DoseLog(
        id: uuid.v4(),
        medicineId: med5Id,
        scheduledDateTime: todayTwentyOneThirty,
        status: DoseStatus.pending,
      ),
    ];

    // 4. Seed Prescriptions
    final seedPrescriptions = [
      Prescription(
        id: uuid.v4(),
        doctorName: 'Dr. Ananya Sharma (Cardiologist)',
        dateAdded: now.subtract(const Duration(days: 14)),
        imagePath: 'assets/images/prescription_scan.jpg',
        notes: 'Metformin 500mg twice daily & Atorvastatin 10mg nightly. Re-check lipid panel in 3 months.',
      ),
      Prescription(
        id: uuid.v4(),
        doctorName: 'Dr. Rajesh Sharma (General Physician)',
        dateAdded: now.subtract(const Duration(days: 3)),
        imagePath: 'assets/images/prescription_scan.jpg',
        notes: 'Amoxicillin 500mg 3x daily for 7 days. Drink plenty of water and rest.',
      ),
      Prescription(
        id: uuid.v4(),
        doctorName: 'Dr. Priya Mehta (Endocrinologist)',
        dateAdded: now.subtract(const Duration(days: 45)),
        imagePath: 'assets/images/prescription_scan.jpg',
        notes: 'Vitamin D3 2000 IU daily morning supplement for 60 days.',
      ),
    ];

    // 5. Seed Health Reports
    final seedReports = [
      HealthReport(
        id: uuid.v4(),
        title: 'Complete Blood Count (CBC)',
        category: 'Blood Test',
        filePath: 'assets/images/health_banner.jpg',
        type: ReportFileType.image,
        dateAdded: now.subtract(const Duration(days: 10)),
        notes: 'Hemoglobin 14.2 g/dL (Normal), WBC 6,500/mcL, Platelets 250k. Excellent results.',
      ),
      HealthReport(
        id: uuid.v4(),
        title: 'Comprehensive Lipid Profile',
        category: 'Lab Test',
        filePath: 'assets/images/health_banner.jpg',
        type: ReportFileType.image,
        dateAdded: now.subtract(const Duration(days: 25)),
        notes: 'HDL 58 mg/dL (Optimal), LDL 98 mg/dL, Triglycerides 110 mg/dL. Good cardiovascular profile.',
      ),
      HealthReport(
        id: uuid.v4(),
        title: 'Chest X-Ray (PA View)',
        category: 'X-Ray',
        filePath: 'assets/images/health_banner.jpg',
        type: ReportFileType.image,
        dateAdded: now.subtract(const Duration(days: 60)),
        notes: 'Lung fields clear bilaterally. Cardiac size normal. No active focal lesions.',
      ),
      HealthReport(
        id: uuid.v4(),
        title: 'Glycated Hemoglobin (HbA1c)',
        category: 'Lab Test',
        filePath: 'assets/images/health_banner.jpg',
        type: ReportFileType.image,
        dateAdded: now.subtract(const Duration(days: 90)),
        notes: 'HbA1c 6.1% (Glycemic control optimal. Continue prescribed dosage).',
      ),
    ];

    await saveMedicines(seedMedicines);
    await saveSchedules(seedSchedules);
    await saveDoseLogs(seedDoseLogs);
    await savePrescriptions(seedPrescriptions);
    await saveReports(seedReports);

    await _prefs.setBool(_keyInitialized, true);
  }

  // Medicines
  List<Medicine> loadMedicines() {
    final raw = _prefs.getString(_keyMedicines);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List decoded = jsonDecode(raw);
      return decoded.map((e) => Medicine.fromMap(Map<String, dynamic>.from(e))).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveMedicines(List<Medicine> medicines) async {
    final raw = jsonEncode(medicines.map((e) => e.toMap()).toList());
    await _prefs.setString(_keyMedicines, raw);
  }

  // Schedules
  List<DosageSchedule> loadSchedules() {
    final raw = _prefs.getString(_keySchedules);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List decoded = jsonDecode(raw);
      return decoded.map((e) => DosageSchedule.fromMap(Map<String, dynamic>.from(e))).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveSchedules(List<DosageSchedule> schedules) async {
    final raw = jsonEncode(schedules.map((e) => e.toMap()).toList());
    await _prefs.setString(_keySchedules, raw);
  }

  // Dose Logs
  List<DoseLog> loadDoseLogs() {
    final raw = _prefs.getString(_keyDoseLogs);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List decoded = jsonDecode(raw);
      return decoded.map((e) => DoseLog.fromMap(Map<String, dynamic>.from(e))).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveDoseLogs(List<DoseLog> logs) async {
    final raw = jsonEncode(logs.map((e) => e.toMap()).toList());
    await _prefs.setString(_keyDoseLogs, raw);
  }

  // Prescriptions
  List<Prescription> loadPrescriptions() {
    final raw = _prefs.getString(_keyPrescriptions);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List decoded = jsonDecode(raw);
      return decoded.map((e) => Prescription.fromMap(Map<String, dynamic>.from(e))).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> savePrescriptions(List<Prescription> items) async {
    final raw = jsonEncode(items.map((e) => e.toMap()).toList());
    await _prefs.setString(_keyPrescriptions, raw);
  }

  // Reports
  List<HealthReport> loadReports() {
    final raw = _prefs.getString(_keyReports);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List decoded = jsonDecode(raw);
      return decoded.map((e) => HealthReport.fromMap(Map<String, dynamic>.from(e))).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveReports(List<HealthReport> items) async {
    final raw = jsonEncode(items.map((e) => e.toMap()).toList());
    await _prefs.setString(_keyReports, raw);
  }
}

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/medicine.dart';
import '../models/dosage_schedule.dart';
import '../models/dose_log.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../utils/date_time_helpers.dart';

class TodayDoseItem {
  final Medicine medicine;
  final DosageSchedule schedule;
  final String timeStr;
  final DateTime scheduledDateTime;
  final DoseLog log;

  TodayDoseItem({
    required this.medicine,
    required this.schedule,
    required this.timeStr,
    required this.scheduledDateTime,
    required this.log,
  });
}

class MedicineProvider with ChangeNotifier {
  final StorageService _storageService;
  final NotificationService _notificationService = NotificationService();
  final Uuid _uuid = const Uuid();

  List<Medicine> _medicines = [];
  List<DosageSchedule> _schedules = [];
  List<DoseLog> _doseLogs = [];

  bool _isLoading = true;

  MedicineProvider(this._storageService) {
    _loadData();
  }

  bool get isLoading => _isLoading;
  List<Medicine> get medicines => List.unmodifiable(_medicines);
  List<DosageSchedule> get schedules => List.unmodifiable(_schedules);
  List<DoseLog> get doseLogs => List.unmodifiable(_doseLogs);

  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    _medicines = _storageService.loadMedicines();
    _schedules = _storageService.loadSchedules();
    _doseLogs = _storageService.loadDoseLogs();

    _updateMissedStatusForToday();
    _isLoading = false;
    notifyListeners();
  }

  // Today's Doses Calculation
  List<TodayDoseItem> get todayDoses {
    final now = DateTime.now();
    final currentWeekday = now.weekday; // 1 = Mon, 7 = Sun
    final List<TodayDoseItem> items = [];

    for (final schedule in _schedules) {
      if (!schedule.daysOfWeek.contains(currentWeekday)) continue;
      if (now.isBefore(schedule.startDate) || now.isAfter(schedule.endDate)) continue;

      final medicine = _medicines.firstWhere(
        (m) => m.id == schedule.medicineId,
        orElse: () => Medicine(
          id: '',
          name: 'Unknown',
          type: 'Tablet',
          strengthLabel: '',
          stock: 0,
          refillThreshold: 0,
        ),
      );
      if (medicine.id.isEmpty) continue;

      for (final timeStr in schedule.times) {
        final scheduledDt = DateTimeHelpers.combineDateAndTime(now, timeStr);

        // Find existing dose log for today and this time
        DoseLog? existingLog;
        try {
          existingLog = _doseLogs.firstWhere(
            (log) =>
                log.medicineId == medicine.id &&
                DateTimeHelpers.isSameDay(log.scheduledDateTime, now) &&
                log.scheduledDateTime.hour == scheduledDt.hour &&
                log.scheduledDateTime.minute == scheduledDt.minute,
          );
        } catch (_) {
          existingLog = null;
        }

        DoseStatus currentStatus = DoseStatus.pending;
        if (existingLog != null) {
          currentStatus = existingLog.status;
        } else if (scheduledDt.isBefore(now.subtract(const Duration(minutes: 15)))) {
          currentStatus = DoseStatus.missed;
        }

        final log = existingLog ??
            DoseLog(
              id: _uuid.v4(),
              medicineId: medicine.id,
              scheduledDateTime: scheduledDt,
              status: currentStatus,
            );

        items.add(TodayDoseItem(
          medicine: medicine,
          schedule: schedule,
          timeStr: timeStr,
          scheduledDateTime: scheduledDt,
          log: log,
        ));
      }
    }

    items.sort((a, b) => a.scheduledDateTime.compareTo(b.scheduledDateTime));
    return items;
  }

  void _updateMissedStatusForToday() {
    final now = DateTime.now();
    bool updated = false;

    for (final item in todayDoses) {
      if (item.log.status == DoseStatus.pending &&
          item.scheduledDateTime.isBefore(now.subtract(const Duration(minutes: 30)))) {
        final newLog = item.log.copyWith(status: DoseStatus.missed);
        final index = _doseLogs.indexWhere((l) => l.id == newLog.id);
        if (index != -1) {
          _doseLogs[index] = newLog;
        } else {
          _doseLogs.add(newLog);
        }
        updated = true;
      }
    }

    if (updated) {
      _storageService.saveDoseLogs(_doseLogs);
    }
  }

  int get todayTakenCount {
    return todayDoses.where((d) => d.log.status == DoseStatus.taken).length;
  }

  int get todayTotalCount {
    return todayDoses.length;
  }

  double get todayCompletionPercentage {
    if (todayTotalCount == 0) return 1.0;
    return todayTakenCount / todayTotalCount;
  }

  TodayDoseItem? get nextUpcomingDose {
    final upcoming = todayDoses.where((d) => d.log.status == DoseStatus.pending).toList();
    if (upcoming.isEmpty) return null;
    return upcoming.first;
  }

  // Refill Calculations
  List<Medicine> get lowStockMedicines {
    return _medicines.where((m) => m.stock <= m.refillThreshold).toList();
  }

  List<Medicine> get outOfStockMedicines {
    return _medicines.where((m) => m.stock == 0).toList();
  }

  int daysOfStockRemaining(Medicine medicine) {
    final schedule = _schedules.firstWhere(
      (s) => s.medicineId == medicine.id,
      orElse: () => DosageSchedule(
        id: '',
        medicineId: '',
        times: ['08:00'],
        daysOfWeek: [1, 2, 3, 4, 5, 6, 7],
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      ),
    );
    final dailyIntake = schedule.totalDosesPerDay;
    if (dailyIntake == 0) return 999;
    return medicine.stock ~/ dailyIntake;
  }

  // CRUD Operations
  Future<void> addMedicineWithSchedule(Medicine medicine, DosageSchedule schedule) async {
    _medicines.add(medicine);
    _schedules.add(schedule);

    await _storageService.saveMedicines(_medicines);
    await _storageService.saveSchedules(_schedules);

    // Schedule local notifications
    await _notificationService.scheduleDosageReminder(
      medicineId: medicine.id,
      medicineName: medicine.name,
      strength: medicine.strengthLabel,
      timeStr: schedule.times.join(','),
      daysOfWeek: schedule.daysOfWeek,
      instructions: schedule.instructions ?? '',
    );

    notifyListeners();
  }

  Future<void> updateMedicine(Medicine updatedMed) async {
    final index = _medicines.indexWhere((m) => m.id == updatedMed.id);
    if (index != -1) {
      _medicines[index] = updatedMed;
      await _storageService.saveMedicines(_medicines);
      notifyListeners();
    }
  }

  Future<void> updateSchedule(DosageSchedule updatedSchedule) async {
    final index = _schedules.indexWhere((s) => s.id == updatedSchedule.id);
    if (index != -1) {
      _schedules[index] = updatedSchedule;
      await _storageService.saveSchedules(_schedules);

      final med = getMedicineById(updatedSchedule.medicineId);
      if (med != null) {
        await _notificationService.cancelMedicineReminders(med.id);
        await _notificationService.scheduleDosageReminder(
          medicineId: med.id,
          medicineName: med.name,
          strength: med.strengthLabel,
          timeStr: updatedSchedule.times.join(','),
          daysOfWeek: updatedSchedule.daysOfWeek,
          instructions: updatedSchedule.instructions ?? '',
        );
      }

      notifyListeners();
    }
  }

  Future<void> deleteMedicine(String id) async {
    _medicines.removeWhere((m) => m.id == id);
    _schedules.removeWhere((s) => s.medicineId == id);
    _doseLogs.removeWhere((l) => l.medicineId == id);

    await _storageService.saveMedicines(_medicines);
    await _storageService.saveSchedules(_schedules);
    await _storageService.saveDoseLogs(_doseLogs);

    await _notificationService.cancelMedicineReminders(id);
    notifyListeners();
  }

  Medicine? getMedicineById(String id) {
    try {
      return _medicines.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  DosageSchedule? getScheduleForMedicine(String medicineId) {
    try {
      return _schedules.firstWhere((s) => s.medicineId == medicineId);
    } catch (_) {
      return null;
    }
  }

  // Mark Dose Status Action
  Future<void> markDoseStatus({
    required TodayDoseItem doseItem,
    required DoseStatus newStatus,
    String? notes,
  }) async {
    final now = DateTime.now();
    final logIndex = _doseLogs.indexWhere((l) => l.id == doseItem.log.id);

    final updatedLog = doseItem.log.copyWith(
      status: newStatus,
      actionDateTime: now,
      notes: notes ?? doseItem.log.notes,
    );

    if (logIndex != -1) {
      _doseLogs[logIndex] = updatedLog;
    } else {
      _doseLogs.add(updatedLog);
    }

    // Decrement stock if status changed to TAKEN
    if (newStatus == DoseStatus.taken && doseItem.log.status != DoseStatus.taken) {
      final med = doseItem.medicine;
      final newStock = (med.stock - doseItem.schedule.dosesPerIntake).clamp(0, 9999);
      final updatedMed = med.copyWith(stock: newStock);

      final medIndex = _medicines.indexWhere((m) => m.id == med.id);
      if (medIndex != -1) {
        _medicines[medIndex] = updatedMed;
        await _storageService.saveMedicines(_medicines);

        if (newStock <= updatedMed.refillThreshold) {
          _notificationService.showInstantNotification(
            title: 'Refill Warning: ${updatedMed.name}',
            body: newStock == 0
                ? '${updatedMed.name} is completely out of stock!'
                : 'Only $newStock doses of ${updatedMed.name} remaining.',
          );
        }
      }
    }

    await _storageService.saveDoseLogs(_doseLogs);
    notifyListeners();
  }

  // Refill Stock Action
  Future<void> refillStock(String medicineId, int addAmount) async {
    final medIndex = _medicines.indexWhere((m) => m.id == medicineId);
    if (medIndex != -1) {
      final med = _medicines[medIndex];
      final updatedMed = med.copyWith(stock: med.stock + addAmount);
      _medicines[medIndex] = updatedMed;
      await _storageService.saveMedicines(_medicines);
      notifyListeners();
    }
  }
}

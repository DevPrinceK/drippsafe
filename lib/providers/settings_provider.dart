import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_settings.dart';
import '../services/cycle_calculator.dart';

class SettingsProvider extends ChangeNotifier {
  UserSettings _settings = const UserSettings();
  bool _isLoading = false;
  String? _error;
  // Cycle cache for fast date lookups
  Map<DateTime, CycleDayInfo> _cycleCache = {};
  static const int _defaultLuteal = 14; // Could be user-configurable later

  UserSettings get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isConfigured => _settings.isValid;

  Future<void> loadSettings() async {
    _setLoading(true);
    try {
      final box = Hive.box('drippsafe_db');
      final data = box.get('settings');

      if (data != null) {
        _settings = UserSettings.fromJson(Map<String, dynamic>.from(data));
        _calculateNextPeriod();
        _rebuildCycleCache();
      }
      _error = null;
    } catch (e) {
      _error = 'Failed to load settings: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> saveSettings({
    String? name,
    String? loadingName,
    DateTime? startDate,
    DateTime? endDate,
    int? cycleLength,
  }) async {
    _setLoading(true);
    try {
      final updatedSettings = _settings.copyWith(
        name: name,
        loadingName: loadingName,
        startDate: startDate,
        endDate: endDate,
        cycleLength: cycleLength,
        isFirstTime: false,
      );

      if (!updatedSettings.isValid) {
        throw Exception('Invalid settings data');
      }

      _settings = updatedSettings;
      _calculateNextPeriod();
      _rebuildCycleCache();

      final box = Hive.box('drippsafe_db');
      await box.put('settings', _settings.toJson());

      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to save settings: $e';
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _calculateNextPeriod() {
    if (_settings.startDate != null && _settings.endDate != null) {
      final periodLength = _settings.periodLength;
      final nextStart =
          _settings.startDate!.add(Duration(days: _settings.cycleLength));
      final nextEnd = nextStart.add(Duration(days: periodLength - 1));

      _settings = _settings.copyWith(
        nextStartDate: nextStart,
        nextEndDate: nextEnd,
      );
    }
  }

  void _rebuildCycleCache() {
    if (_settings.startDate == null) return;
    final calc = CycleCalculator(
      lastPeriodStart: _settings.startDate!,
      config: CycleCalculatorConfig(
        cycleLength: _settings.cycleLength,
        periodLength: _settings.periodLength,
        lutealLength: _defaultLuteal,
        cyclesForward: 6,
      ),
    );
    _cycleCache = calc.generate();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  bool isPeriodDay(DateTime date) {
    final info = dayInfo(date);
    return info?.phase == CyclePhase.menstrual;
  }

  bool isOvulationDay(DateTime date) {
    final info = dayInfo(date);
    return info?.phase == CyclePhase.ovulation;
  }

  bool isSafeDay(DateTime date) {
    final info = dayInfo(date);
    if (info == null) return false;
    return info.phase == CyclePhase.follicular ||
        info.phase == CyclePhase.luteal;
  }

  // New API
  CycleDayInfo? dayInfo(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return _cycleCache[d];
  }

  CyclePhase? phaseFor(DateTime date) => dayInfo(date)?.phase;

  DateTime? predictedNextPeriod() => _settings.nextStartDate;

  List<List<DateTime>> monthMatrix(DateTime month) => buildMonthMatrix(month);
}

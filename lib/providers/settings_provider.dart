import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_settings.dart';

class SettingsProvider extends ChangeNotifier {
  UserSettings _settings = const UserSettings();
  bool _isLoading = false;
  String? _error;

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

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  bool isPeriodDay(DateTime date) {
    if (_settings.nextStartDate == null || _settings.nextEndDate == null) {
      return false;
    }
    return date.isAfter(
            _settings.nextStartDate!.subtract(const Duration(days: 1))) &&
        date.isBefore(_settings.nextEndDate!.add(const Duration(days: 1)));
  }

  bool isOvulationDay(DateTime date) {
    if (_settings.nextStartDate == null) return false;
    // Ovulation typically occurs 14 days before the next period
    final ovulationDate =
        _settings.nextStartDate!.subtract(const Duration(days: 14));
    return date.isAtSameMomentAs(ovulationDate);
  }

  bool isSafeDay(DateTime date) {
    return !isPeriodDay(date) && !isOvulationDay(date);
  }
}

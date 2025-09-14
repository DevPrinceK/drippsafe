/// Cycle phases representing physiological segments of a menstrual cycle.
/// These labels are for educational & planning assistance and are NOT a
/// diagnostic or medical substitute.
///
/// menstrual: Active bleeding days.
/// follicular: Post-menstruation pre-fertile buildup.
/// fertile: 5-day window before ovulation plus ovulation probability rise.
/// ovulation: Estimated ovulation day (egg release) – prediction only.
/// luteal: Post-ovulation phase until next period begins.
enum CyclePhase { menstrual, follicular, fertile, ovulation, luteal }

class CycleDayInfo {
  final DateTime date;
  final int cycleIndex; // 0 = current cycle, 1 = next, etc.
  final int dayOfCycle; // 1-based within its cycle
  final CyclePhase phase;
  final bool isPredicted; // true if beyond confirmed last recorded period range
  final bool isToday;
  final DateTime cycleStart; // first day of that cycle
  final DateTime expectedNextPeriodStart;
  final DateTime ovulationDate;

  const CycleDayInfo({
    required this.date,
    required this.cycleIndex,
    required this.dayOfCycle,
    required this.phase,
    required this.isPredicted,
    required this.isToday,
    required this.cycleStart,
    required this.expectedNextPeriodStart,
    required this.ovulationDate,
  });
}

class CycleCalculatorConfig {
  final int cycleLength; // average cycle length
  final int periodLength; // length of bleeding
  final int lutealLength; // assumed luteal length (default ~14)
  final int cyclesForward; // number of future cycles to generate

  const CycleCalculatorConfig({
    required this.cycleLength,
    required this.periodLength,
    this.lutealLength = 14,
    this.cyclesForward = 6,
  });
}

class CycleCalculator {
  final DateTime lastPeriodStart;
  final CycleCalculatorConfig config;

  CycleCalculator({
    required this.lastPeriodStart,
    required this.config,
  })  : assert(config.periodLength > 0),
        assert(config.cycleLength >= config.periodLength + 8,
            'Cycle length too short relative to period length'),
        assert(config.lutealLength >= 10 && config.lutealLength <= 17,
            'Luteal length out of typical range (10-17)');

  /// Returns estimated ovulation date for the cycle that begins on [cycleStart].
  DateTime ovulationForCycle(DateTime cycleStart) {
    // Ovulation = cycleStart + (cycleLength - lutealLength) - 1 (because day1 is cycleStart)
    return cycleStart
        .add(Duration(days: config.cycleLength - config.lutealLength - 1));
  }

  /// Returns expected next period (start) for cycle that starts at [cycleStart].
  DateTime nextPeriodStart(DateTime cycleStart) =>
      cycleStart.add(Duration(days: config.cycleLength));

  /// Generate a map keyed by date for quick lookup.
  Map<DateTime, CycleDayInfo> generate() {
    final map = <DateTime, CycleDayInfo>{};
    final today = _dateOnly(DateTime.now());

    for (int idx = 0; idx <= config.cyclesForward; idx++) {
      final cycleStart =
          lastPeriodStart.add(Duration(days: idx * config.cycleLength));
      final expectedNext = nextPeriodStart(cycleStart);
      final ovulation = ovulationForCycle(cycleStart);

      for (int dayOffset = 0; dayOffset < config.cycleLength; dayOffset++) {
        final date = _dateOnly(cycleStart.add(Duration(days: dayOffset)));
        final dayOfCycle = dayOffset + 1;
        final phase = _classify(date, cycleStart, ovulation, expectedNext);
        final isPredicted = date.isAfter(today);
        final info = CycleDayInfo(
          date: date,
          cycleIndex: idx,
          dayOfCycle: dayOfCycle,
          phase: phase,
          isPredicted: isPredicted,
          isToday: date == today,
          cycleStart: cycleStart,
          expectedNextPeriodStart: expectedNext,
          ovulationDate: ovulation,
        );
        map[date] = info;
      }
    }
    return map;
  }

  CyclePhase _classify(DateTime date, DateTime cycleStart, DateTime ovulation,
      DateTime nextPeriodStart) {
    final periodEnd = cycleStart.add(Duration(days: config.periodLength - 1));
    final fertileStart = ovulation.subtract(const Duration(days: 5));

    if (!_isSameOrAfter(date, cycleStart) ||
        !_isBefore(date, nextPeriodStart)) {
      // Outside cycle range; treat as luteal of previous or ignore; here just bound.
      if (date.isBefore(cycleStart)) return CyclePhase.luteal;
      return CyclePhase.luteal;
    }
    if (!_isAfter(date, periodEnd.subtract(const Duration(days: 1))) &&
        _isSameOrAfter(date, cycleStart)) {
      // Menstrual days
      return CyclePhase.menstrual;
    }
    if (date == ovulation) return CyclePhase.ovulation;
    if (_isSameOrAfter(date, fertileStart) && _isBefore(date, ovulation)) {
      return CyclePhase.fertile;
    }
    if (_isAfter(date, ovulation) && _isBefore(date, nextPeriodStart)) {
      return CyclePhase.luteal;
    }
    // Remaining gap between period end and fertile window start is follicular
    return CyclePhase.follicular;
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
  bool _isSameOrAfter(DateTime a, DateTime b) => !a.isBefore(b);
  bool _isBefore(DateTime a, DateTime b) => a.isBefore(b);
  bool _isAfter(DateTime a, DateTime b) => a.isAfter(b);
}

/// Utility to build a month grid (including leading/trailing days) for a given
/// [month] reference (year & month used). Returns a list of lists (weeks)
/// each containing exactly 7 dates.
List<List<DateTime>> buildMonthMatrix(DateTime month) {
  final first = DateTime(month.year, month.month, 1);
  final firstWeekday = first.weekday; // 1=Mon ... 7=Sun
  // We'll standardize on Monday start; so leading = firstWeekday -1
  final adjustedLeading = firstWeekday - 1; // 0..6
  final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
  final totalCells = ((adjustedLeading + daysInMonth) / 7).ceil() * 7;
  final weeks = <List<DateTime>>[];
  DateTime cursor = first.subtract(Duration(days: adjustedLeading));
  for (int i = 0; i < totalCells; i++) {
    if (i % 7 == 0) weeks.add([]);
    weeks.last.add(cursor);
    cursor = cursor.add(const Duration(days: 1));
  }
  return weeks;
}

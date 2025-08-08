class UserSettings {
  final String name;
  final String loadingName;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? nextStartDate;
  final DateTime? nextEndDate;
  final int cycleLength;
  final bool isFirstTime;

  const UserSettings({
    this.name = '',
    this.loadingName = 'Afia Kyeremaah-Yeboah',
    this.startDate,
    this.endDate,
    this.nextStartDate,
    this.nextEndDate,
    this.cycleLength = 28,
    this.isFirstTime = true,
  });

  UserSettings copyWith({
    String? name,
    String? loadingName,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? nextStartDate,
    DateTime? nextEndDate,
    int? cycleLength,
    bool? isFirstTime,
  }) {
    return UserSettings(
      name: name ?? this.name,
      loadingName: loadingName ?? this.loadingName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      nextStartDate: nextStartDate ?? this.nextStartDate,
      nextEndDate: nextEndDate ?? this.nextEndDate,
      cycleLength: cycleLength ?? this.cycleLength,
      isFirstTime: isFirstTime ?? this.isFirstTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'loadingName': loadingName,
      'startDate': startDate?.millisecondsSinceEpoch,
      'endDate': endDate?.millisecondsSinceEpoch,
      'nextStartDate': nextStartDate?.millisecondsSinceEpoch,
      'nextEndDate': nextEndDate?.millisecondsSinceEpoch,
      'cycleLength': cycleLength,
      'isFirstTime': isFirstTime,
    };
  }

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      name: json['name'] ?? '',
      loadingName: json['loadingName'] ?? 'Afia Kyeremaah-Yeboah',
      startDate: json['startDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['startDate'])
          : null,
      endDate: json['endDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['endDate'])
          : null,
      nextStartDate: json['nextStartDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['nextStartDate'])
          : null,
      nextEndDate: json['nextEndDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['nextEndDate'])
          : null,
      cycleLength: json['cycleLength'] ?? 28,
      isFirstTime: json['isFirstTime'] ?? true,
    );
  }

  bool get isValid {
    return name.isNotEmpty &&
        loadingName.isNotEmpty &&
        startDate != null &&
        endDate != null &&
        startDate!.isBefore(endDate!);
  }

  int get periodLength {
    if (startDate == null || endDate == null) return 5;
    return endDate!.difference(startDate!).inDays + 1;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserSettings &&
        other.name == name &&
        other.loadingName == loadingName &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.nextStartDate == nextStartDate &&
        other.nextEndDate == nextEndDate &&
        other.cycleLength == cycleLength &&
        other.isFirstTime == isFirstTime;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        loadingName.hashCode ^
        startDate.hashCode ^
        endDate.hashCode ^
        nextStartDate.hashCode ^
        nextEndDate.hashCode ^
        cycleLength.hashCode ^
        isFirstTime.hashCode;
  }
}

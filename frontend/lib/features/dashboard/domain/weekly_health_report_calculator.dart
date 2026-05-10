class WeeklyHealthReport {
  const WeeklyHealthReport({
    required this.bmi,
    required this.bloodPressure,
    required this.temperature,
  });

  factory WeeklyHealthReport.empty() {
    return const WeeklyHealthReport(
      bmi: WeeklyHealthMetricSummary.empty(unit: 'kg/m²'),
      bloodPressure: WeeklyHealthMetricSummary.empty(unit: 'mmHg'),
      temperature: WeeklyHealthMetricSummary.empty(unit: '°C'),
    );
  }

  final WeeklyHealthMetricSummary bmi;
  final WeeklyHealthMetricSummary bloodPressure;
  final WeeklyHealthMetricSummary temperature;
}

class WeeklyHealthMetricSummary {
  const WeeklyHealthMetricSummary({
    required this.value,
    required this.unit,
    required this.hasData,
    required this.entryCount,
  });

  const WeeklyHealthMetricSummary.empty({required this.unit})
    : value = '--',
      hasData = false,
      entryCount = 0;

  final String value;
  final String unit;
  final bool hasData;
  final int entryCount;
}

class WeeklyBmiReading {
  const WeeklyBmiReading({required this.value, required this.recordedAt});

  final double value;
  final DateTime recordedAt;
}

class WeeklyBloodPressureReading {
  const WeeklyBloodPressureReading({
    required this.systolic,
    required this.diastolic,
    required this.recordedAt,
  });

  final int systolic;
  final int diastolic;
  final DateTime recordedAt;
}

class WeeklyTemperatureReading {
  const WeeklyTemperatureReading({
    required this.celsius,
    required this.recordedAt,
  });

  final double celsius;
  final DateTime recordedAt;
}

WeeklyHealthReport calculateWeeklyHealthReport({
  required List<WeeklyBmiReading> bmiReadings,
  required List<WeeklyBloodPressureReading> bloodPressureReadings,
  required List<WeeklyTemperatureReading> temperatureReadings,
  DateTime? now,
}) {
  final today = _startOfDay(now ?? DateTime.now());
  final weekStart = today.subtract(const Duration(days: 6));

  final weeklyBmi = _filterWeek(bmiReadings, weekStart, today);
  final weeklyBloodPressure = _filterWeek(
    bloodPressureReadings,
    weekStart,
    today,
  );
  final weeklyTemperature = _filterWeek(temperatureReadings, weekStart, today);

  return WeeklyHealthReport(
    bmi: _buildDecimalSummary(
      unit: 'kg/m²',
      readings: weeklyBmi,
      valueOf: (reading) => reading.value,
    ),
    bloodPressure: _buildBloodPressureSummary(weeklyBloodPressure),
    temperature: _buildDecimalSummary(
      unit: '°C',
      readings: weeklyTemperature,
      valueOf: (reading) => reading.celsius,
    ),
  );
}

WeeklyHealthMetricSummary _buildDecimalSummary<T extends Object>({
  required String unit,
  required List<T> readings,
  required double Function(T reading) valueOf,
}) {
  if (readings.isEmpty) {
    return WeeklyHealthMetricSummary.empty(unit: unit);
  }

  final latest = readings.reduce(
    (currentLatest, reading) =>
        _recordedAtOf(reading).isAfter(_recordedAtOf(currentLatest))
        ? reading
        : currentLatest,
  );

  return WeeklyHealthMetricSummary(
    value: valueOf(latest).toStringAsFixed(1),
    unit: unit,
    hasData: true,
    entryCount: readings.length,
  );
}

WeeklyHealthMetricSummary _buildBloodPressureSummary(
  List<WeeklyBloodPressureReading> readings,
) {
  if (readings.isEmpty) {
    return const WeeklyHealthMetricSummary.empty(unit: 'mmHg');
  }

  final latest = readings.reduce(
    (currentLatest, reading) =>
        reading.recordedAt.isAfter(currentLatest.recordedAt)
        ? reading
        : currentLatest,
  );

  return WeeklyHealthMetricSummary(
    value: '${latest.systolic}/${latest.diastolic}',
    unit: 'mmHg',
    hasData: true,
    entryCount: readings.length,
  );
}

List<T> _filterWeek<T extends Object>(
  List<T> readings,
  DateTime weekStart,
  DateTime today,
) {
  final weekEnd = today.add(const Duration(days: 1));
  final filtered = readings
      .where((reading) {
        final recordedAt = _recordedAtOf(reading).toLocal();
        return !recordedAt.isBefore(weekStart) && recordedAt.isBefore(weekEnd);
      })
      .toList(growable: false);

  filtered.sort((a, b) => _recordedAtOf(a).compareTo(_recordedAtOf(b)));
  return filtered;
}

DateTime _recordedAtOf(Object reading) {
  return switch (reading) {
    WeeklyBmiReading(:final recordedAt) => recordedAt,
    WeeklyBloodPressureReading(:final recordedAt) => recordedAt,
    WeeklyTemperatureReading(:final recordedAt) => recordedAt,
    _ => throw ArgumentError.value(
      reading,
      'reading',
      'Unsupported reading type',
    ),
  };
}

DateTime _startOfDay(DateTime value) {
  final local = value.toLocal();
  return DateTime(local.year, local.month, local.day);
}

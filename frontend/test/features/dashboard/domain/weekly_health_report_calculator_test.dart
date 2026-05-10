import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/dashboard/domain/weekly_health_report_calculator.dart';

void main() {
  group('calculateWeeklyHealthReport', () {
    test('uses latest weekly readings and counts entries in the week', () {
      final now = DateTime(2026, 5, 10, 12);

      final report = calculateWeeklyHealthReport(
        now: now,
        bmiReadings: <WeeklyBmiReading>[
          WeeklyBmiReading(value: 25.0, recordedAt: DateTime(2026, 5, 1, 9)),
          WeeklyBmiReading(value: 23.0, recordedAt: DateTime(2026, 5, 8, 9)),
          WeeklyBmiReading(value: 24.0, recordedAt: DateTime(2026, 5, 8, 18)),
          WeeklyBmiReading(value: 23.6, recordedAt: DateTime(2026, 5, 10, 8)),
        ],
        bloodPressureReadings: <WeeklyBloodPressureReading>[
          WeeklyBloodPressureReading(
            systolic: 118,
            diastolic: 78,
            recordedAt: DateTime(2026, 5, 7, 8),
          ),
          WeeklyBloodPressureReading(
            systolic: 122,
            diastolic: 82,
            recordedAt: DateTime(2026, 5, 9, 8),
          ),
          WeeklyBloodPressureReading(
            systolic: 120,
            diastolic: 80,
            recordedAt: DateTime(2026, 5, 10, 8),
          ),
        ],
        temperatureReadings: <WeeklyTemperatureReading>[
          WeeklyTemperatureReading(
            celsius: 36.4,
            recordedAt: DateTime(2026, 5, 5, 8),
          ),
          WeeklyTemperatureReading(
            celsius: 36.8,
            recordedAt: DateTime(2026, 5, 10, 8),
          ),
        ],
      );

      expect(report.bmi.value, '23.6');
      expect(report.bmi.unit, 'kg/m²');
      expect(report.bmi.entryCount, 3);
      expect(report.bloodPressure.value, '120/80');
      expect(report.bloodPressure.entryCount, 3);
      expect(report.temperature.value, '36.8');
      expect(report.temperature.entryCount, 2);
    });

    test('returns empty summaries when there are no readings in the week', () {
      final report = calculateWeeklyHealthReport(
        now: DateTime(2026, 5, 10, 12),
        bmiReadings: <WeeklyBmiReading>[
          WeeklyBmiReading(value: 22.0, recordedAt: DateTime(2026, 4, 1, 9)),
        ],
        bloodPressureReadings: const <WeeklyBloodPressureReading>[],
        temperatureReadings: const <WeeklyTemperatureReading>[],
      );

      expect(report.bmi.value, '--');
      expect(report.bmi.entryCount, 0);
      expect(report.bloodPressure.value, '--');
      expect(report.bloodPressure.entryCount, 0);
      expect(report.temperature.value, '--');
      expect(report.temperature.entryCount, 0);
    });
  });
}

import '../../phr/data/personal_records_api_client.dart';
import '../domain/weekly_health_report_calculator.dart';

class WeeklyHealthReportRepository {
  WeeklyHealthReportRepository({PersonalRecordsApiClient? apiClient})
    : _apiClient = apiClient ?? PersonalRecordsApiClient.instance;

  final PersonalRecordsApiClient _apiClient;

  Future<WeeklyHealthReport> loadWeeklyHealthReport({
    required String accessToken,
    DateTime? now,
  }) async {
    final bmiResponse = await _apiClient.getBmiRecords(
      accessToken: accessToken,
    );
    final bloodPressureResponse = await _apiClient.getBloodPressureRecords(
      accessToken: accessToken,
    );
    final temperatureResponse = await _apiClient.getTemperatureRecords(
      accessToken: accessToken,
    );

    return calculateWeeklyHealthReport(
      bmiReadings: bmiResponse.records
          .map(
            (record) => WeeklyBmiReading(
              value: record.bmiValue,
              recordedAt: record.recordedAt,
            ),
          )
          .toList(growable: false),
      bloodPressureReadings: bloodPressureResponse.records
          .map(
            (record) => WeeklyBloodPressureReading(
              systolic: record.systolicMmHg,
              diastolic: record.diastolicMmHg,
              recordedAt: record.recordedAt,
            ),
          )
          .toList(growable: false),
      temperatureReadings: temperatureResponse.records
          .map(
            (record) => WeeklyTemperatureReading(
              celsius: record.normalizedCelsius,
              recordedAt: record.recordedAt,
            ),
          )
          .toList(growable: false),
      now: now,
    );
  }
}

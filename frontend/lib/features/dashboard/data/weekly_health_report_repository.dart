import '../../phr/data/personal_records_api_client.dart';
import 'weekly_health_report_local_store.dart';
import '../domain/weekly_health_report_calculator.dart';

class WeeklyHealthReportRepository {
  WeeklyHealthReportRepository({
    PersonalRecordsApiClient? apiClient,
    WeeklyHealthReportLocalStore? localStore,
  }) : _apiClient = apiClient ?? PersonalRecordsApiClient.instance,
       _localStore = localStore ?? WeeklyHealthReportLocalStore();

  final PersonalRecordsApiClient _apiClient;
  final WeeklyHealthReportLocalStore _localStore;

  Future<WeeklyHealthReport?> loadCachedWeeklyHealthReport({
    required String cacheKey,
  }) {
    return _localStore.read(cacheKey: cacheKey);
  }

  Future<WeeklyHealthReport> loadWeeklyHealthReport({
    required String accessToken,
    required String cacheKey,
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

    final report = calculateWeeklyHealthReport(
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

    await _localStore.write(cacheKey: cacheKey, report: report);
    return report;
  }
}

import 'personal_records_api_client.dart';
import 'personal_records_local_store.dart';

enum PersonalRecordSection {
  bmi('bmi'),
  bloodPressure('blood-pressure'),
  temperature('temperature'),
  medicineIntake('medicine-intake');

  const PersonalRecordSection(this.pathSegment);
  final String pathSegment;
}

class PersonalRecordsRepository {
  PersonalRecordsRepository({
    PersonalRecordsApiClient? apiClient,
    PersonalRecordsLocalStore? localStore,
  }) : _apiClient = apiClient ?? PersonalRecordsApiClient.instance,
       _localStore = localStore ?? PersonalRecordsLocalStore();

  final PersonalRecordsApiClient _apiClient;
  final PersonalRecordsLocalStore _localStore;

  Future<List<BmiRecordResponse>?> loadCachedBmiRecords({
    required String cacheKey,
  }) async {
    final records = await _localStore.readSection(
      cacheKey: cacheKey,
      section: PersonalRecordSection.bmi,
    );
    if (records == null) {
      return null;
    }

    return records.map(BmiRecordResponse.fromJson).toList(growable: false);
  }

  Future<List<BmiRecordResponse>> loadBmiRecords({
    required String accessToken,
    required String cacheKey,
  }) async {
    final response = await _apiClient.getBmiRecords(accessToken: accessToken);
    await cacheBmiRecords(cacheKey: cacheKey, records: response.records);
    return response.records;
  }

  Future<void> cacheBmiRecords({
    required String cacheKey,
    required List<BmiRecordResponse> records,
  }) {
    return _localStore.writeSection(
      cacheKey: cacheKey,
      section: PersonalRecordSection.bmi,
      records: records.map((record) => record.toJson()).toList(growable: false),
    );
  }

  Future<List<BloodPressureRecordResponse>?> loadCachedBloodPressureRecords({
    required String cacheKey,
  }) async {
    final records = await _localStore.readSection(
      cacheKey: cacheKey,
      section: PersonalRecordSection.bloodPressure,
    );
    if (records == null) {
      return null;
    }

    return records
        .map(BloodPressureRecordResponse.fromJson)
        .toList(growable: false);
  }

  Future<List<BloodPressureRecordResponse>> loadBloodPressureRecords({
    required String accessToken,
    required String cacheKey,
  }) async {
    final response = await _apiClient.getBloodPressureRecords(
      accessToken: accessToken,
    );
    await cacheBloodPressureRecords(cacheKey: cacheKey, records: response.records);
    return response.records;
  }

  Future<void> cacheBloodPressureRecords({
    required String cacheKey,
    required List<BloodPressureRecordResponse> records,
  }) {
    return _localStore.writeSection(
      cacheKey: cacheKey,
      section: PersonalRecordSection.bloodPressure,
      records: records.map((record) => record.toJson()).toList(growable: false),
    );
  }

  Future<List<TemperatureRecordResponse>?> loadCachedTemperatureRecords({
    required String cacheKey,
  }) async {
    final records = await _localStore.readSection(
      cacheKey: cacheKey,
      section: PersonalRecordSection.temperature,
    );
    if (records == null) {
      return null;
    }

    return records
        .map(TemperatureRecordResponse.fromJson)
        .toList(growable: false);
  }

  Future<List<TemperatureRecordResponse>> loadTemperatureRecords({
    required String accessToken,
    required String cacheKey,
  }) async {
    final response = await _apiClient.getTemperatureRecords(
      accessToken: accessToken,
    );
    await cacheTemperatureRecords(cacheKey: cacheKey, records: response.records);
    return response.records;
  }

  Future<void> cacheTemperatureRecords({
    required String cacheKey,
    required List<TemperatureRecordResponse> records,
  }) {
    return _localStore.writeSection(
      cacheKey: cacheKey,
      section: PersonalRecordSection.temperature,
      records: records.map((record) => record.toJson()).toList(growable: false),
    );
  }

  Future<List<MedicationIntakeRecordResponse>?>
  loadCachedMedicationIntakeRecords({required String cacheKey}) async {
    final records = await _localStore.readSection(
      cacheKey: cacheKey,
      section: PersonalRecordSection.medicineIntake,
    );
    if (records == null) {
      return null;
    }

    return records
        .map(MedicationIntakeRecordResponse.fromJson)
        .toList(growable: false);
  }

  Future<List<MedicationIntakeRecordResponse>> loadMedicationIntakeRecords({
    required String accessToken,
    required String cacheKey,
  }) async {
    final response = await _apiClient.getMedicationIntakeRecords(
      accessToken: accessToken,
    );
    await cacheMedicationIntakeRecords(
      cacheKey: cacheKey,
      records: response.records,
    );
    return response.records;
  }

  Future<void> cacheMedicationIntakeRecords({
    required String cacheKey,
    required List<MedicationIntakeRecordResponse> records,
  }) {
    return _localStore.writeSection(
      cacheKey: cacheKey,
      section: PersonalRecordSection.medicineIntake,
      records: records.map((record) => record.toJson()).toList(growable: false),
    );
  }
}

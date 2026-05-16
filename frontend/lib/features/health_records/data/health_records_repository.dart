import 'health_records_api_client.dart';
import 'health_records_local_store.dart';

class HealthRecordsRepository {
  HealthRecordsRepository({
    HealthRecordsApiClient? apiClient,
    HealthRecordsLocalStore? localStore,
  }) : _apiClient = apiClient ?? HealthRecordsApiClient.instance,
       _localStore = localStore ?? HealthRecordsLocalStore();

  final HealthRecordsApiClient _apiClient;
  final HealthRecordsLocalStore _localStore;

  Future<List<HealthRecordResponse>?> loadCachedRecords({
    required String cacheKey,
    required HealthRecordSection section,
  }) {
    return _localStore.readSection(cacheKey: cacheKey, section: section);
  }

  Future<List<HealthRecordResponse>> loadRecords({
    required String accessToken,
    required String cacheKey,
    required HealthRecordSection section,
  }) async {
    final response = await _apiClient.getRecords(
      section: section,
      accessToken: accessToken,
    );
    await _localStore.writeSection(
      cacheKey: cacheKey,
      section: section,
      records: response.records,
    );
    return response.records;
  }
}

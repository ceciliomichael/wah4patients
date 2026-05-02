import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/app_environment.dart';

class PersonalRecordsApiException implements Exception {
  const PersonalRecordsApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;
}

class BmiRecordResponse {
  const BmiRecordResponse({
    required this.id,
    required this.profileId,
    required this.weightKg,
    required this.heightCm,
    required this.bmiValue,
    required this.manualBmiValue,
    required this.bmiSource,
    required this.measurementSystem,
    required this.notes,
    required this.recordedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String profileId;
  final double weightKg;
  final double heightCm;
  final double bmiValue;
  final double? manualBmiValue;
  final String bmiSource;
  final String measurementSystem;
  final String? notes;
  final DateTime recordedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory BmiRecordResponse.fromJson(Map<String, dynamic> json) {
    return BmiRecordResponse(
      id: _readString(json['id']),
      profileId: _readString(json['profileId']),
      weightKg: _readDouble(json['weightKg']),
      heightCm: _readDouble(json['heightCm']),
      bmiValue: _readDouble(json['bmiValue']),
      manualBmiValue: _readNullableDouble(json['manualBmiValue']),
      bmiSource: _readString(json['bmiSource']),
      measurementSystem: _readString(json['measurementSystem']),
      notes: _readNullableString(json['notes']),
      recordedAt: _readDateTime(json['recordedAt']),
      createdAt: _readDateTime(json['createdAt']),
      updatedAt: _readDateTime(json['updatedAt']),
    );
  }
}

class BmiRecordsResponse {
  const BmiRecordsResponse({required this.records});

  final List<BmiRecordResponse> records;

  factory BmiRecordsResponse.fromJson(Map<String, dynamic> json) {
    final recordsJson = json['records'];
    if (recordsJson is! List) {
      return const BmiRecordsResponse(records: <BmiRecordResponse>[]);
    }

    return BmiRecordsResponse(
      records: recordsJson
          .whereType<Map<String, dynamic>>()
          .map(BmiRecordResponse.fromJson)
          .toList(growable: false),
    );
  }
}

class BloodPressureRecordResponse {
  const BloodPressureRecordResponse({
    required this.id,
    required this.profileId,
    required this.systolicMmHg,
    required this.diastolicMmHg,
    required this.pulseRate,
    required this.measurementPosition,
    required this.measurementMethod,
    required this.notes,
    required this.recordedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String profileId;
  final int systolicMmHg;
  final int diastolicMmHg;
  final int? pulseRate;
  final String? measurementPosition;
  final String? measurementMethod;
  final String? notes;
  final DateTime recordedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory BloodPressureRecordResponse.fromJson(Map<String, dynamic> json) {
    return BloodPressureRecordResponse(
      id: _readString(json['id']),
      profileId: _readString(json['profileId']),
      systolicMmHg: _readInt(json['systolicMmHg']),
      diastolicMmHg: _readInt(json['diastolicMmHg']),
      pulseRate: _readNullableInt(json['pulseRate']),
      measurementPosition: _readNullableString(json['measurementPosition']),
      measurementMethod: _readNullableString(json['measurementMethod']),
      notes: _readNullableString(json['notes']),
      recordedAt: _readDateTime(json['recordedAt']),
      createdAt: _readDateTime(json['createdAt']),
      updatedAt: _readDateTime(json['updatedAt']),
    );
  }
}

class BloodPressureRecordsResponse {
  const BloodPressureRecordsResponse({required this.records});

  final List<BloodPressureRecordResponse> records;

  factory BloodPressureRecordsResponse.fromJson(Map<String, dynamic> json) {
    final recordsJson = json['records'];
    if (recordsJson is! List) {
      return const BloodPressureRecordsResponse(records: <BloodPressureRecordResponse>[]);
    }

    return BloodPressureRecordsResponse(
      records: recordsJson
          .whereType<Map<String, dynamic>>()
          .map(BloodPressureRecordResponse.fromJson)
          .toList(growable: false),
    );
  }
}

class TemperatureRecordResponse {
  const TemperatureRecordResponse({
    required this.id,
    required this.profileId,
    required this.temperatureValue,
    required this.temperatureUnit,
    required this.normalizedCelsius,
    required this.measurementMethod,
    required this.notes,
    required this.recordedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String profileId;
  final double temperatureValue;
  final String temperatureUnit;
  final double normalizedCelsius;
  final String? measurementMethod;
  final String? notes;
  final DateTime recordedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory TemperatureRecordResponse.fromJson(Map<String, dynamic> json) {
    return TemperatureRecordResponse(
      id: _readString(json['id']),
      profileId: _readString(json['profileId']),
      temperatureValue: _readDouble(json['temperatureValue']),
      temperatureUnit: _readString(json['temperatureUnit']),
      normalizedCelsius: _readDouble(json['normalizedCelsius']),
      measurementMethod: _readNullableString(json['measurementMethod']),
      notes: _readNullableString(json['notes']),
      recordedAt: _readDateTime(json['recordedAt']),
      createdAt: _readDateTime(json['createdAt']),
      updatedAt: _readDateTime(json['updatedAt']),
    );
  }
}

class TemperatureRecordsResponse {
  const TemperatureRecordsResponse({required this.records});

  final List<TemperatureRecordResponse> records;

  factory TemperatureRecordsResponse.fromJson(Map<String, dynamic> json) {
    final recordsJson = json['records'];
    if (recordsJson is! List) {
      return const TemperatureRecordsResponse(records: <TemperatureRecordResponse>[]);
    }

    return TemperatureRecordsResponse(
      records: recordsJson
          .whereType<Map<String, dynamic>>()
          .map(TemperatureRecordResponse.fromJson)
          .toList(growable: false),
    );
  }
}

class MedicationIntakeRecordResponse {
  const MedicationIntakeRecordResponse({
    required this.id,
    required this.profileId,
    required this.prescriptionId,
    required this.medicationReference,
    required this.medicationNameSnapshot,
    required this.scheduledAt,
    required this.takenAt,
    required this.status,
    required this.quantityValue,
    required this.quantityUnit,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String profileId;
  final String? prescriptionId;
  final String? medicationReference;
  final String medicationNameSnapshot;
  final DateTime scheduledAt;
  final DateTime? takenAt;
  final String status;
  final double? quantityValue;
  final String? quantityUnit;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory MedicationIntakeRecordResponse.fromJson(Map<String, dynamic> json) {
    return MedicationIntakeRecordResponse(
      id: _readString(json['id']),
      profileId: _readString(json['profileId']),
      prescriptionId: _readNullableString(json['prescriptionId']),
      medicationReference: _readNullableString(json['medicationReference']),
      medicationNameSnapshot: _readString(json['medicationNameSnapshot']),
      scheduledAt: _readDateTime(json['scheduledAt']),
      takenAt: _readNullableDateTime(json['takenAt']),
      status: _readString(json['status']),
      quantityValue: _readNullableDouble(json['quantityValue']),
      quantityUnit: _readNullableString(json['quantityUnit']),
      notes: _readNullableString(json['notes']),
      createdAt: _readDateTime(json['createdAt']),
      updatedAt: _readDateTime(json['updatedAt']),
    );
  }
}

class MedicationIntakeRecordsResponse {
  const MedicationIntakeRecordsResponse({required this.records});

  final List<MedicationIntakeRecordResponse> records;

  factory MedicationIntakeRecordsResponse.fromJson(Map<String, dynamic> json) {
    final recordsJson = json['records'];
    if (recordsJson is! List) {
      return const MedicationIntakeRecordsResponse(records: <MedicationIntakeRecordResponse>[]);
    }

    return MedicationIntakeRecordsResponse(
      records: recordsJson
          .whereType<Map<String, dynamic>>()
          .map(MedicationIntakeRecordResponse.fromJson)
          .toList(growable: false),
    );
  }
}

class PersonalRecordsApiClient {
  PersonalRecordsApiClient({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  static final PersonalRecordsApiClient instance = PersonalRecordsApiClient();

  final http.Client _httpClient;

  Future<BmiRecordsResponse> getBmiRecords({required String accessToken}) async {
    final response = await _get(
      path: '/phr/bmi-records',
      bearerToken: accessToken,
    );
    return BmiRecordsResponse.fromJson(response);
  }

  Future<BmiRecordResponse> createBmiRecord({
    required String accessToken,
    required double weightValue,
    required double heightValue,
    required String measurementSystem,
    double? manualBmiValue,
    String? notes,
  }) async {
    final response = await _post(
      path: '/phr/bmi-records',
      body: <String, dynamic>{
        'weightValue': weightValue,
        'heightValue': heightValue,
        'measurementSystem': measurementSystem,
        if (manualBmiValue != null) 'manualBmiValue': manualBmiValue,
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      },
      bearerToken: accessToken,
    );
    return BmiRecordResponse.fromJson(response);
  }

  Future<BloodPressureRecordsResponse> getBloodPressureRecords({
    required String accessToken,
  }) async {
    final response = await _get(
      path: '/phr/blood-pressure-records',
      bearerToken: accessToken,
    );
    return BloodPressureRecordsResponse.fromJson(response);
  }

  Future<BloodPressureRecordResponse> createBloodPressureRecord({
    required String accessToken,
    required int systolicMmHg,
    required int diastolicMmHg,
    int? pulseRate,
    String? measurementPosition,
    String? measurementMethod,
    String? notes,
  }) async {
    final response = await _post(
      path: '/phr/blood-pressure-records',
      body: <String, dynamic>{
        'systolicMmHg': systolicMmHg,
        'diastolicMmHg': diastolicMmHg,
        if (pulseRate != null) 'pulseRate': pulseRate,
        if (measurementPosition != null && measurementPosition.trim().isNotEmpty)
          'measurementPosition': measurementPosition.trim(),
        if (measurementMethod != null && measurementMethod.trim().isNotEmpty)
          'measurementMethod': measurementMethod.trim(),
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      },
      bearerToken: accessToken,
    );
    return BloodPressureRecordResponse.fromJson(response);
  }

  Future<TemperatureRecordsResponse> getTemperatureRecords({
    required String accessToken,
  }) async {
    final response = await _get(
      path: '/phr/temperature-records',
      bearerToken: accessToken,
    );
    return TemperatureRecordsResponse.fromJson(response);
  }

  Future<TemperatureRecordResponse> createTemperatureRecord({
    required String accessToken,
    required double temperatureValue,
    required String temperatureUnit,
    String? measurementMethod,
    String? notes,
  }) async {
    final response = await _post(
      path: '/phr/temperature-records',
      body: <String, dynamic>{
        'temperatureValue': temperatureValue,
        'temperatureUnit': temperatureUnit,
        if (measurementMethod != null && measurementMethod.trim().isNotEmpty)
          'measurementMethod': measurementMethod.trim(),
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      },
      bearerToken: accessToken,
    );
    return TemperatureRecordResponse.fromJson(response);
  }

  Future<MedicationIntakeRecordsResponse> getMedicationIntakeRecords({
    required String accessToken,
  }) async {
    final response = await _get(
      path: '/phr/medication-intake-records',
      bearerToken: accessToken,
    );
    return MedicationIntakeRecordsResponse.fromJson(response);
  }

  Future<MedicationIntakeRecordResponse> createMedicationIntakeRecord({
    required String accessToken,
    required String medicationNameSnapshot,
    required DateTime scheduledAt,
    required String status,
    String? prescriptionId,
    String? medicationReference,
    DateTime? takenAt,
    double? quantityValue,
    String? quantityUnit,
    String? notes,
  }) async {
    final response = await _post(
      path: '/phr/medication-intake-records',
      body: <String, dynamic>{
        'medicationNameSnapshot': medicationNameSnapshot.trim(),
        'scheduledAt': scheduledAt.toUtc().toIso8601String(),
        'status': status,
        if (prescriptionId != null && prescriptionId.trim().isNotEmpty)
          'prescriptionId': prescriptionId.trim(),
        if (medicationReference != null && medicationReference.trim().isNotEmpty)
          'medicationReference': medicationReference.trim(),
        if (takenAt != null) 'takenAt': takenAt.toUtc().toIso8601String(),
        if (quantityValue != null) 'quantityValue': quantityValue,
        if (quantityUnit != null && quantityUnit.trim().isNotEmpty)
          'quantityUnit': quantityUnit.trim(),
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      },
      bearerToken: accessToken,
    );
    return MedicationIntakeRecordResponse.fromJson(response);
  }

  Future<Map<String, dynamic>> _get({
    required String path,
    String? bearerToken,
  }) async {
    await AppEnvironment.load();

    if (!AppEnvironment.isAuthApiConfigured) {
      throw const PersonalRecordsApiException(
        'Missing auth API config. Set BACKEND_BASE_URL and BACKEND_API_KEY in frontend/.env.',
      );
    }

    final uri = _buildUri(path);
    final headers = _buildHeaders(bearerToken);

    late final http.Response response;
    try {
      response = await _httpClient
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 20));
    } on TimeoutException {
      throw const PersonalRecordsApiException(
        'Request timed out. Please ensure the backend is running and try again.',
      );
    } on http.ClientException {
      throw const PersonalRecordsApiException(
        'Unable to reach the backend. Check BACKEND_BASE_URL and backend server status.',
      );
    }

    final decodedBody = _decodeResponseBody(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decodedBody;
    }

    throw PersonalRecordsApiException(
      _extractErrorMessage(decodedBody) ??
          'Request failed with status ${response.statusCode}',
      statusCode: response.statusCode,
    );
  }

  Future<Map<String, dynamic>> _post({
    required String path,
    required Map<String, dynamic> body,
    String? bearerToken,
  }) async {
    await AppEnvironment.load();

    if (!AppEnvironment.isAuthApiConfigured) {
      throw const PersonalRecordsApiException(
        'Missing auth API config. Set BACKEND_BASE_URL and BACKEND_API_KEY in frontend/.env.',
      );
    }

    final uri = _buildUri(path);
    final headers = _buildHeaders(bearerToken);

    late final http.Response response;
    try {
      response = await _httpClient
          .post(uri, headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 20));
    } on TimeoutException {
      throw const PersonalRecordsApiException(
        'Request timed out. Please ensure the backend is running and try again.',
      );
    } on http.ClientException {
      throw const PersonalRecordsApiException(
        'Unable to reach the backend. Check BACKEND_BASE_URL and backend server status.',
      );
    }

    final decodedBody = _decodeResponseBody(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decodedBody;
    }

    throw PersonalRecordsApiException(
      _extractErrorMessage(decodedBody) ??
          'Request failed with status ${response.statusCode}',
      statusCode: response.statusCode,
    );
  }

  Uri _buildUri(String path) {
    return Uri.parse('${AppEnvironment.normalizedBackendBaseUrl}$path');
  }

  Map<String, String> _buildHeaders(String? bearerToken) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'x-api-key': AppEnvironment.backendApiKey.trim(),
    };

    final trimmedBearerToken = bearerToken?.trim() ?? '';
    if (trimmedBearerToken.isNotEmpty) {
      headers['authorization'] = 'Bearer $trimmedBearerToken';
    }

    return headers;
  }

  Map<String, dynamic> _decodeResponseBody(String body) {
    if (body.trim().isEmpty) {
      return <String, dynamic>{};
    }

    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return <String, dynamic>{};
  }

  String? _extractErrorMessage(Map<String, dynamic> body) {
    final message = body['message'];
    if (message is String && message.trim().isNotEmpty) {
      return message;
    }

    if (message is List) {
      final firstMessage = message.firstWhere(
        (item) => item is String && item.trim().isNotEmpty,
        orElse: () => null,
      );
      if (firstMessage is String) {
        return firstMessage;
      }
    }

    final error = body['error'];
    if (error is String && error.trim().isNotEmpty) {
      return error;
    }

    return null;
  }
}

String _readString(Object? value) {
  if (value is String && value.trim().isNotEmpty) {
    return value;
  }

  throw const FormatException('Expected string value in API response');
}

double _readDouble(Object? value) {
  if (value is num) {
    return value.toDouble();
  }

  throw const FormatException('Expected numeric value in API response');
}

int _readInt(Object? value) {
  if (value is num) {
    return value.toInt();
  }

  throw const FormatException('Expected integer value in API response');
}

double? _readNullableDouble(Object? value) {
  if (value == null) {
    return null;
  }

  if (value is num) {
    return value.toDouble();
  }

  return null;
}

int? _readNullableInt(Object? value) {
  if (value == null) {
    return null;
  }

  if (value is num) {
    return value.toInt();
  }

  return null;
}

String? _readNullableString(Object? value) {
  if (value is String && value.trim().isNotEmpty) {
    return value;
  }

  return null;
}

DateTime _readDateTime(Object? value) {
  if (value is String && value.trim().isNotEmpty) {
    return DateTime.parse(value);
  }

  throw const FormatException('Expected date-time value in API response');
}

DateTime? _readNullableDateTime(Object? value) {
  if (value is String && value.trim().isNotEmpty) {
    return DateTime.parse(value);
  }

  return null;
}

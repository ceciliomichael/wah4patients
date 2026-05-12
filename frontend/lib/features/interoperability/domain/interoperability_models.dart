import '../../auth/domain/models/auth_api_models.dart';

const String philHealthIdentifierSystem =
    'http://philhealth.gov.ph/fhir/Identifier/philhealth-id';
const String philSysIdentifierSystem =
    'http://philsys.gov.ph/fhir/Identifier/philsys-id';

class SyncIdentifierOption {
  const SyncIdentifierOption({
    required this.fieldKey,
    required this.label,
    required this.systemUri,
    required this.value,
  });

  final String fieldKey;
  final String label;
  final String systemUri;
  final String value;

  bool get hasValue => value.trim().isNotEmpty;
}

class SyncRequestIdentifier {
  const SyncRequestIdentifier({required this.system, required this.value});

  final String system;
  final String value;

  factory SyncRequestIdentifier.fromJson(Map<String, dynamic> json) {
    return SyncRequestIdentifier(
      system: _readString(json['system']),
      value: _readString(json['value']),
    );
  }
}

class InteroperabilityProviderSummary {
  const InteroperabilityProviderSummary({
    required this.id,
    required this.name,
    required this.type,
    required this.facilityCode,
    required this.location,
    required this.isActive,
  });

  final String id;
  final String name;
  final String type;
  final String facilityCode;
  final String location;
  final bool isActive;

  factory InteroperabilityProviderSummary.fromJson(Map<String, dynamic> json) {
    return InteroperabilityProviderSummary(
      id: _readString(json['id']),
      name: _readString(json['name']),
      type: _readString(json['type']),
      facilityCode: _readString(json['facilityCode']),
      location: _readString(json['location']),
      isActive: json['isActive'] == true,
    );
  }
}

class SyncRequestPreview {
  const SyncRequestPreview({
    required this.canSubmit,
    required this.requesterId,
    required this.targetProvider,
    required this.patientIdentifiers,
    required this.resourceType,
    required this.gatewayUrl,
    required this.reason,
    required this.notes,
  });

  final bool canSubmit;
  final String requesterId;
  final InteroperabilityProviderSummary targetProvider;
  final List<SyncRequestIdentifier> patientIdentifiers;
  final String resourceType;
  final String gatewayUrl;
  final String? reason;
  final String? notes;

  factory SyncRequestPreview.fromJson(Map<String, dynamic> json) {
    final identifiersValue = json['patientIdentifiers'];
    final patientIdentifiers = identifiersValue is List
        ? identifiersValue
              .whereType<Map<String, dynamic>>()
              .map(SyncRequestIdentifier.fromJson)
              .toList(growable: false)
        : const <SyncRequestIdentifier>[];

    final providerValue = json['targetProvider'];
    final provider = providerValue is Map<String, dynamic>
        ? InteroperabilityProviderSummary.fromJson(providerValue)
        : InteroperabilityProviderSummary.fromJson(const <String, dynamic>{});

    return SyncRequestPreview(
      canSubmit: json['canSubmit'] == true,
      requesterId: _readString(json['requesterId']),
      targetProvider: provider,
      patientIdentifiers: patientIdentifiers,
      resourceType: _readString(json['resourceType']),
      gatewayUrl: _readString(json['gatewayUrl']),
      reason: _readOptionalString(json['reason']),
      notes: _readOptionalString(json['notes']),
    );
  }
}

class SyncSimulationResult {
  const SyncSimulationResult({
    required this.message,
    required this.transactionId,
    required this.storedResourceTypes,
  });

  final String message;
  final String transactionId;
  final List<String> storedResourceTypes;

  factory SyncSimulationResult.fromJson(Map<String, dynamic> json) {
    final storedResourceTypesValue = json['storedResourceTypes'];
    final storedResourceTypes = storedResourceTypesValue is List
        ? storedResourceTypesValue
              .whereType<String>()
              .map((value) => value.trim())
              .where((value) => value.isNotEmpty)
              .toList(growable: false)
        : const <String>[];

    return SyncSimulationResult(
      message: _readString(json['message']),
      transactionId: _readString(json['transactionId']),
      storedResourceTypes: storedResourceTypes,
    );
  }
}

List<SyncIdentifierOption> buildSyncIdentifierOptions(
  UserProfileSummary profile,
) {
  final options = <SyncIdentifierOption>[];

  final philHealthId = profile.philHealthId.trim();
  if (philHealthId.isNotEmpty) {
    options.add(
      SyncIdentifierOption(
        fieldKey: 'philHealthId',
        label: 'PhilHealth ID',
        systemUri: philHealthIdentifierSystem,
        value: philHealthId,
      ),
    );
  }

  final philSysId = profile.philSysId.trim();
  if (philSysId.isNotEmpty) {
    options.add(
      SyncIdentifierOption(
        fieldKey: 'philSysId',
        label: 'PhilSys ID',
        systemUri: philSysIdentifierSystem,
        value: philSysId,
      ),
    );
  }

  return options;
}

SyncIdentifierOption? syncIdentifierOptionForFieldKey(
  Iterable<SyncIdentifierOption> options,
  String fieldKey,
) {
  for (final option in options) {
    if (option.fieldKey == fieldKey) {
      return option;
    }
  }

  return null;
}

String _readString(Object? value) {
  if (value is String) {
    return value;
  }

  return '';
}

String? _readOptionalString(Object? value) {
  final text = _readString(value).trim();
  return text.isNotEmpty ? text : null;
}

import '../../auth/domain/models/auth_api_models.dart';

class ProfileSyncReadiness {
  const ProfileSyncReadiness({
    required this.isReady,
    required this.missingRequirements,
  });

  final bool isReady;
  final List<String> missingRequirements;
}

ProfileSyncReadiness evaluateProfileSyncReadiness(UserProfileSummary profile) {
  final missingRequirements = <String>[];
  final seenRequirements = <String>{};

  void addRequirement(String requirement) {
    final trimmedRequirement = requirement.trim();
    if (trimmedRequirement.isEmpty) {
      return;
    }
    if (seenRequirements.add(trimmedRequirement)) {
      missingRequirements.add(trimmedRequirement);
    }
  }

  for (final field in profile.missingFields) {
    final label = _formatFieldLabel(field);
    if (label.isEmpty) {
      continue;
    }

    if (label == 'PhilHealth ID' || label == 'PhilSys ID') {
      continue;
    }

    addRequirement(label);
  }

  final hasIdentifier =
      profile.philHealthId.trim().isNotEmpty ||
      profile.philSysId.trim().isNotEmpty;
  if (!hasIdentifier) {
    addRequirement('PhilHealth ID or PhilSys ID');
  }

  return ProfileSyncReadiness(
    isReady: hasIdentifier,
    missingRequirements: List.unmodifiable(missingRequirements),
  );
}

String _formatFieldLabel(String rawFieldName) {
  final trimmed = rawFieldName.trim();
  if (trimmed.isEmpty) {
    return '';
  }

  const knownLabels = <String, String>{
    'birthDate': 'Birth date',
    'phoneNumber': 'Phone number',
    'communicationLanguage': 'Communication language',
    'philHealthId': 'PhilHealth ID',
    'philSysId': 'PhilSys ID',
    'addressLine1': 'Address line 1',
    'addressLine2': 'Address line 2',
    'postalCode': 'Postal code',
    'genderIdentity': 'Gender identity',
    'emergencyContactName': 'Emergency contact name',
    'emergencyContactPhone': 'Emergency contact phone',
  };

  final knownLabel = knownLabels[trimmed];
  if (knownLabel != null) {
    return knownLabel;
  }

  final normalized = trimmed
      .replaceAll(RegExp(r'[_-]+'), ' ')
      .replaceAllMapped(
        RegExp(r'([a-z0-9])([A-Z])'),
        (match) => '${match[1]} ${match[2]}',
      );

  return normalized
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .map((part) => part[0].toUpperCase() + part.substring(1))
      .join(' ');
}

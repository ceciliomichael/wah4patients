const Map<String, String> _maritalStatusLabelsByCode = <String, String>{
  'S': 'Single',
  'M': 'Married',
  'D': 'Divorced',
  'W': 'Widowed',
};

const Map<String, String> _maritalStatusCodesByLabel = <String, String>{
  'single': 'S',
  'married': 'M',
  'divorced': 'D',
  'widowed': 'W',
};

String displayMaritalStatusLabel(String rawValue) {
  final value = rawValue.trim();
  if (value.isEmpty) {
    return '';
  }

  final label = _maritalStatusLabelsByCode[value.toUpperCase()];
  if (label != null) {
    return label;
  }

  final normalized = value.toLowerCase();
  final canonicalCode = _maritalStatusCodesByLabel[normalized];
  if (canonicalCode != null) {
    return _maritalStatusLabelsByCode[canonicalCode] ?? value;
  }

  return value;
}

String normalizeMaritalStatusValue(String rawValue) {
  final value = rawValue.trim();
  if (value.isEmpty) {
    return '';
  }

  final directCode = value.toUpperCase();
  if (_maritalStatusLabelsByCode.containsKey(directCode)) {
    return directCode;
  }

  final canonicalCode = _maritalStatusCodesByLabel[value.toLowerCase()];
  if (canonicalCode != null) {
    return canonicalCode;
  }

  return value;
}

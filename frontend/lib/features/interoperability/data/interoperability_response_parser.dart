import 'dart:convert';

/// Decodes interoperability API responses while ignoring HTML error pages.
///
/// The backend only expects JSON payloads for successful interoperability
/// requests. If a gateway or proxy returns HTML or any other non-JSON body,
/// this helper intentionally drops the body so callers can fall back to a
/// generic status-based error message instead of surfacing raw markup.
Map<String, dynamic> decodeInteroperabilityResponseBody(
  String body, {
  required String contentType,
}) {
  final trimmed = body.trim();
  if (trimmed.isEmpty) {
    return <String, dynamic>{};
  }

  final isJsonResponse = contentType.toLowerCase().contains('application/json');
  if (!isJsonResponse) {
    return <String, dynamic>{};
  }

  try {
    final decoded = jsonDecode(trimmed);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    if (decoded is List) {
      return <String, dynamic>{'data': decoded};
    }
  } on FormatException {
    return <String, dynamic>{};
  }

  return <String, dynamic>{};
}

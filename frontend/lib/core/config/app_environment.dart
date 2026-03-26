import 'package:flutter/services.dart' show rootBundle;

class AppEnvironment {
  AppEnvironment._();

  static const String _configAssetPath = '.env';
  static const String _defaultBackendBaseUrl = 'http://localhost:3000/api/v1';

  static String _backendBaseUrl = _defaultBackendBaseUrl;
  static String _backendApiKey = '';
  static bool _loaded = false;

  static Future<void> load() async {
    if (_loaded) {
      return;
    }

    try {
      final configContent = await rootBundle.loadString(_configAssetPath);
      final values = _parseKeyValueContent(configContent);
      _backendBaseUrl =
          values['BACKEND_BASE_URL']?.trim().isNotEmpty == true
              ? values['BACKEND_BASE_URL']!.trim()
              : _defaultBackendBaseUrl;
      _backendApiKey = values['BACKEND_API_KEY']?.trim() ?? '';
    } catch (_) {
      _backendBaseUrl = _defaultBackendBaseUrl;
      _backendApiKey = '';
    } finally {
      _loaded = true;
    }
  }

  static String get backendBaseUrl {
    return _backendBaseUrl;
  }

  static String get backendApiKey {
    return _backendApiKey;
  }

  static String get normalizedBackendBaseUrl {
    final trimmed = backendBaseUrl.trim();
    if (trimmed.endsWith('/')) {
      return trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }

  static bool get isAuthApiConfigured {
    return normalizedBackendBaseUrl.isNotEmpty && backendApiKey.trim().isNotEmpty;
  }

  static Map<String, String> _parseKeyValueContent(String content) {
    final values = <String, String>{};

    for (final rawLine in content.split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty || line.startsWith('#') || !line.contains('=')) {
        continue;
      }

      final equalsIndex = line.indexOf('=');
      final key = line.substring(0, equalsIndex).trim();
      final value = line.substring(equalsIndex + 1).trim();
      if (key.isNotEmpty) {
        values[key] = value;
      }
    }

    return values;
  }
}

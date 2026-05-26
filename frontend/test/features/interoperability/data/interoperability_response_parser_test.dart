import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/interoperability/data/interoperability_response_parser.dart';

void main() {
  test('ignores HTML bodies returned by proxies or gateways', () {
    final decoded = decodeInteroperabilityResponseBody(
      '<!doctype html><html><body>503 - Service unavailable</body></html>',
      contentType: 'text/html',
    );

    expect(decoded, isEmpty);
  });

  test('parses JSON bodies when the response is JSON', () {
    final decoded = decodeInteroperabilityResponseBody(
      '{"message":"ok","status":200}',
      contentType: 'application/json; charset=utf-8',
    );

    expect(decoded['message'], 'ok');
    expect(decoded['status'], 200);
  });
}

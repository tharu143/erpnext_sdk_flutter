/// Parses the 'set-cookie' header and returns a map of cookie names to values.
Map<String, String> parseSetCookie(String setCookieValue) {
  final cookies = <String, String>{};
  final parts = setCookieValue.split(',');
  for (var part in parts) {
    final cookiePart = part.split(';').first.trim();
    final equalsIndex = cookiePart.indexOf('=');
    if (equalsIndex > 0) {
      final name = cookiePart.substring(0, equalsIndex);
      final value = cookiePart.substring(equalsIndex + 1);
      cookies[name] = value;
    }
  }
  return cookies;
}

/// Helper to format error messages from ERPNext responses
String extractErrorMessage(dynamic body) {
  if (body is! Map) return body.toString();

  if (body.containsKey('exception')) {
    return body['exception'].toString();
  }
  if (body.containsKey('message')) {
    // Sometimes message is a string, sometimes a list, sometimes JSON
    return body['message'].toString();
  }
  if (body.containsKey('_server_messages')) {
    try {
      // _server_messages is usually a JSON string array
      // e.g. "[\"{\\\"message\\\": \\\"Invalid Login\\\"}\"]"
      // This is complex to parse reliably without more context, returning raw for now or simple string
      return body['_server_messages'].toString();
    } catch (_) {}
  }
  return 'Unknown Error';
}

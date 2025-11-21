import 'dart:convert';
import 'rest_helper.dart';
import 'exceptions.dart';
import 'utils.dart';

abstract class SessionStorage {
  Future<void> saveSession(String sid);
  Future<String?> getSession();
  Future<void> clearSession();
}

class InMemorySessionStorage implements SessionStorage {
  String? _sid;
  @override
  Future<void> saveSession(String sid) async => _sid = sid;
  @override
  Future<String?> getSession() async => _sid;
  @override
  Future<void> clearSession() async => _sid = null;
}

class AuthService {
  final RestHelper _restHelper;
  final SessionStorage _sessionStorage;

  AuthService(this._restHelper, {SessionStorage? sessionStorage})
      : _sessionStorage = sessionStorage ?? InMemorySessionStorage();

  Future<void> initialize() async {
    final sid = await _sessionStorage.getSession();
    if (sid != null) {
      _restHelper.setSessionCookie(sid);
    }
  }

  Future<void> loginWithCredentials(String username, String password) async {
    final uri = Uri.parse('${_restHelper.baseUrl}/api/method/login');
    try {
      final response = await _restHelper.client.post(
        uri,
        body: {'usr': username, 'pwd': password},
      );

      if (response.statusCode == 200) {
        // Just to check if error, though 200 usually means success.
        // ERPNext returns 200 with {message: "Logged In"}
        // We don't strictly need to extract error message here if we assume success,
        // but let's decode safely.

        final cookies = parseSetCookie(response.headers['set-cookie'] ?? '');
        final sid = cookies['sid'];

        if (sid != null) {
          _restHelper.setSessionCookie(sid);
          await _sessionStorage.saveSession(sid);
        } else {
          // Sometimes ERPNext returns 200 but with a message saying "Logged In" but no cookie if something is weird,
          // or maybe it failed but returned 200 (rare in recent versions).
          // Let's check body for error message just in case.
          dynamic body;
          try {
            body = jsonDecode(response.body);
            if (body is Map<String, dynamic> &&
                (body.containsKey('message') &&
                    body['message'] == 'Logged In')) {
              // If we got here and no cookie, it's weird.
              throw AuthException(
                'Login successful but no session cookie found',
              );
            }
          } catch (_) {}

          // If we are here, maybe we just didn't get the cookie.
          throw AuthException('Login successful but no session cookie found');
        }
      } else {
        dynamic body;
        try {
          body = jsonDecode(response.body);
        } catch (_) {
          body = {};
        }
        throw AuthException(extractErrorMessage(body), response.statusCode);
      }
    } catch (e) {
      if (e is ErpNextException) rethrow;
      throw NetworkException('Login failed: $e');
    }
  }

  void setApiKey(String apiKey, String apiSecret) {
    _restHelper.setApiKey(apiKey, apiSecret);
  }

  Future<void> logout() async {
    try {
      await _restHelper.get('/api/method/logout');
    } catch (_) {
      // Ignore logout errors
    } finally {
      _restHelper.clearSession();
      await _sessionStorage.clearSession();
    }
  }
}

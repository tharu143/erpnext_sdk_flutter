import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:erpnext_sdk_flutter/erpnext_sdk_flutter.dart';

void main() {
  group('ERPNextClient Tests', () {
    test('Login success', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.contains('login')) {
          return http.Response(
            jsonEncode({'message': 'Logged In'}),
            200,
            headers: {'set-cookie': 'sid=12345; Path=/'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final client = ERPNextClient(
        'https://example.com',
        httpClient: mockClient,
      );
      await client.auth.loginWithCredentials('user', 'pass');

      // Verify session is stored (we can't easily check private fields, but we can check if subsequent requests have cookie)
      // Or we can check the SessionStorage if we injected one.
    });

    test('List DocType', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.contains('frappe.client.get_list')) {
          return http.Response(
            jsonEncode({
              'message': [
                {'name': '1', 'subject': 'Test'},
              ],
            }),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      final client = ERPNextClient(
        'https://example.com',
        httpClient: mockClient,
      );
      final list = await client.doctype.list('ToDo');
      expect(list.length, 1);
      expect(list[0]['subject'], 'Test');
    });

    test('Create Document', () async {
      final mockClient = MockClient((request) async {
        if (request.method == 'POST' && request.url.path.contains('ToDo')) {
          final body = jsonDecode(request.body);
          return http.Response(
            jsonEncode({
              'data': {'name': 'new-todo', ...body},
            }),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      final client = ERPNextClient(
        'https://example.com',
        httpClient: mockClient,
      );
      final doc = await client.document.createDocument('ToDo', {
        'description': 'New Task',
      });
      expect(doc['name'], 'new-todo');
      expect(doc['description'], 'New Task');
    });
  });
}

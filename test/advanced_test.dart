import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:erpnext_sdk_flutter/erpnext_sdk_flutter.dart';

void main() {
  group('ERPNextClient Advanced Tests', () {
    test('QueryBuilder constructs correct params', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.contains('frappe.client.get_list')) {
          final params = request.url.queryParameters;
          if (params['doctype'] == 'ToDo' &&
              (params['filters']?.contains('Open') ?? false) &&
              params['order_by'] == 'creation desc') {
            return http.Response(jsonEncode({'message': []}), 200);
          }
        }
        return http.Response('Not Found', 404);
      });

      final client =
          ERPNextClient('https://example.com', httpClient: mockClient);
      await client
          .doc('ToDo')
          .where('status', 'Open')
          .orderBy('creation', descending: true)
          .get();
    });

    test('Generic Call executes correctly', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.contains('ping')) {
          return http.Response(jsonEncode({'message': 'pong'}), 200);
        }
        return http.Response('Not Found', 404);
      });

      final client =
          ERPNextClient('https://example.com', httpClient: mockClient);
      final res = await client.call('ping');
      expect(res['message'], 'pong');
    });
  });
}

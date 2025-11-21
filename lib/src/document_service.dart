import 'dart:convert';
import 'rest_helper.dart';

class DocumentService {
  final RestHelper _restHelper;

  DocumentService(this._restHelper);

  /// Creates a new document.
  ///
  /// [doctype] is the name of the DocType.
  /// [data] is the map of fields to set.
  ///
  /// Uses the REST API /api/resource/{DocType} by default.
  /// If [useFrappeClient] is true, it uses frappe.client.insert (useful for older versions or specific server-side logic hooks).
  Future<Map<String, dynamic>> createDocument(
    String doctype,
    Map<String, dynamic> data, {
    bool useFrappeClient = false,
  }) async {
    if (useFrappeClient) {
      // Using frappe.client.insert
      final response = await _restHelper.post(
        '/api/method/frappe.client.insert',
        body: {'doc': jsonEncode(data..['doctype'] = doctype)},
      );
      if (response is Map<String, dynamic> && response.containsKey('message')) {
        return response['message'] as Map<String, dynamic>;
      }
      return response as Map<String, dynamic>;
    } else {
      // Standard REST API
      final response = await _restHelper.post(
        '/api/resource/$doctype',
        body: data,
      );
      if (response is Map<String, dynamic> && response.containsKey('data')) {
        return response['data'] as Map<String, dynamic>;
      }
      return response as Map<String, dynamic>;
    }
  }

  /// Updates an existing document.
  ///
  /// [doctype] is the name of the DocType.
  /// [name] is the name (ID) of the document.
  /// [data] is the map of fields to update.
  Future<Map<String, dynamic>> updateDocument(
    String doctype,
    String name,
    Map<String, dynamic> data,
  ) async {
    final response = await _restHelper.put(
      '/api/resource/$doctype/$name',
      body: data,
    );
    if (response is Map<String, dynamic> && response.containsKey('data')) {
      return response['data'] as Map<String, dynamic>;
    }
    return response as Map<String, dynamic>;
  }

  /// Deletes a document.
  ///
  /// [doctype] is the name of the DocType.
  /// [name] is the name (ID) of the document.
  Future<void> deleteDocument(String doctype, String name) async {
    await _restHelper.delete('/api/resource/$doctype/$name');
  }

  /// Submits a document (if it is submittable).
  ///
  /// This usually requires calling a specific method or updating docstatus.
  /// Standard REST API allows updating docstatus to 1.
  Future<Map<String, dynamic>> submitDocument(
    String doctype,
    String name,
  ) async {
    return updateDocument(doctype, name, {'docstatus': 1});
  }

  /// Cancels a document.
  Future<Map<String, dynamic>> cancelDocument(
    String doctype,
    String name,
  ) async {
    return updateDocument(doctype, name, {'docstatus': 2});
  }
}

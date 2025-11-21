import 'dart:convert';
import 'rest_helper.dart';

class DoctypeService {
  final RestHelper _restHelper;

  DoctypeService(this._restHelper);

  /// Fetches metadata for a specific DocType.
  Future<Map<String, dynamic>> getDocTypeMeta(String doctype) async {
    final response = await _restHelper.get(
      '/api/method/frappe.desk.form.load.getdoctype',
      queryParams: {'doctype': doctype},
    );
    // Response structure: {"message": [{"docs": [...], "user_permissions": ...}]} or similar depending on version
    // Standard /api/resource/DocType/Name is also an option but getdoctype gives more meta.
    // Let's stick to the standard response parsing.

    if (response is Map<String, dynamic> && response.containsKey('docs')) {
      // frappe.desk.form.load.getdoctype returns a list of docs in 'docs'
      return response;
    }

    // Fallback or if structure is different (e.g. just the doc)
    return response as Map<String, dynamic>;
  }

  /// Lists documents of a specific DocType.
  /// [fields] is a list of field names to fetch (e.g. ["name", "status"]).
  /// [filters] is a list of filters (e.g. [["status", "=", "Open"]]).
  Future<List<dynamic>> list(
    String doctype, {
    List<String>? fields,
    List<List<dynamic>>? filters,
    int limit_start = 0,
    int limit_page_length = 20,
    String? order_by,
  }) async {
    final queryParams = <String, dynamic>{
      'doctype': doctype,
      'limit_start': limit_start,
      'limit_page_length': limit_page_length,
    };

    if (fields != null)
      queryParams['fields'] = fields
          .toString(); // JSON encode? No, Frappe expects JSON string for list params usually
    if (filters != null)
      queryParams['filters'] = filters
          .toString(); // This might need proper JSON encoding
    if (order_by != null) queryParams['order_by'] = order_by;

    // We need to be careful with list encoding.
    // frappe.client.get_list expects JSON strings for list/dict arguments if passed via GET.
    // Let's use the resource API for listing if possible, or frappe.client.get_list

    // Using /api/resource/{DocType} is cleaner for REST
    final resourceParams = <String, dynamic>{
      'limit_start': limit_start,
      'limit_page_length': limit_page_length,
    };
    if (fields != null)
      resourceParams['fields'] = fields
          .map((e) => '"$e"')
          .toList()
          .toString(); // Simple hack, better use jsonEncode
    if (filters != null)
      resourceParams['filters'] = filters.toString(); // Need jsonEncode
    if (order_by != null) resourceParams['order_by'] = order_by;

    // Actually, let's use jsonEncode for safety
    // However, /api/resource/DocType expects query params.

    // Let's use frappe.client.get_list via /api/method/frappe.client.get_list for maximum compatibility
    final methodParams = <String, dynamic>{
      'doctype': doctype,
      'limit_start': limit_start,
      'limit_page_length': limit_page_length,
    };
    if (fields != null)
      methodParams['fields'] =
          fields; // RestHelper will need to handle this? No, RestHelper takes Map<String, dynamic> and converts values to string.
    // We should JSON encode complex objects.

    // Let's refine RestHelper usage or do it here.
    // The RestHelper.get converts all values to string using .toString().
    // So we must JSON encode lists/maps here.

    // import 'dart:convert'; // Moved to top

    if (fields != null) methodParams['fields'] = jsonEncode(fields);
    if (filters != null) methodParams['filters'] = jsonEncode(filters);
    if (order_by != null) methodParams['order_by'] = order_by;

    final response = await _restHelper.get(
      '/api/method/frappe.client.get_list',
      queryParams: methodParams,
    );

    if (response is Map<String, dynamic> && response.containsKey('message')) {
      return response['message'] as List<dynamic>;
    }
    // Sometimes it returns just the list if not wrapped? No, usually wrapped in message.
    return [];
  }

  /// Gets a specific document by name.
  Future<Map<String, dynamic>> getByName(String doctype, String name) async {
    // Using REST API
    final response = await _restHelper.get('/api/resource/$doctype/$name');
    if (response is Map<String, dynamic> && response.containsKey('data')) {
      return response['data'] as Map<String, dynamic>;
    }
    return response as Map<String, dynamic>;
  }
}

import 'doctype_service.dart';

/// A fluent builder for constructing ERPNext queries.
class QueryBuilder {
  final DoctypeService _service;
  final String doctype;

  final List<String> _fields = [];
  final List<List<dynamic>> _filters = [];
  int _limitStart = 0;
  int _limitPageLength = 20;
  String? _orderBy;

  QueryBuilder(this._service, this.doctype);

  /// Specify fields to fetch.
  QueryBuilder select(List<String> fields) {
    _fields.addAll(fields);
    return this;
  }

  /// Add a filter.
  ///
  /// Usage:
  /// .where('status', 'Open') // Equals
  /// .where('age', '>', 18)   // Operator
  QueryBuilder where(String field, dynamic operatorOrValue, [dynamic value]) {
    if (value == null) {
      // implied equals
      _filters.add([doctype, field, '=', operatorOrValue]);
    } else {
      _filters.add([doctype, field, operatorOrValue, value]);
    }
    return this;
  }

  /// Add multiple filters at once.
  QueryBuilder filters(List<List<dynamic>> filters) {
    _filters.addAll(filters);
    return this;
  }

  /// Set sorting.
  /// e.g. 'creation desc'
  QueryBuilder orderBy(String field, {bool descending = false}) {
    _orderBy = '$field ${descending ? 'desc' : 'asc'}';
    return this;
  }

  /// Set pagination limits.
  QueryBuilder limit(int pageLength, {int start = 0}) {
    _limitPageLength = pageLength;
    _limitStart = start;
    return this;
  }

  /// Execute the query and return a list of maps.
  Future<List<dynamic>> get() async {
    return _service.list(
      doctype,
      fields: _fields.isEmpty ? ['*'] : _fields,
      filters: _filters,
      limit_start: _limitStart,
      limit_page_length: _limitPageLength,
      order_by: _orderBy,
    );
  }

  /// Execute and return the first result or null.
  Future<Map<String, dynamic>?> first() async {
    limit(1);
    final results = await get();
    if (results.isNotEmpty) {
      return results.first as Map<String, dynamic>;
    }
    return null;
  }
}

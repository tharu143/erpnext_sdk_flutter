import 'package:http/http.dart' as http;
import 'rest_helper.dart';
import 'auth.dart';
import 'doctype_service.dart';
import 'document_service.dart';
import 'attachment_service.dart';
import 'query_builder.dart';

class ERPNextClient {
  final RestHelper _restHelper;

  late final AuthService auth;
  late final DoctypeService doctype;
  late final DocumentService document;
  late final AttachmentService attachment;

  ERPNextClient(
    String baseUrl, {
    http.Client? httpClient,
    SessionStorage? sessionStorage,
  }) : _restHelper = RestHelper(baseUrl, client: httpClient) {
    auth = AuthService(_restHelper, sessionStorage: sessionStorage);
    doctype = DoctypeService(_restHelper);
    document = DocumentService(_restHelper);
    attachment = AttachmentService(_restHelper);
  }

  /// Initialize the client (e.g. load persisted session)
  Future<void> initialize() async {
    await auth.initialize();
  }

  /// Access to the raw RestHelper if needed for custom requests
  RestHelper get rest => _restHelper;

  /// Start a query for a DocType.
  ///
  /// Example: client.doc('ToDo').where('status', 'Open').get();
  QueryBuilder doc(String doctype) {
    return QueryBuilder(this.doctype, doctype);
  }

  /// Call a whitelisted server-side method.
  ///
  /// Example: client.call('frappe.client.get_value', args: {'doctype': 'User', 'fieldname': 'full_name'});
  Future<dynamic> call(String method,
      {Map<String, dynamic>? args, String httpMethod = 'POST'}) {
    return _restHelper.call(method, args: args, httpMethod: httpMethod);
  }
}

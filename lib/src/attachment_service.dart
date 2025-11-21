import 'dart:io';
import 'rest_helper.dart';

class AttachmentService {
  final RestHelper _restHelper;

  AttachmentService(this._restHelper);

  /// Uploads a file and optionally attaches it to a document.
  ///
  /// [file] is the file to upload.
  /// [fileName] is the name of the file (optional, defaults to file path basename).
  /// [doctype] and [docname] are optional. If provided, the file will be attached to this document.
  /// [isPrivate] determines if the file is private (default true).
  Future<Map<String, dynamic>> uploadFile(
    File file, {
    String? fileName,
    String? doctype,
    String? docname,
    bool isPrivate = true,
  }) async {
    final fields = <String, String>{
      'is_private': isPrivate ? '1' : '0',
      'folder': 'Home', // Default folder
    };

    if (doctype != null && docname != null) {
      fields['dt'] = doctype;
      fields['dn'] = docname;
    }

    if (fileName != null) {
      fields['filename'] = fileName;
    }

    // ERPNext /api/method/upload_file expects 'file' as the field name for the file content
    // or 'file_url' / 'file_name' etc. For multipart, we use 'file'.

    final response = await _restHelper.uploadFile(
      '/api/method/upload_file',
      'file',
      file,
      fields: fields,
    );

    if (response is Map<String, dynamic> && response.containsKey('message')) {
      return response['message'] as Map<String, dynamic>;
    }
    return response as Map<String, dynamic>;
  }
}

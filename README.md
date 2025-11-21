# ERPNext Flutter SDK

A production-ready ERPNext SDK for Flutter/Dart focused on mobile apps. This package provides a clean, type-safe, and robust way to interact with your ERPNext instance.

## Features

*   **Authentication**: Login with username/password (Session-based) or API Key/Secret.
*   **Session Management**: Automatic cookie handling and optional session persistence.
*   **REST Helper**: Simplified GET, POST, PUT, DELETE methods with automatic error handling and retries.
*   **DocType Service**: Fetch metadata, list documents with filters and fields.
*   **Document Service**: Create, Update, Delete, Submit, and Cancel documents.
*   **Attachment Service**: Upload files and attach them to documents.
*   **Error Handling**: Typed exceptions for Auth, Network, API, and Validation errors.

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  erpnext_sdk_flutter:
    path: ./ # If local, or version if published
```

## Quick Start

### Initialization

```dart
import 'package:erpnext_sdk_flutter/erpnext_sdk_flutter.dart';

final client = ERPNextClient('https://your-erpnext-site.com');
```

### Authentication

```dart
// Login with credentials
try {
  await client.auth.loginWithCredentials('user@example.com', 'password');
  print('Logged in successfully');
} catch (e) {
  print('Login failed: $e');
}

// Or use API Key/Secret
client.auth.setApiKey('your_api_key', 'your_api_secret');
```

### Listing Documents

```dart
final todos = await client.doctype.list(
  'ToDo',
  fields: ['name', 'description', 'status'],
  filters: [['status', '=', 'Open']],
  limit_page_length: 10,
);

for (var todo in todos) {
  print('${todo['name']}: ${todo['description']}');
}
```

### Creating a Document

```dart
final newDoc = await client.document.createDocument('ToDo', {
  'description': 'Buy milk',
  'status': 'Open',
  'priority': 'High',
});
print('Created ToDo: ${newDoc['name']}');
```

### Advanced Usage

#### Query Builder

Easily build complex queries without manually formatting filters.

```dart
final todos = await client.doc('ToDo')
    .select(['name', 'description'])
    .where('status', 'Open')
    .where('priority', 'High')
    .orderBy('creation', descending: true)
    .limit(5)
    .get();
```

#### Generic Method Calls (RPC)

Call any whitelisted Python method on your ERPNext server.

```dart
final user = await client.call('frappe.client.get_value', args: {
  'doctype': 'User',
  'fieldname': 'full_name',
  'filters': {'email': 'test@example.com'}
});
```

#### FrappeDocument Wrapper

Use the `FrappeDocument` wrapper for type-safe property access.

```dart
import 'package:erpnext_sdk_flutter/src/frappe_document.dart';

final doc = FrappeDocument(data);
print(doc.getString('description'));
print(doc.getBool('is_completed'));
```

### Uploading a File

```dart
import 'dart:io';

final file = File('/path/to/image.png');
await client.attachment.uploadFile(
  file,
  doctype: 'ToDo',
  docname: newDoc['name'],
  isPrivate: true,
);
```

## Mobile Best Practices

*   **API Keys**: For mobile apps, it is often better to use API Keys and Secrets generated for a specific user, rather than storing passwords.
*   **Secure Storage**: The default `InMemorySessionStorage` does not persist across app restarts. Implement `SessionStorage` using `flutter_secure_storage` to securely save the session cookie (SID) or API keys.
*   **Offline Sync**: This SDK provides the building blocks. For offline support, consider using a local database (like Hive or Isar) to cache data and a sync queue to push changes when online.

## Troubleshooting

*   **CORS**: Ensure your ERPNext server has CORS enabled if you are developing a web app or using a browser-based environment. For mobile apps, CORS is usually not an issue unless you are using a web view.
*   **CSRF**: If you encounter CSRF errors, ensure you are not manually setting headers that conflict with the session cookie. The SDK handles standard headers.

## License

MIT

import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:googleapis_auth/auth_io.dart';

class ReceiptRemoteDataSource {
  final String endpoint;

  ReceiptRemoteDataSource(this.endpoint);

  Future<Map<String, dynamic>> uploadReceipt(File image) async {
    // Load service account JSON from assets
    final jsonString = await rootBundle.loadString('assets/ledoys-738a4da4fb7c.json');
    final accountCredentials = ServiceAccountCredentials.fromJson(json.decode(jsonString));

    final scopes = ['https://www.googleapis.com/auth/cloud-platform'];
    final client = await clientViaServiceAccount(accountCredentials, scopes);

    // Read image bytes and encode in Base64
    final bytes = await image.readAsBytes();
    final base64Content = base64Encode(bytes);

    // Build the JSON request as Document AI expects
    final mimeType = _mimeTypeFromPath(image.path);

    final payload = jsonEncode({
      "rawDocument": {
        "content": base64Content,
        "mimeType": mimeType,
      }
    });

    final response = await client.post(
      Uri.parse(endpoint),
      headers: {
        'Authorization': 'Bearer ${client.credentials.accessToken.data}',
        'Content-Type': 'application/json',
      },
      body: payload,
    );

    client.close();

    if (response.statusCode != 200) {
      debugPrint(response.body);
      throw Exception(
        "Receipt scan failed. Status: ${response.statusCode}, Body: ${response.body}",
      );
    }
    // debugPrint(response.body);
    return jsonDecode(response.body);
  }

  String _mimeTypeFromPath(String path) {
    final ext = path.toLowerCase().split('.').last;
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'tif':
      case 'tiff':
        return 'image/tiff';
      case 'gif':
        return 'image/gif';
      case 'bmp':
        return 'image/bmp';
      case 'webp':
        return 'image/webp';
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }

}

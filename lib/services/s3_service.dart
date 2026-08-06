import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart'; // ✅ Added for MediaType

class S3Service {
  static const String _baseUrl = 'https://s3-upload.mirdemy.com';
  static const String _apiKey = '9a893ecf96844dd65bf4ed7f856c5767e96ef983ad6cfabbed81817c778948f2';

  /// Upload an image to the S3 server
  /// Returns the public URL of the uploaded image
  static Future<String?> uploadImage(File imageFile) async {
    try {
      final url = Uri.parse('$_baseUrl/upload');

      // ─── REQUEST DETAILS ───────────────────────────────────────────────
      debugPrint('════════════════════════════════════════');
      debugPrint('📤 [S3Service] REQUEST');
      debugPrint('   URL    : ${url.toString()}');
      debugPrint('   Method : POST multipart/form-data');
      debugPrint('   Header : x-api-key = ${_apiKey.substring(0, 12)}...');
      debugPrint('   File   : ${imageFile.path}');
      debugPrint('   Size   : ${(await imageFile.length() / 1024).toStringAsFixed(1)} KB');
      
      // Determine mimetype
      String ext = imageFile.path.split('.').last.toLowerCase();
      String mimeType = (ext == 'png') ? 'image/png' : 'image/jpeg';
      debugPrint('   Mime   : $mimeType'); 
      debugPrint('════════════════════════════════════════');

      var request = http.MultipartRequest('POST', url);
      request.headers.addAll({'x-api-key': _apiKey});
      
      request.files.add(
        await http.MultipartFile.fromPath(
          'image', 
          imageFile.path,
          contentType: MediaType.parse(mimeType), // ✅ Explicitly set for server compatibility
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // ─── RESPONSE DETAILS ──────────────────────────────────────────────
      debugPrint('════════════════════════════════════════');
      debugPrint('📥 [S3Service] RESPONSE');
      debugPrint('   Status : ${response.statusCode}');
      debugPrint('   Body   : ${response.body}');
      debugPrint('════════════════════════════════════════');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final imageUrl = data['url'] ?? data['data']?['url'] ?? data['imageUrl'] ?? data['link'];

        if (imageUrl != null) {
          debugPrint('✅ [S3Service] Upload successful! URL: $imageUrl');
          return imageUrl;
        } else {
          debugPrint('⚠️ [S3Service] Upload succeeded but URL key not found in response.');
          debugPrint('   Available keys: ${data.keys.toList()}');
          return null;
        }
      } else {
        debugPrint('❌ [S3Service] Upload FAILED (${response.statusCode})');
        return null;
      }
    } catch (e, st) {
      debugPrint('❌ [S3Service] Exception: $e');
      debugPrint('   StackTrace: $st');
      return null;
    }
  }
}

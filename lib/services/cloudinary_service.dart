// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class CloudinaryService {
  // ✅ Cloudinary credentials (replace with your own)
  static const String _cloudName = "";// add your cloudname
  static const String _uploadPreset = "";// add your uploadPreset
  final String _apiKey = '';// add your api key
  final String _apiSecret = '';// add your api secret

  /// Upload image or video to Cloudinary
   Future<Map<String, String>?> uploadFile(File file) async {
    try {
      final uri = Uri.parse(
          'https://api.cloudinary.com/v1_1/$_cloudName/auto/upload');

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = _uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        print('✅ Upload Success: ${data['secure_url']}');
        return {
          'url': data['secure_url'],
          'public_id': data['public_id'], // 👈 Important for deletion
        };
      } else {
        print('❌ Upload Failed: ${response.reasonPhrase}');
        print('Response body: $responseBody');
        return null;
      }
    } catch (e) {
      print('⚠️ Exception during upload: $e');
      return null;
    }
  }
   /// ✅ Delete image from Cloudinary using public_id
  Future<void> deleteImage(String publicId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final String toSign = 'public_id=$publicId&timestamp=$timestamp$_apiSecret';

      // Generate the SHA-1 signature
      final signature = sha1.convert(utf8.encode(toSign)).toString();

      final uri = Uri.parse(
          'https://api.cloudinary.com/v1_1/$_cloudName/image/destroy');

      final response = await http.post(uri, body: {
        'public_id': publicId,
        'api_key': _apiKey,
        'timestamp': timestamp.toString(),
        'signature': signature,
      });

      if (response.statusCode == 200) {
        print('🗑️ Image deleted successfully from Cloudinary.');
      } else {
        print('❌ Failed to delete image: ${response.body}');
      }
    } catch (e) {
      print('⚠️ Exception while deleting image: $e');
    }
  }
  /// (Optional) Upload multiple files at once
  Future<List<Map<String, String>>> uploadMultipleFiles(List<File> files) async {
    List<Map<String, String>> uploads = [];
    for (final file in files) {
      final result = await uploadFile(file);
      if (result != null) uploads.add(result);
    }
    return uploads;
  }
}

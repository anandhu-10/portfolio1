import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class CloudinaryService {
  // Cloudinary credentials configuration
  // IMPORTANT: Replace these with your own Cloudinary Cloud Name and Unsigned Upload Preset.
  static const String cloudName = 'myportfolio-21019'; // Your Cloudinary Cloud Name
  static const String uploadPreset = 'portfolio_preset'; // Your Unsigned Upload Preset name

  /// Uploads a base64 image or file to Cloudinary.
  /// [base64DataUrl] must be a valid Data URL (e.g. data:image/png;base64,...)
  /// [fileName] is used to help determine the type of asset (image vs document).
  /// Returns the secure URL of the uploaded asset.
  static Future<String> uploadBase64(String base64DataUrl, String fileName) async {
    if (base64DataUrl.isEmpty) return '';
    if (base64DataUrl.startsWith('http://') || base64DataUrl.startsWith('https://')) {
      return base64DataUrl;
    }

    try {
      debugPrint('[Cloudinary] Initiating upload for $fileName...');
      
      // Determine resource type for Cloudinary
      // Cloudinary has 'image', 'video', and 'raw' (for non-image assets like PDFs, text files)
      String resourceType = 'image';
      if (fileName.toLowerCase().endsWith('.pdf') || base64DataUrl.contains('application/pdf')) {
        resourceType = 'raw';
      }

      final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/upload');
      
      // Build the request fields
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..fields['file'] = base64DataUrl
        ..fields['resource_type'] = resourceType;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isEmpty) {
          throw Exception('Cloudinary returned an empty response.');
        }
        try {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final String? secureUrl = data['secure_url'];
          if (secureUrl != null && secureUrl.isNotEmpty) {
            debugPrint('[Cloudinary] Successfully uploaded $fileName -> $secureUrl');
            return secureUrl;
          } else {
            throw Exception('Upload succeeded but secure_url was not returned.');
          }
        } catch (je) {
          throw Exception('Failed to parse Cloudinary success response: ${response.body}');
        }
      } else {
        String errorMessage = 'Unknown error';
        if (response.body.isNotEmpty) {
          try {
            final Map<String, dynamic> errorData = jsonDecode(response.body);
            errorMessage = errorData['error']?['message'] ?? response.body;
          } catch (_) {
            errorMessage = response.body;
          }
        }
        throw Exception('Cloudinary error: $errorMessage (Status: ${response.statusCode})');
      }
    } catch (e) {
      debugPrint('[Cloudinary] ERROR uploading file: $e');
      rethrow;
    }
  }
}

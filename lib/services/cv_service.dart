import 'dart:async';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import '../api_constants.dart';
import '../models/cv_analysis.dart';

class CvService {
  static const maxBytes = 5 * 1024 * 1024;
  Future<CvAnalysis> analyze(PlatformFile file) async {
    if (file.size > maxBytes) {
      throw const FormatException('Maximum file size is 5 MB.');
    }
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      throw const FormatException('Please select the file again.');
    }
    final client = http.Client();
    try {
      return await (() async {
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('${ApiConstants.baseUrl}/analyze_cv'),
        );
        request.files.add(
          http.MultipartFile.fromBytes('file', bytes, filename: file.name),
        );
        final response = await http.Response.fromStream(
          await client.send(request),
        );
        final data = jsonDecode(response.body);
        if (response.statusCode != 200) {
          throw FormatException(
            data is Map
                ? '${data['detail'] ?? 'Server rejected this file.'}'
                : 'Server error.',
          );
        }
        if (data is! Map ||
            data['profile'] is! String ||
            data['skills'] is! List ||
            data['matchReason'] is! String) {
          throw const FormatException('Invalid analysis response.');
        }
        return CvAnalysis(
          profile: data['profile'] as String,
          skills: List<String>.from(data['skills'] as List),
          matchReason: data['matchReason'] as String,
        );
      })().timeout(const Duration(seconds: 30));
    } on TimeoutException {
      throw const FormatException(
        'Analysis timed out. Check the API connection and retry.',
      );
    } on http.ClientException {
      throw const FormatException(
        'Cannot reach the analysis service. Check API_BASE_URL and retry.',
      );
    } finally {
      client.close();
    }
  }
}

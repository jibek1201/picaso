import 'dart:typed_data';
import 'package:http/http.dart' as http;

class StabilityAIService {
  final String apiKey = 'sk-gOp9iwamUFAoEzT7YlJNkqXgHwflSzznYRNe4cM9kOhl7h8b';  // Replace with your API key
  final String apiUrl = 'https://api.stability.ai/v2beta/stable-image/generate/diffusion';

  Future<Uint8List?> generateImage(String prompt) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl))
        ..headers['Authorization'] = 'Bearer $apiKey'
        ..headers['Accept'] = 'image/*'
        ..fields['prompt'] = prompt
        ..fields['output_format'] = 'webp';

      var response = await request.send();

      if (response.statusCode == 400) {
        return await response.stream.toBytes();  // Return image bytes
      } else {
        final responseBody = await response.stream.bytesToString();
        print('Failed to generate image: ${response.statusCode}, Response Body: $responseBody');
        return null;
      }
    } catch (e) {
      print('Error generating AI image: $e');
      return null;
    }
  }
}
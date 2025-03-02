import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'image_processing.dart';

class StabilityAIService {
  final String apiKey = dotenv.env['Bearer sk-gOp9iwamUFAoEzT7YlJNkqXgHwflSzznYRNe4cM9kOhl7h8b'] ?? '';
  final String apiUrl = 'https://api.stability.ai/v2beta/stable-image/generate/core';

  Future<Uint8List?> generateImage(String prompt) async {
    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Accept': 'image/*',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'prompt': prompt,
          'output_format': 'png',
        }),
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;  // Return the generated image as bytes
      } else {
        print('Failed to generate image: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error generating AI image: $e');
      return null;
    }
  }

  Future<Uint8List?> generateImageAndContour(String prompt) async {
    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Accept': 'image/*',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'prompt': prompt,
          'output_format': 'png',
        }),
      );

      if (response.statusCode == 200) {
        // Convert the generated image to a contour
        Uint8List? contourImage = convertToContour(response.bodyBytes);
        return contourImage;
      } else {
        print('Failed to generate image: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error generating AI image: $e');
      return null;
    }
  }
}


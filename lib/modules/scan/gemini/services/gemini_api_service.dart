// lib/modules/scan/gemini/services/gemini_api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../model/plant_model.dart';
import '../model/pest_model.dart';

class GeminiApiService {
  final String apiKey; // Kept for backwards compatibility but not used
  // Using Production Server
  static const String _baseUrl = 'https://apps-model-server.mirdemy.com';
  static String get _accessKey => dotenv.env['LABMATE_API_KEY'] ?? '';

  GeminiApiService(this.apiKey);

  static String _getMimeType(String path) {
    if (path.endsWith('.png')) return 'image/png';
    if (path.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  Future<PlantModel> identifyPlant(File imageFile) async {
    try {
      debugPrint("🌿 [GeminiApiService] Starting image identification...");

      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      const prompt = """
You are a professional botanist and plant identification expert.

Task: Identify the plant in the provided image. 
Return **ONLY one JSON object** (no markdown or explanation) matching this schema:

{
  "name": "Common name of the plant",
  "scientific_name": "Scientific name (Genus species)",
  "confidence": 0.0,
  "about": "A short description (max 300 words)",
  "details": {
    "temperature_range": "Short Numeric Temperature Range only (e.g. 20°C - 30°C)",
    "sunlight": " Only 2-3 words only Recommended sunlight (e.g. Full Sun, Partial Shade, etc)",
    "watering": "short range or frequency only (e.g. every 4-7 days)",
    "repotting": "short duration only (e.g. every 2 years, not needed, etc)",
    "fertilizing": "Short duration only (e.g. every 3 months)",
    "pests": "only 2-3 pest names, comma-separated (e.g. Spider Mites, Aphids)"
  },
  "common_problems": "Common issues seen in this plant",
  "faqs": [
    {"q": "Question 1", "a": "Answer 1"},
    {"q": "Question 2", "a": "Answer 2"}
  ],
  "fun_facts": ["fact 1", "fact 2"]
}

If the image does NOT contain a plant or tree, respond with:
{"error": "This image does not appear to be a plant."}

If unsure, still return your best guess and include a confidence < 0.6.
""";

      final body = {
        "prompt": prompt,
        "image_base64": base64Image,
        "mime_type": _getMimeType(imageFile.path)
      };

      debugPrint("🔍 [GeminiApiService] Sending identifyPlant Request to: $_baseUrl/api/plantai");
      debugPrint("📤 [Payload Body]: ${jsonEncode(body)}");

      final response = await http.post(
        Uri.parse("$_baseUrl/api/plantai"),
        headers: {
          "Content-Type": "application/json",
          "x-api-key": _accessKey
        },
        body: jsonEncode(body),
      );

      debugPrint("🔍 [GeminiApiService] HTTP Status: ${response.statusCode}");
      debugPrint("📥 [Response Body]: ${response.body}");

      if (response.statusCode != 200) {
        debugPrint("❌ API Error [${response.statusCode}]: ${response.body}");
        throw Exception("Unable to analyze the image right now. Please try again later.");
      }

      final data = jsonDecode(response.body);
      final text = data['result'];

      if (text == null || (text as String).isEmpty) {
        throw Exception("We received an empty response. Please try another image.");
      }

      final jsonData = _extractJsonFromText(text as String);
      debugPrint("🌱 [GeminiApiService] Parsed JSON: $jsonData");

      if (jsonData.containsKey("details")) {
        return PlantModel.fromJson(jsonData);
      } else {
        return PlantModel.fromGeminiResponse(jsonData);
      }
    } catch (e, st) {
      debugPrint("❌ [GeminiApiService] Error: $e\n$st");
      // Don't leak raw exceptions to UI
      throw Exception("Our servers encountered an issue. Please try again.");
    }
  }

  Future<PestModel> identifyPest(File imageFile) async {
    try {
      debugPrint("🐛 [GeminiApiService] Starting pest identification...");

      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      const prompt = """
You are a professional entomologist and plant pathologist expert.

Task: Identify the plant pest (insect, mite, or disease) in the provided image. 
Return **ONLY one JSON object** (no markdown or explanation) matching this schema:

{
  "name": "Common name of the pest",
  "scientific_name": "Scientific name",
  "confidence": 0.0,
  "description": "A short overview of the pest",
  "symptoms": "What signs to look for on the plant",
  "organic_treatment": "3-4 direct steps for organic/natural treatment",
  "prevention": "How to prevent this pest in the future",
  "affected_plants": ["plant 1", "plant 2"]
}

If the image does NOT contain a pest or plant disease, respond with:
{"error": "No significant pest or disease detected in the image."}

Focus specifically on organic and natural treatment suggestions.
""";

      final body = {
        "prompt": prompt,
        "image_base64": base64Image,
        "mime_type": _getMimeType(imageFile.path)
      };

      debugPrint("🐛 [GeminiApiService] Sending identifyPest Request to: $_baseUrl/api/plantai");
      debugPrint("📤 [Payload Body]: ${jsonEncode(body)}");

      final response = await http.post(
        Uri.parse("$_baseUrl/api/plantai"),
        headers: {
          "Content-Type": "application/json",
          "x-api-key": _accessKey
        },
        body: jsonEncode(body),
      );

      debugPrint("🐛 [GeminiApiService] HTTP Status: ${response.statusCode}");
      debugPrint("📥 [Response Body]: ${response.body}");

      if (response.statusCode != 200) {
        debugPrint("❌ API Error [${response.statusCode}]: ${response.body}");
        throw Exception("Unable to analyze the pest image right now. Please try again later.");
      }

      final data = jsonDecode(response.body);
      final text = data['result'];

      if (text == null || (text as String).isEmpty) {
        throw Exception("We received an empty response. Please try another image.");
      }

      final jsonData = _extractJsonFromText(text as String);
      if (jsonData.containsKey("error")) {
        throw Exception(jsonData["error"]);
      }

      return PestModel.fromJson(jsonData);
    } catch (e, st) {
      debugPrint("❌ [GeminiApiService] Pest ID Error: $e\n$st");
      throw Exception("Our servers encountered an issue. Please try again.");
    }
  }

  /// Safely extract JSON from Gemini text output
  Map<String, dynamic> _extractJsonFromText(String text) {
    try {
      final start = text.indexOf('{');
      final end = text.lastIndexOf('}');
      if (start == -1 || end == -1) return {"name": text.trim()};
      final jsonStr = text.substring(start, end + 1);
      return jsonDecode(jsonStr);
    } catch (e) {
      debugPrint("⚠️ [GeminiApiService] Failed to parse JSON: $e");
      return {"name": text.trim()};
    }
  }
}

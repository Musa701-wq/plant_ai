// lib/modules/scan/gemini/services/gemini_api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../model/plant_model.dart';

class GeminiApiService {
  final String apiKey;
  GeminiApiService(this.apiKey);

  static const String _modelUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-image:generateContent";

  Future<PlantModel> identifyPlant(File imageFile) async {
    try {
      debugPrint("🌿 [GeminiApiService] Starting image identification...");

      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // 🧠 Very clear and structured prompt (your version is already excellent)
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

      final requestBody = jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt},
              {
                "inline_data": {
                  "mime_type": "image/jpeg",
                  "data": base64Image,
                }
              }
            ]
          }
        ]
      });

      final response = await http.post(
        Uri.parse("$_modelUrl?key=$apiKey"),
        headers: {"Content-Type": "application/json"},
        body: requestBody,
      );

      debugPrint("🔍 [GeminiApiService] HTTP Status: ${response.statusCode}");

      if (response.statusCode != 200) {
        debugPrint("❌ [GeminiApiService] Response: ${response.body}");
        throw Exception("Gemini API failed with ${response.statusCode}: ${response.body}");
      }

      final data = jsonDecode(response.body);
      final text = data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"];

      if (text == null || text.isEmpty) {
        throw Exception("Empty response from Gemini API");
      }

      final jsonData = _extractJsonFromText(text);
      debugPrint("🌱 [GeminiApiService] Parsed JSON: $jsonData");

      // ✅ Use appropriate model parser depending on the structure
      if (jsonData.containsKey("details")) {
        return PlantModel.fromJson(jsonData);
      } else {
        return PlantModel.fromGeminiResponse(jsonData);
      }
    } catch (e, st) {
      debugPrint("❌ [GeminiApiService] Error: $e\n$st");
      throw Exception("Gemini API error: $e");
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

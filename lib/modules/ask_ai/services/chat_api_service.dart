// lib/services/gemini/services/gemini_chat_api_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart'; // for debugPrint
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../scan/gemini/model/plant_model.dart';

class GeminiChatApiService {
  final String apiKey; // Kept for backwards compatibility but not used
  // Using Production Server
  static const String _baseUrl = 'https://apps-model-server.mirdemy.com';
  static String get _accessKey => dotenv.env['LABMATE_API_KEY'] ?? '';

  GeminiChatApiService(this.apiKey);

  /// Send message with context (last few messages)
  Future<String> sendMessageWithContext(List<Map<String, dynamic>> messages) async {
    final url = Uri.parse("$_baseUrl/api/plantai");

    // 🔑 System prompt for restriction + better responses
    const systemPrompt = """
You are **Plant AI Assistant 🌱**.
Rules:
- You ONLY answer questions about plants, gardening, soil, sunlight, watering, diseases, fertilizers, or plant identification.
- If the user asks something unrelated (technology, sports, politics, etc.), politely respond:
  "I'm here to help only with plant-related topics 🌱."
- Be concise, friendly, and give practical, actionable advice.
- If user provides plant symptoms, suggest possible causes and solutions.
- Always keep a warm and encouraging tone.
""";

    // Combine history into a single string since endpoint takes "prompt"
    String combinedPrompt = systemPrompt + "\n\nConversation History:\n";
    for (var msg in messages) {
      final role = msg['role'];
      final parts = msg['parts'] as List;
      final text = parts.isNotEmpty ? parts[0]['text'] : '';
      combinedPrompt += "${role == 'user' ? 'User' : 'AI'}: $text\n";
    }
    // Add instruction to reply only to the last user message based on context
    combinedPrompt += "\nBased on the above conversation, please provide the next response as the AI.";

    final body = {
      "prompt": combinedPrompt
    };

    try {
      debugPrint("🌿 [GeminiChatApiService] Sending request to: $url");
      debugPrint("📤 [Payload Body]: ${jsonEncode(body)}");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "x-api-key": _accessKey
        },
        body: jsonEncode(body),
      );

      debugPrint("📡 [Response Status Code]: ${response.statusCode}");
      debugPrint("📥 [Response Body]: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['result'];
        debugPrint("✅ [AI Response Text]: $text");
        return text ?? "Sorry, I couldn’t generate a response at this moment.";
      } else {
        debugPrint("❌ API Error [${response.statusCode}]: ${response.body}");
        throw Exception("We couldn't reach the server. Please try again later.");
      }
    } catch (e, stack) {
      debugPrint("💥 [Exception Caught]: $e");
      debugPrint("🧱 [Stack Trace]: $stack");
      return "An unexpected error occurred. Please try again later.";
    }
  }


  // --------------------------------------------------------------
  // 🌱 NEW METHOD: Fetch Plant Details by Name (text-based request)
  // --------------------------------------------------------------
  Future<PlantModel> fetchPlantDetailsByName(String plantName) async {
    final url = Uri.parse("$_baseUrl/api/plantai");

    final prompt = """
You are a professional botanist and plant expert 🌿.

Task: Provide **complete botanical details** about the plant named "$plantName".
Return **ONLY one JSON object** (no markdown or explanation) matching this schema exactly:

{
  "name": "Common name of the plant",
  "scientific_name": "Scientific name (Genus species)",
  "confidence": 1.0,
  "about": "A short description (max 300 words)",
  "details": {
    "temperature_range": "Short Numeric Temperature Range only (e.g. 20°C - 30°C)",
    "sunlight": " Only 2-3 words only Recommended sunlight (e.g. Full Sun, Partial Shade, etc)",
    "watering": "short range or frequency only (e.g. every 4-7 days)",
    "repotting": "short duration only (e.g. every 2 years, not needed, etc)",
    "fertilizing": "Short duration only (e.g. every 3 months)",
    "pests": "only 2-3 pest names, comma-separated (e.g. Spider Mites, Aphids)"
  },
  "common_problems": "Common problems seen in this plant",
  "faqs": [
    {"q": "Question 1", "a": "Answer 1"},
    {"q": "Question 2", "a": "Answer 2"}
  ],
  "fun_facts": ["fact 1", "fact 2"]
}

If you don't recognize the plant name, respond with:
{"error": "Plant not found or insufficient data."}
""";

    final body = {
      "prompt": prompt
    };

    try {
      debugPrint("🌱 [GeminiChatApiService] Fetching details for: $plantName\nURL: $url");
      debugPrint("📤 [Payload Body]: ${jsonEncode(body)}");
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "x-api-key": _accessKey
        },
        body: jsonEncode(body),
      );

      debugPrint("📡 [Response Code]: ${response.statusCode}");
      debugPrint("📥 [Response Body]: ${response.body}");
      if (response.statusCode != 200) {
        debugPrint("❌ API Error [${response.statusCode}]: ${response.body}");
        throw Exception("Unable to fetch plant details right now. Please try again.");
      }

      final data = jsonDecode(response.body);
      final text = data['result'];

      if (text == null || (text as String).isEmpty) {
        throw Exception("We received an empty response. Please try again.");
      }

      final jsonData = _extractJsonFromText(text as String);
      debugPrint("🌿 [Parsed Gemini JSON]: $jsonData");

      if (jsonData.containsKey("error")) {
        throw Exception(jsonData["error"]);
      }

      return PlantModel.fromJson(jsonData);
    } catch (e, st) {
      debugPrint("❌ [fetchPlantDetailsByName] Error: $e\n$st");
      rethrow;
    }
  }

  /// Helper: safely extract JSON object from model output
  Map<String, dynamic> _extractJsonFromText(String text) {
    try {
      final start = text.indexOf('{');
      final end = text.lastIndexOf('}');
      if (start == -1 || end == -1) return {"error": "Invalid format"};
      final jsonStr = text.substring(start, end + 1);
      return jsonDecode(jsonStr);
    } catch (e) {
      debugPrint("⚠️ Failed to extract JSON: $e");
      return {"error": "Failed to parse JSON"};
    }
  }

  /// --------------------------------------------------------------
  /// 🌊 NEW: Fetch Watering Plan for a plant given environment
  /// --------------------------------------------------------------
  Future<Map<String, dynamic>> fetchWateringPlan({
    required String plantName,
    required String location, // "Indoor" or "Outdoor"
    required double humidityPercent, // e.g. 55.0
    required double temperature, // numeric
    required String tempUnit, // "C" or "F"
  }) async {
    final url = Uri.parse("$_baseUrl/api/plantai");

    final prompt = """
You are a professional plant care assistant 🌿.
Given the following plant and environment details, generate a concise and accurate watering plan in JSON format.

Input:
- plant: "$plantName"
- location: "$location"
- humidity_percent: $humidityPercent
- temperature: $temperature $tempUnit

Return ONLY a JSON object using this exact schema:

{
  "plant": "<common name>",
  "watering_frequency": "<every 3-5 days, check soil moisture>",
  "water_amount_ml": "<200-250 ml>",
  "best_time": "<early morning>",
  "adjustments": {
     "if_low_humidity": "<advice>",
     "if_high_humidity": "<advice>",
     "if_low_temperature": "<advice>",
     "if_high_temperature": "<advice>"
  },
  "tips": ["short tip1", "short tip2", "short tip3"]
}

Keep it realistic, practical, and based on typical indoor/outdoor care.  
If you cannot determine a plan, return:
{"error": "Insufficient data or plant unknown"}
""";

    final body = {
      "prompt": prompt
    };

    try {
      debugPrint("🌊 [Gemini] Fetching watering plan for: $plantName\nURL: $url");
      debugPrint("📤 [Payload Body]: ${jsonEncode(body)}");
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "x-api-key": _accessKey
        },
        body: jsonEncode(body),
      );

      debugPrint("📡 [Response Code]: ${response.statusCode}");
      debugPrint("📥 [Response Body]: ${response.body}");
      if (response.statusCode != 200) {
        debugPrint("❌ API Error [${response.statusCode}]: ${response.body}");
        throw Exception("Unable to generate a watering plan right now. Please try again.");
      }

      final data = jsonDecode(response.body);
      final text = data['result'];

      if (text == null || (text as String).trim().isEmpty) {
        throw Exception("We received an empty response. Please try again.");
      }

      final jsonData = _extractJsonFromText(text as String);
      debugPrint("🌊 [Parsed WaterPlan JSON]: $jsonData");

      if (jsonData.containsKey("error")) {
        throw Exception(jsonData["error"]);
      }

      return jsonData;
    } catch (e, st) {
      debugPrint("❌ [fetchWateringPlan] Error: $e\n$st");
      rethrow;
    }
  }

}

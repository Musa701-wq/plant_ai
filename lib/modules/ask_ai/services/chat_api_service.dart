// lib/services/gemini/services/gemini_chat_api_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart'; // for debugPrint
import 'package:http/http.dart' as http;

import '../../scan/gemini/model/plant_model.dart';

class GeminiChatApiService {
  final String apiKey;
  final String baseUrl = "https://generativelanguage.googleapis.com/v1";

  GeminiChatApiService(this.apiKey);

  /// Send message with context (last few messages)
  Future<String> sendMessageWithContext(List<Map<String, dynamic>> messages) async {
    // ✅ Use the latest supported model
    final url = Uri.parse(
      "$baseUrl/models/gemini-2.5-flash-image:generateContent?key=$apiKey",
    );

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

    final body = {
      "contents": [
        {
          "role": "user",
          "parts": [
            {"text": systemPrompt}
          ]
        },
        ...messages, // Include conversation context
      ]
    };

    try {
      // 🪵 Debug logs
      debugPrint("🌿 [GeminiChatApiService] Sending request to: $url");
      debugPrint("📝 [Request Body]: ${jsonEncode(body)}");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      debugPrint("📡 [Response Status Code]: ${response.statusCode}");
      debugPrint("📩 [Raw Response Body]: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final candidates = data["candidates"] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final parts = candidates[0]["content"]["parts"] as List?;
          final text = parts != null && parts.isNotEmpty ? parts[0]["text"] : null;
          debugPrint("✅ [AI Response Text]: $text");
          return text ?? "Sorry, I couldn’t generate a response.";
        } else {
          debugPrint("⚠️ [Warning]: No candidates returned from AI.");
          return "No response from AI.";
        }
      } else {
        debugPrint("❌ [Error] Response failed: ${response.body}");
        throw Exception("Failed to fetch AI response: ${response.body}");
      }
    } catch (e, stack) {
      debugPrint("💥 [Exception Caught]: $e");
      debugPrint("🧱 [Stack Trace]: $stack");
      return "Error occurred while connecting to AI: $e";
    }
  }


  // --------------------------------------------------------------
  // 🌱 NEW METHOD: Fetch Plant Details by Name (text-based request)
  // --------------------------------------------------------------
  Future<PlantModel> fetchPlantDetailsByName(String plantName) async {
    final url = Uri.parse(
      "$baseUrl/models/gemini-2.5-flash-image:generateContent?key=$apiKey",
    );

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
      "contents": [
        {
          "role": "user",
          "parts": [
            {"text": prompt}
          ]
        }
      ]
    };

    try {
      debugPrint("🌱 [GeminiChatApiService] Fetching details for: $plantName");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      debugPrint("📡 [Response Code]: ${response.statusCode}");
      if (response.statusCode != 200) {
        throw Exception("Gemini API error: ${response.body}");
      }

      final data = jsonDecode(response.body);
      final text = data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"];

      if (text == null || text.isEmpty) {
        throw Exception("Empty response for plant: $plantName");
      }

      final jsonData = _extractJsonFromText(text);
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
    final url = Uri.parse(
      "$baseUrl/models/gemini-2.5-flash-image:generateContent?key=$apiKey",
    );

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
      "contents": [
        {
          "role": "user",
          "parts": [
            {"text": prompt}
          ]
        }
      ]
    };

    try {
      debugPrint("🌊 [Gemini] Fetching watering plan for: $plantName");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      debugPrint("📡 [Response Code]: ${response.statusCode}");
      if (response.statusCode != 200) {
        debugPrint("❌ [Gemini] error: ${response.body}");
        throw Exception("Gemini API error: ${response.body}");
      }

      final data = jsonDecode(response.body);
      final text = data["candidates"]?[0]?["content"]?[0]?["parts"]?[0]?["text"]
          ?? data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"];

      if (text == null || (text as String).trim().isEmpty) {
        throw Exception("Empty response from Gemini for watering plan");
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

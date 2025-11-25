// lib/models/search_model.dart
class SearchModel {
  final int id;
  final String commonName; // We’ll map from "alt" or photographer
  final String? scientificName; // Not provided by Pexels, keep null for now
  final String? imageUrl;
  final String? description; // We can later fill with Gemini-generated text

  SearchModel({
    required this.id,
    required this.commonName,
    this.scientificName,
    this.imageUrl,
    this.description,
  });

  /// Factory constructor to parse JSON from Pexels API
  factory SearchModel.fromJson(Map<String, dynamic> json) {
    return SearchModel(
      id: json['id'] ?? 0,
      commonName: json['alt'] ?? "Unknown Plant", // Use alt text as plant name
      scientificName: null, // Not available in Pexels API
      imageUrl: json['src'] != null ? json['src']['medium'] : null,
      description: json['photographer'] != null
          ? "Photo by ${json['photographer']}"
          : null, // Optional fallback
    );
  }
}

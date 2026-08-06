class PestModel {
  final String name;
  final String scientificName;
  final double confidence;
  final String description;
  final String symptoms;
  final String organicTreatment;
  final String prevention;
  final List<String> affectedPlants;
  String? imagePath;

  PestModel({
    required this.name,
    required this.scientificName,
    required this.confidence,
    required this.description,
    required this.symptoms,
    required this.organicTreatment,
    required this.prevention,
    required this.affectedPlants,
    this.imagePath,
  });

  /// Safely convert a field that could be String or List to String
  static String _asString(dynamic value, [String fallback = '']) {
    if (value == null) return fallback;
    if (value is String) return value;
    if (value is List) return value.join('\n');
    return value.toString();
  }

  factory PestModel.fromJson(Map<String, dynamic> json) {
    return PestModel(
      name: _asString(json['name'], 'Unknown Pest'),
      scientificName: _asString(json['scientific_name']),
      confidence: (json['confidence'] is num)
          ? (json['confidence'] as num).toDouble()
          : 1.0,
      description: _asString(json['description']),
      symptoms: _asString(json['symptoms']),
      organicTreatment: _asString(json['organic_treatment']),
      prevention: _asString(json['prevention']),
      affectedPlants: List<String>.from(json['affected_plants'] ?? []),
    );
  }
}

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

  factory PestModel.fromJson(Map<String, dynamic> json) {
    return PestModel(
      name: json['name'] ?? 'Unknown Pest',
      scientificName: json['scientific_name'] ?? '',
      confidence: (json['confidence'] is num)
          ? (json['confidence'] as num).toDouble()
          : 1.0,
      description: json['description'] ?? '',
      symptoms: json['symptoms'] ?? '',
      organicTreatment: json['organic_treatment'] ?? '',
      prevention: json['prevention'] ?? '',
      affectedPlants: List<String>.from(json['affected_plants'] ?? []),
    );
  }
}

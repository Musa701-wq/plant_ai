// lib/modules/scan/gemini/model/plant_model.dart
class PlantModel {
  final String name;
  final String scientificName;
  final double confidence;
  final String about;
  final PlantDetails details;
  final String commonProblems;
  final List<FAQItem> faqs;
  final List<String> funFacts;
  String? imagePath;


  PlantModel({
    required this.name,
    required this.scientificName,
    required this.confidence,
    required this.about,
    required this.details,
    required this.commonProblems,
    required this.faqs,
    required this.funFacts,
    this.imagePath,
  });

  factory PlantModel.fromJson(Map<String, dynamic> json) {
    return PlantModel(
      name: json['name'] ?? '',
      scientificName: json['scientific_name'] ?? '',
      confidence: (json['confidence'] is num)
          ? (json['confidence'] as num).toDouble()
          : 1.0,
      about: json['about'] ?? json['description'] ?? '',
      details: PlantDetails.fromJson(json['details'] ?? {}),
      commonProblems: json['common_problems'] ?? '',
      faqs: (json['faqs'] as List?)
          ?.map((item) => FAQItem.fromJson(item))
          .toList() ??
          [],
      funFacts: List<String>.from(json['fun_facts'] ?? []),
    );
  }

  /// Fallback parser for loose or simplified JSON
  factory PlantModel.fromGeminiResponse(Map<String, dynamic> json) {
    final careTipsRaw = json['care_tips'] ?? json['details'] ?? '';
    final careLines = careTipsRaw.toString().split(RegExp(r'[\n•-]+')).map((t) => t.trim()).toList();

    return PlantModel(
      name: json['name'] ?? 'Unknown Plant',
      scientificName: json['scientific_name'] ?? '',
      confidence: (json['confidence'] is num)
          ? (json['confidence'] as num).toDouble()
          : 1.0,
      about: json['description'] ?? json['about'] ?? '',
      details: PlantDetails(
        temperatureRange: _extractByKeyword(careLines, ['temperature', 'cold', 'heat']),
        sunlight: _extractByKeyword(careLines, ['sunlight', 'light', 'shade']),
        watering: _extractByKeyword(careLines, ['water', 'moisture']),
        repotting: _extractByKeyword(careLines, ['repot', 'soil']),
        fertilizing: _extractByKeyword(careLines, ['fertilizer', 'feed']),
        pests: _extractByKeyword(careLines, ['pest', 'disease']),
      ),
      commonProblems: json['common_problems'] ??
          'May suffer from overwatering or lack of sunlight.',
      faqs: (json['faqs'] as List?)
          ?.map((item) => FAQItem.fromJson(item))
          .toList() ??
          [
            FAQItem(
              question: 'How often should I water ${json['name'] ?? 'this plant'}?',
              answer: 'Water when the top soil feels dry to the touch.',
            ),
          ],
      funFacts: List<String>.from(json['fun_facts'] ?? [
        'This plant helps purify indoor air naturally.',
        'It’s a popular choice among home gardeners.',
      ]),
    );
  }

  static String _extractByKeyword(List<String> lines, List<String> keywords) {
    for (final line in lines) {
      for (final keyword in keywords) {
        if (line.toLowerCase().contains(keyword)) return line;
      }
    }
    return lines.isNotEmpty ? lines.first : '';
  }
}

class PlantDetails {
  final String temperatureRange;
  final String sunlight;
  final String watering;
  final String repotting;
  final String fertilizing;
  final String pests;

  const PlantDetails({
    required this.temperatureRange,
    required this.sunlight,
    required this.watering,
    required this.repotting,
    required this.fertilizing,
    required this.pests,
  });

  factory PlantDetails.fromJson(Map<String, dynamic> json) {
    return PlantDetails(
      temperatureRange: json['temperature_range'] ?? '',
      sunlight: json['sunlight'] ?? '',
      watering: json['watering'] ?? '',
      repotting: json['repotting'] ?? '',
      fertilizing: json['fertilizing'] ?? '',
      pests: json['pests'] ?? '',
    );
  }
}

class FAQItem {
  final String question;
  final String answer;

  const FAQItem({required this.question, required this.answer});

  factory FAQItem.fromJson(Map<String, dynamic> json) {
    return FAQItem(
      question: json['q'] ?? '',
      answer: json['a'] ?? '',
    );
  }
}

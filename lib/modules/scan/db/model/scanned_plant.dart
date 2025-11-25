// lib/modules/scan/local/scanned_plant.dart
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../gemini/model/plant_model.dart';
part 'scanned_plant.g.dart';

@HiveType(typeId: 10)
class ScannedPlant extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String? name;

  @HiveField(2)
  String? scientificName;

  @HiveField(3)
  double? confidence;

  @HiveField(4)
  String? about;

  @HiveField(5)
  PlantDetailsHive? details;

  @HiveField(6)
  String? commonProblems;

  @HiveField(7)
  List<FAQItemHive>? faqs;

  @HiveField(8)
  List<String>? funFacts;

  @HiveField(9)
  String? imagePath; // local path to captured image (optional)

  @HiveField(10)
  DateTime scannedAt;

  ScannedPlant({
    required this.id,
    this.name,
    this.scientificName,
    this.confidence,
    this.about,
    this.details,
    this.commonProblems,
    this.faqs,
    this.funFacts,
    this.imagePath,
    required this.scannedAt,
  });

  /// Create ScannedPlant from your PlantModel and optional imagePath
  factory ScannedPlant.fromPlantModel(PlantModel model, {String? imagePath}) {
    return ScannedPlant(
      id: const Uuid().v4(),
      name: model.name,
      scientificName: model.scientificName,
      confidence: model.confidence,
      about: model.about,
      details: PlantDetailsHive.fromPlantDetails(model.details),
      commonProblems: model.commonProblems,
      faqs: model.faqs.map((f) => FAQItemHive.fromFaqItem(f)).toList(),
      funFacts: model.funFacts,
      imagePath: imagePath,
      scannedAt: DateTime.now(),
    );
  }

  /// Convert back to PlantModel for display or re-use
  PlantModel toPlantModel() {
    return PlantModel(
      name: name ?? 'Unknown Plant',
      scientificName: scientificName ?? '',
      confidence: confidence ?? 0.0,
      about: about ?? '',
      details:
          details?.toPlantDetails() ??
          PlantDetails(
            temperatureRange: '',
            sunlight: '',
            watering: '',
            repotting: '',
            fertilizing: '',
            pests: '',
          ),
      commonProblems: commonProblems ?? '',
      faqs: faqs?.map((f) => f.toFaqItem()).toList() ?? [],
      funFacts: funFacts ?? [],
      imagePath: imagePath
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'scientificName': scientificName,
      'confidence': confidence,
      'about': about,
      'details': details?.toMap(),
      'commonProblems': commonProblems,
      'faqs': faqs?.map((f) => f.toMap()).toList(),
      'funFacts': funFacts,
      'imagePath': imagePath,
      'scannedAt': scannedAt.toIso8601String(),
    };
  }
}

@HiveType(typeId: 11)
class PlantDetailsHive {
  @HiveField(0)
  String? temperatureRange;

  @HiveField(1)
  String? sunlight;

  @HiveField(2)
  String? watering;

  @HiveField(3)
  String? repotting;

  @HiveField(4)
  String? fertilizing;

  @HiveField(5)
  String? pests;

  PlantDetailsHive({
    this.temperatureRange,
    this.sunlight,
    this.watering,
    this.repotting,
    this.fertilizing,
    this.pests,
  });

  factory PlantDetailsHive.fromPlantDetails(PlantDetails d) {
    return PlantDetailsHive(
      temperatureRange: d.temperatureRange,
      sunlight: d.sunlight,
      watering: d.watering,
      repotting: d.repotting,
      fertilizing: d.fertilizing,
      pests: d.pests,
    );
  }

  PlantDetails toPlantDetails() {
    return PlantDetails(
      temperatureRange: temperatureRange ?? '',
      sunlight: sunlight ?? '',
      watering: watering ?? '',
      repotting: repotting ?? '',
      fertilizing: fertilizing ?? '',
      pests: pests ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'temperatureRange': temperatureRange,
      'sunlight': sunlight,
      'watering': watering,
      'repotting': repotting,
      'fertilizing': fertilizing,
      'pests': pests,
    };
  }
}

@HiveType(typeId: 12)
class FAQItemHive {
  @HiveField(0)
  String? question;

  @HiveField(1)
  String? answer;

  FAQItemHive({this.question, this.answer});

  factory FAQItemHive.fromFaqItem(FAQItem f) {
    return FAQItemHive(question: f.question, answer: f.answer);
  }

  FAQItem toFaqItem() {
    return FAQItem(question: question ?? '', answer: answer ?? '');
  }

  Map<String, dynamic> toMap() {
    return {'q': question, 'a': answer};
  }
}

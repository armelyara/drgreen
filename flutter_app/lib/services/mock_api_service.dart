import 'dart:io';
import '../models/plant.dart';
import 'api_service.dart';

/// Service Mock pour simuler l'API Dr Green
class MockApiService implements ApiService {
  @override
  Future<PredictionResult> identifyPlant(
    File imageFile, {
    bool useTta = true,
  }) async {
    // Simuler un délai réseau
    await Future.delayed(const Duration(seconds: 2));

    // Retourner un résultat fictif
    return PredictionResult(
      predictedClass: 'Artemisia annua',
      confidence: 0.95,
      allProbabilities: {
        'Artemisia annua': 0.95,
        'Moringa oleifera': 0.03,
        'Azadirachta indica': 0.02,
      },
      top3: [
        PredictionItem(className: 'Artemisia annua', confidence: 0.95),
        PredictionItem(className: 'Moringa oleifera', confidence: 0.03),
        PredictionItem(className: 'Azadirachta indica', confidence: 0.02),
      ],
    );
  }

  @override
  Future<List<String>> getClasses() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      'Artemisia annua',
      'Moringa oleifera',
      'Azadirachta indica',
      'Catharanthus roseus',
      'Cymbopogon citratus',
    ];
  }

  @override
  Future<bool> healthCheck() async {
    return true;
  }
}

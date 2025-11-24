import '../models/plant.dart';
import 'firestore_service.dart';

/// Service Firestore simulé pour le développement sans backend
class MockFirestoreService implements FirestoreService {
  // Données simulées
  final List<Plant> _mockPlants = [
    Plant(
      id: '1',
      nomScientifique: 'Artemisia annua',
      nomsCommuns: {'fr': 'Armoise annuelle', 'en': 'Sweet wormwood'},
      regionsCi: ['Abidjan', 'Yamoussoukro'],
      usagesTraditionnels: UsagesTraditionnels(
        maladies: ['Paludisme', 'Fièvre'],
        preparation: 'Infusion des feuilles séchées',
        posologie: 'Une tasse matin et soir pendant 7 jours',
        precautions: 'Déconseillé aux femmes enceintes',
      ),
      imagesUrls: ['https://upload.wikimedia.org/wikipedia/commons/thumb/6/66/Artemisia_annua_001.JPG/640px-Artemisia_annua_001.JPG'],
      dateAjout: DateTime.now(),
      auteurId: 'user1',
      statut: 'approuve',
    ),
    Plant(
      id: '2',
      nomScientifique: 'Moringa oleifera',
      nomsCommuns: {'fr': 'Moringa', 'dioula': 'Nébédaye'},
      regionsCi: ['Bouaké', 'Korhogo'],
      usagesTraditionnels: UsagesTraditionnels(
        maladies: ['Fatigue', 'Anémie', 'Hypertension'],
        preparation: 'Poudre de feuilles séchées',
        posologie: 'Une cuillère à café par jour dans les repas',
        precautions: 'Aucune contre-indication majeure connue',
      ),
      imagesUrls: ['https://upload.wikimedia.org/wikipedia/commons/thumb/5/52/Moringa_oleifera_3347.jpg/640px-Moringa_oleifera_3347.jpg'],
      dateAjout: DateTime.now().subtract(const Duration(days: 5)),
      auteurId: 'user2',
      statut: 'approuve',
    ),
    Plant(
      id: '3',
      nomScientifique: 'Kigelia africana',
      nomsCommuns: {'fr': 'Saucissonnier', 'baoulé': 'N\'gblin'},
      regionsCi: ['Nord', 'Centre'],
      usagesTraditionnels: UsagesTraditionnels(
        maladies: ['Problèmes de peau', 'Rhumatismes'],
        preparation: 'Décoction de l\'écorce ou du fruit',
        posologie: 'Application locale ou bain',
        precautions: 'Le fruit frais est toxique, ne pas ingérer',
      ),
      imagesUrls: ['https://upload.wikimedia.org/wikipedia/commons/thumb/c/c6/Kigelia_africana_fruit.jpg/640px-Kigelia_africana_fruit.jpg'],
      dateAjout: DateTime.now().subtract(const Duration(days: 10)),
      auteurId: 'user1',
      statut: 'approuve',
    ),
  ];

  @override
  Stream<List<Plant>> getApprovedPlants() {
    return Stream.value(_mockPlants);
  }

  @override
  Future<Plant?> getPlantById(String id) async {
    try {
      return _mockPlants.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Plant?> getPlantByScientificName(String name) async {
    try {
      return _mockPlants.firstWhere((p) => p.nomScientifique == name);
    } catch (e) {
      return null;
    }
  }

  @override
  Stream<List<Plant>> searchPlants(String query) {
    final lowerQuery = query.toLowerCase();
    final results = _mockPlants.where((plant) =>
        plant.nomScientifique.toLowerCase().contains(lowerQuery) ||
        plant.nomsCommuns.values.any(
            (name) => name.toLowerCase().contains(lowerQuery))).toList();
    return Stream.value(results);
  }

  @override
  Future<String> addContribution(Plant plant) async {
    // Simulation d'ajout
    return 'mock_id_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Stream<List<Plant>> getPendingContributions() {
    return Stream.value([]);
  }

  @override
  Future<void> approveContribution(String contributionId) async {
    // No-op
  }

  @override
  Future<void> rejectContribution(String contributionId) async {
    // No-op
  }

  @override
  Future<void> updatePlant(String id, Map<String, dynamic> data) async {
    // No-op
  }

  @override
  Future<void> deletePlant(String id) async {
    // No-op
  }

  @override
  Stream<List<Plant>> getPlantsByRegion(String region) {
    return Stream.value(_mockPlants.where((p) => p.regionsCi.contains(region)).toList());
  }

  @override
  Future<Map<String, int>> getStatistics() async {
    return {
      'total_plants': _mockPlants.length,
      'pending_contributions': 0,
    };
  }
}

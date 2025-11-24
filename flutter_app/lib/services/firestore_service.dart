import '../models/plant.dart';

/// Service Firestore (Interface)
abstract class FirestoreService {
  Stream<List<Plant>> getApprovedPlants();
  Future<Plant?> getPlantById(String id);
  Future<Plant?> getPlantByScientificName(String name);
  Stream<List<Plant>> searchPlants(String query);
  Future<String> addContribution(Plant plant);
  Stream<List<Plant>> getPendingContributions();
  Future<void> approveContribution(String contributionId);
  Future<void> rejectContribution(String contributionId);
  Future<void> updatePlant(String id, Map<String, dynamic> data);
  Future<void> deletePlant(String id);
  Stream<List<Plant>> getPlantsByRegion(String region);
  Future<Map<String, int>> getStatistics();
}

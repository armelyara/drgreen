import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/plant.dart';

/// Service Firestore pour gérer les données des plantes
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collections
  static const String plantsCollection = 'plants';
  static const String contributionsCollection = 'contributions';

  /// Obtenir toutes les plantes approuvées
  Stream<List<Plant>> getApprovedPlants() {
    return _db
        .collection(plantsCollection)
        .where('statut', isEqualTo: 'approuve')
        .orderBy('date_ajout', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Plant.fromFirestore(doc)).toList());
  }

  /// Obtenir une plante par ID
  Future<Plant?> getPlantById(String id) async {
    final doc = await _db.collection(plantsCollection).doc(id).get();
    if (doc.exists) {
      return Plant.fromFirestore(doc);
    }
    return null;
  }

  /// Obtenir une plante par nom scientifique
  Future<Plant?> getPlantByScientificName(String name) async {
    final querySnapshot = await _db
        .collection(plantsCollection)
        .where('nom_scientifique', isEqualTo: name)
        .where('statut', isEqualTo: 'approuve')
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return Plant.fromFirestore(querySnapshot.docs.first);
    }
    return null;
  }

  /// Rechercher des plantes par nom
  Stream<List<Plant>> searchPlants(String query) {
    return _db
        .collection(plantsCollection)
        .where('statut', isEqualTo: 'approuve')
        .snapshots()
        .map((snapshot) {
      final plants = snapshot.docs
          .map((doc) => Plant.fromFirestore(doc))
          .where((plant) =>
              plant.nomScientifique.toLowerCase().contains(query.toLowerCase()) ||
              plant.nomsCommuns.values.any(
                  (name) => name.toLowerCase().contains(query.toLowerCase())))
          .toList();
      return plants;
    });
  }

  /// Ajouter une contribution (nouvelle plante)
  Future<String> addContribution(Plant plant) async {
    final docRef = await _db.collection(contributionsCollection).add(
          plant.copyWith(statut: 'en_attente').toFirestore(),
        );
    return docRef.id;
  }

  /// Obtenir les contributions en attente (pour modération)
  Stream<List<Plant>> getPendingContributions() {
    return _db
        .collection(contributionsCollection)
        .where('statut', isEqualTo: 'en_attente')
        .orderBy('date_ajout', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Plant.fromFirestore(doc)).toList());
  }

  /// Approuver une contribution (modérateur)
  Future<void> approveContribution(String contributionId) async {
    final contribution =
        await _db.collection(contributionsCollection).doc(contributionId).get();

    if (contribution.exists) {
      // Créer la plante dans la collection principale
      await _db.collection(plantsCollection).add(
            Plant.fromFirestore(contribution)
                .copyWith(statut: 'approuve')
                .toFirestore(),
          );

      // Mettre à jour le statut de la contribution
      await _db
          .collection(contributionsCollection)
          .doc(contributionId)
          .update({'statut': 'approuve'});
    }
  }

  /// Rejeter une contribution (modérateur)
  Future<void> rejectContribution(String contributionId) async {
    await _db
        .collection(contributionsCollection)
        .doc(contributionId)
        .update({'statut': 'rejete'});
  }

  /// Mettre à jour une plante
  Future<void> updatePlant(String id, Map<String, dynamic> data) async {
    await _db.collection(plantsCollection).doc(id).update(data);
  }

  /// Supprimer une plante
  Future<void> deletePlant(String id) async {
    await _db.collection(plantsCollection).doc(id).delete();
  }

  /// Obtenir les plantes par région
  Stream<List<Plant>> getPlantsByRegion(String region) {
    return _db
        .collection(plantsCollection)
        .where('statut', isEqualTo: 'approuve')
        .where('regions_ci', arrayContains: region)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Plant.fromFirestore(doc)).toList());
  }

  /// Obtenir des statistiques
  Future<Map<String, int>> getStatistics() async {
    final plantsSnapshot = await _db
        .collection(plantsCollection)
        .where('statut', isEqualTo: 'approuve')
        .get();

    final pendingSnapshot = await _db
        .collection(contributionsCollection)
        .where('statut', isEqualTo: 'en_attente')
        .get();

    return {
      'total_plants': plantsSnapshot.docs.length,
      'pending_contributions': pendingSnapshot.docs.length,
    };
  }
}

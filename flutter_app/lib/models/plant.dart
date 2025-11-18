import 'package:cloud_firestore/cloud_firestore.dart';

/// Modèle de données pour une plante médicinale
class Plant {
  final String id;
  final String nomScientifique;
  final Map<String, String> nomsCommuns;
  final List<String> regionsCi;
  final UsagesTraditionnels usagesTraditionnels;
  final List<String> imagesUrls;
  final DateTime dateAjout;
  final String auteurId;
  final String statut; // 'approuve', 'en_attente', 'rejete'

  Plant({
    required this.id,
    required this.nomScientifique,
    required this.nomsCommuns,
    required this.regionsCi,
    required this.usagesTraditionnels,
    required this.imagesUrls,
    required this.dateAjout,
    required this.auteurId,
    this.statut = 'approuve',
  });

  /// Créer une plante depuis Firestore
  factory Plant.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Plant(
      id: doc.id,
      nomScientifique: data['nom_scientifique'] ?? '',
      nomsCommuns: Map<String, String>.from(data['noms_communs'] ?? {}),
      regionsCi: List<String>.from(data['regions_ci'] ?? []),
      usagesTraditionnels: UsagesTraditionnels.fromMap(
        data['usages_traditionnels'] ?? {},
      ),
      imagesUrls: List<String>.from(data['images_urls'] ?? []),
      dateAjout: (data['date_ajout'] as Timestamp).toDate(),
      auteurId: data['auteur_id'] ?? '',
      statut: data['statut'] ?? 'approuve',
    );
  }

  /// Convertir en Map pour Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nom_scientifique': nomScientifique,
      'noms_communs': nomsCommuns,
      'regions_ci': regionsCi,
      'usages_traditionnels': usagesTraditionnels.toMap(),
      'images_urls': imagesUrls,
      'date_ajout': Timestamp.fromDate(dateAjout),
      'auteur_id': auteurId,
      'statut': statut,
    };
  }

  /// Créer une copie avec modifications
  Plant copyWith({
    String? id,
    String? nomScientifique,
    Map<String, String>? nomsCommuns,
    List<String>? regionsCi,
    UsagesTraditionnels? usagesTraditionnels,
    List<String>? imagesUrls,
    DateTime? dateAjout,
    String? auteurId,
    String? statut,
  }) {
    return Plant(
      id: id ?? this.id,
      nomScientifique: nomScientifique ?? this.nomScientifique,
      nomsCommuns: nomsCommuns ?? this.nomsCommuns,
      regionsCi: regionsCi ?? this.regionsCi,
      usagesTraditionnels: usagesTraditionnels ?? this.usagesTraditionnels,
      imagesUrls: imagesUrls ?? this.imagesUrls,
      dateAjout: dateAjout ?? this.dateAjout,
      auteurId: auteurId ?? this.auteurId,
      statut: statut ?? this.statut,
    );
  }
}

/// Usages traditionnels d'une plante
class UsagesTraditionnels {
  final List<String> maladies;
  final String preparation;
  final String posologie;
  final String precautions;

  UsagesTraditionnels({
    required this.maladies,
    required this.preparation,
    required this.posologie,
    required this.precautions,
  });

  factory UsagesTraditionnels.fromMap(Map<String, dynamic> map) {
    return UsagesTraditionnels(
      maladies: List<String>.from(map['maladies'] ?? []),
      preparation: map['preparation'] ?? '',
      posologie: map['posologie'] ?? '',
      precautions: map['precautions'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'maladies': maladies,
      'preparation': preparation,
      'posologie': posologie,
      'precautions': precautions,
    };
  }
}

/// Résultat de prédiction de l'API
class PredictionResult {
  final String predictedClass;
  final double confidence;
  final Map<String, double> allProbabilities;
  final List<PredictionItem> top3;
  final Plant? plantInfo;

  PredictionResult({
    required this.predictedClass,
    required this.confidence,
    required this.allProbabilities,
    required this.top3,
    this.plantInfo,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    final prediction = json['prediction'] as Map<String, dynamic>;

    return PredictionResult(
      predictedClass: prediction['class'] as String,
      confidence: (prediction['confidence'] as num).toDouble(),
      allProbabilities: Map<String, double>.from(
        (prediction['all_probabilities'] as Map).map(
          (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
        ),
      ),
      top3: (prediction['top_3'] as List)
          .map((item) => PredictionItem.fromJson(item))
          .toList(),
      plantInfo: null, // Will be populated from Firestore
    );
  }
}

/// Item de prédiction (top 3)
class PredictionItem {
  final String className;
  final double confidence;

  PredictionItem({
    required this.className,
    required this.confidence,
  });

  factory PredictionItem.fromJson(Map<String, dynamic> json) {
    return PredictionItem(
      className: json['class'] as String,
      confidence: (json['confidence'] as num).toDouble(),
    );
  }
}

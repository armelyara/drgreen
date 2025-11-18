import 'dart:io';
import 'package:dio/dio.dart';
import '../models/plant.dart';

/// Service pour appeler l'API Dr Green
class ApiService {
  // À remplacer par votre URL Cloud Run après déploiement
  static const String baseUrl = 'YOUR_CLOUD_RUN_URL';

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  /// Identifier une plante à partir d'une image
  Future<PredictionResult> identifyPlant(
    File imageFile, {
    bool useTta = true,
  }) async {
    try {
      // Créer FormData avec l'image
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
        'use_tta': useTta,
      });

      // Envoyer la requête
      final response = await _dio.post(
        '/api/v1/identify',
        data: formData,
      );

      if (response.statusCode == 200) {
        return PredictionResult.fromJson(response.data);
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Timeout: Vérifiez votre connexion internet');
      } else if (e.type == DioExceptionType.badResponse) {
        throw Exception('Erreur serveur: ${e.response?.statusCode}');
      } else {
        throw Exception('Erreur réseau: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erreur inconnue: $e');
    }
  }

  /// Obtenir la liste des classes de plantes
  Future<List<String>> getClasses() async {
    try {
      final response = await _dio.get('/api/v1/classes');

      if (response.statusCode == 200) {
        return List<String>.from(response.data['classes']);
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des classes: $e');
    }
  }

  /// Vérifier l'état de santé de l'API
  Future<bool> healthCheck() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

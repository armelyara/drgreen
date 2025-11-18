import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

/// Service pour gérer le stockage d'images dans Firebase Storage
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload une image et retourner l'URL
  Future<String> uploadPlantImage(
    File file,
    String plantName, {
    bool isContribution = false,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${plantName}_$timestamp.jpg';

      final path = isContribution
          ? 'contributions/$fileName'
          : 'plants/$fileName';

      final ref = _storage.ref().child(path);

      // Upload le fichier
      final uploadTask = await ref.putFile(
        file,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'uploaded_at': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Obtenir l'URL de téléchargement
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Erreur lors de l\'upload de l\'image: $e');
    }
  }

  /// Upload plusieurs images
  Future<List<String>> uploadMultipleImages(
    List<File> files,
    String plantName, {
    bool isContribution = false,
  }) async {
    final List<String> urls = [];

    for (int i = 0; i < files.length; i++) {
      final url = await uploadPlantImage(
        files[i],
        '${plantName}_$i',
        isContribution: isContribution,
      );
      urls.add(url);
    }

    return urls;
  }

  /// Supprimer une image
  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'image: $e');
    }
  }

  /// Supprimer plusieurs images
  Future<void> deleteMultipleImages(List<String> imageUrls) async {
    for (final url in imageUrls) {
      await deleteImage(url);
    }
  }
}

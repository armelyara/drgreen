import 'dart:io';

/// Service de stockage simulé
class StorageService {
  /// Upload une image et retourner l'URL
  Future<String> uploadPlantImage(
    File file,
    String plantName, {
    bool isContribution = false,
  }) async {
    // Simulation d'upload
    await Future.delayed(const Duration(seconds: 1));
    return 'https://via.placeholder.com/400x300?text=${Uri.encodeComponent(plantName)}';
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
    // No-op
  }

  /// Supprimer plusieurs images
  Future<void> deleteMultipleImages(List<String> imageUrls) async {
    // No-op
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/theme.dart';
import '../services/api_service.dart';
import '../services/firestore_service.dart';
import '../models/plant.dart';
import 'result_screen.dart';

/// Écran de capture/sélection d'image pour identification
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner une plante'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Instructions
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.info.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.info,
                        size: 40,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Conseils pour une bonne identification',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.info,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildTip('Cadrez bien les feuilles ou fleurs'),
                      _buildTip('Assurez un bon éclairage'),
                      _buildTip('Évitez les images floues'),
                    ],
                  ),
                ),

                const SizedBox(height: 60),

                // Bouton Caméra
                _buildImageSourceButton(
                  icon: Icons.camera_alt,
                  label: 'Prendre une photo',
                  color: AppColors.accent,
                  onPressed: () => _pickImage(ImageSource.camera),
                ),

                const SizedBox(height: 20),

                // Bouton Galerie
                _buildImageSourceButton(
                  icon: Icons.photo_library,
                  label: 'Choisir depuis la galerie',
                  color: AppColors.primary,
                  onPressed: () => _pickImage(ImageSource.gallery),
                ),

                if (_isProcessing) ...[
                  const SizedBox(height: 40),
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Analyse en cours...',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            size: 16,
            color: AppColors.success,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSourceButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isProcessing ? null : onPressed,
        icon: Icon(icon, size: 28),
        label: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      // Sélectionner l'image
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
        _isProcessing = true;
      });

      // Appeler l'API pour identifier la plante
      final apiService = context.read<ApiService>();
      final firestoreService = context.read<FirestoreService>();

      final result = await apiService.identifyPlant(File(image.path));

      // Récupérer les informations complètes depuis Firestore
      final plant = await firestoreService.getPlantByScientificName(
        _mapClassToScientificName(result.predictedClass),
      );

      setState(() {
        _isProcessing = false;
      });

      // Naviguer vers l'écran de résultat
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              imageFile: File(image.path),
              result: result,
              plant: plant,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // Mapper le nom de classe à nom scientifique
  String _mapClassToScientificName(String className) {
    const mapping = {
      'artemisia': 'Artemisia annua',
      'carica': 'Carica papaya',
      'goyavier': 'Psidium guajava',
      'kinkeliba': 'Combretum micranthum',
    };
    return mapping[className] ?? className;
  }
}

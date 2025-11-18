import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/theme.dart';
import '../models/plant.dart';
import 'detail_screen.dart';

/// Écran de résultat après identification
class ResultScreen extends StatelessWidget {
  final File imageFile;
  final PredictionResult result;
  final Plant? plant;

  const ResultScreen({
    super.key,
    required this.imageFile,
    required this.result,
    this.plant,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultat'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image scannée
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: FileImage(imageFile),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Résultat principal
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                    decoration: BoxDecoration(
                      color: _getConfidenceColor(result.confidence)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _getConfidenceColor(result.confidence),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 64,
                          color: _getConfidenceColor(result.confidence),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          plant?.nomScientifique ?? result.predictedClass,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (plant != null &&
                            plant!.nomsCommuns.containsKey('fr')) ...[
                          const SizedBox(height: 8),
                          Text(
                            plant!.nomsCommuns['fr']!,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.verified,
                              size: 20,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Confiance: ${(result.confidence * 100).toStringAsFixed(1)}%',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Top 3 prédictions
                  Text(
                    'Autres possibilités',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ...result.top3.skip(1).map((prediction) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.greyLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            prediction.className,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${(prediction.confidence * 100).toStringAsFixed(1)}%',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 32),

                  // Bouton voir détails
                  if (plant != null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailScreen(plant: plant!),
                            ),
                          );
                        },
                        icon: const Icon(Icons.info_outline),
                        label: const Text('Voir les détails de la plante'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) {
      return AppColors.success;
    } else if (confidence >= 0.6) {
      return AppColors.warning;
    } else {
      return AppColors.error;
    }
  }
}

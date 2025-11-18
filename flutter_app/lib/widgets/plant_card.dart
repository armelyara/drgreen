import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../utils/theme.dart';
import '../models/plant.dart';

/// Widget pour afficher une carte de plante dans la bibliothèque
class PlantCard extends StatelessWidget {
  final Plant plant;
  final VoidCallback onTap;

  const PlantCard({
    super.key,
    required this.plant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingMedium),
      elevation: AppDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.borderRadius),
                bottomLeft: Radius.circular(AppDimensions.borderRadius),
              ),
              child: plant.imagesUrls.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: plant.imagesUrls.first,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 120,
                        height: 120,
                        color: AppColors.greyLight,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 120,
                        height: 120,
                        color: AppColors.greyLight,
                        child: const Icon(
                          Icons.local_florist,
                          size: 40,
                          color: AppColors.greyMedium,
                        ),
                      ),
                    )
                  : Container(
                      width: 120,
                      height: 120,
                      color: AppColors.primary.withOpacity(0.1),
                      child: const Icon(
                        Icons.local_florist,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),
            ),

            // Informations
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nom scientifique
                    Text(
                      plant.nomScientifique,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Nom commun
                    if (plant.nomsCommuns.containsKey('fr'))
                      Text(
                        plant.nomsCommuns['fr']!,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                    const SizedBox(height: 8),

                    // Régions
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            plant.regionsCi.join(', '),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Maladies traitées
                    if (plant.usagesTraditionnels.maladies.isNotEmpty)
                      Row(
                        children: [
                          const Icon(
                            Icons.healing,
                            size: 14,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              plant.usagesTraditionnels.maladies.join(', '),
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            // Flèche
            const Padding(
              padding: EdgeInsets.all(AppDimensions.paddingMedium),
              child: Icon(
                Icons.chevron_right,
                color: AppColors.greyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

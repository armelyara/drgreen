import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/theme.dart';
import '../models/plant.dart';

/// Écran de détails d'une plante
class DetailScreen extends StatelessWidget {
  final Plant plant;

  const DetailScreen({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar avec image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                plant.nomScientifique,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.8),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Image or Fallback Gradient
                  plant.imagesUrls.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: plant.imagesUrls.first,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppColors.greyLight,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.primary,
                                  AppColors.secondary,
                                ],
                              ),
                            ),
                            child: const Icon(
                              Icons.local_florist,
                              size: 64,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primary,
                                AppColors.secondary,
                              ],
                            ),
                          ),
                          child: const Icon(
                            Icons.local_florist,
                            size: 100,
                            color: Colors.white,
                          ),
                        ),
                  
                  // Gradient Overlay for text readability
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.2),
                          Colors.black.withOpacity(0.7),
                        ],
                        stops: const [0.6, 0.8, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Contenu
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Noms communs
                  _buildSection(
                    icon: Icons.language,
                    title: 'Noms communs',
                    color: AppColors.secondary,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: plant.nomsCommuns.entries
                          .map((entry) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondary.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        entry.key.toUpperCase(),
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.secondary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        entry.value,
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Localisation
                  _buildSection(
                    icon: Icons.location_on,
                    title: 'Localisation en Côte d\'Ivoire',
                    color: AppColors.accent,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: plant.regionsCi
                          .map((region) => ActionChip(
                                label: Text(
                                  region,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: AppColors.accent,
                                  ),
                                ),
                                backgroundColor: AppColors.accent.withOpacity(0.1),
                                side: BorderSide(
                                  color: AppColors.accent.withOpacity(0.3),
                                ),
                                onPressed: () async {
                                  final query = Uri.encodeComponent('$region, Côte d\'Ivoire');
                                  final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
                                  
                                  try {
                                    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Impossible d\'ouvrir la carte')),
                                        );
                                      }
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Erreur: $e')),
                                      );
                                    }
                                  }
                                },
                              ))
                          .toList(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Usages traditionnels (Le cœur de l'app)
                  _buildSection(
                    icon: Icons.healing,
                    title: 'Usages Traditionnels',
                    color: AppColors.primary,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Maladies traitées
                        _buildSubSection(
                          title: 'Ce que ça soigne',
                          content: plant.usagesTraditionnels.maladies
                              .map((m) => '• $m')
                              .join('\n'),
                        ),

                        const SizedBox(height: 16),

                        // Préparation
                        _buildSubSection(
                          title: 'Mode de préparation',
                          content: plant.usagesTraditionnels.preparation,
                        ),

                        const SizedBox(height: 16),

                        // Posologie
                        _buildSubSection(
                          title: 'Posologie',
                          content: plant.usagesTraditionnels.posologie,
                        ),

                        const SizedBox(height: 16),

                        // Précautions (Important!)
                        Container(
                          padding: const EdgeInsets.all(
                            AppDimensions.paddingMedium,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.warning.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.warning_amber_rounded,
                                    color: AppColors.warning,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Avertissement',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.warning,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                plant.usagesTraditionnels.precautions,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Galerie d'images
                  if (plant.imagesUrls.length > 1) ...[
                    _buildSection(
                      icon: Icons.photo_library,
                      title: 'Galerie d\'images',
                      color: AppColors.info,
                      child: SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: plant.imagesUrls.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  imageUrl: plant.imagesUrls[index],
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Disclaimer final
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                    decoration: BoxDecoration(
                      color: AppColors.greyLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Les informations présentées sont basées sur des usages traditionnels. '
                      'Elles ne remplacent pas un avis médical professionnel. '
                      'Consultez toujours un professionnel de santé avant utilisation.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required Color color,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildSubSection({
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.textPrimary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

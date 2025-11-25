import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';


import '../utils/theme.dart';
import '../models/plant.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

/// Écran de contribution - Ajouter une nouvelle plante
class ContributeScreen extends StatefulWidget {
  const ContributeScreen({super.key});

  @override
  State<ContributeScreen> createState() => _ContributeScreenState();
}

class _ContributeScreenState extends State<ContributeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomScientifiqueController = TextEditingController();
  final _nomFrController = TextEditingController();
  final _nomEnController = TextEditingController();
  final _nomBaouleController = TextEditingController();
  final _nomDioulaController = TextEditingController();
  final _preparationController = TextEditingController();
  final _posologieController = TextEditingController();
  final _precautionsController = TextEditingController();

  final List<String> _selectedRegions = [];
  final List<String> _maladies = [];
  final List<File> _selectedImages = [];
  bool _isSubmitting = false;

  final ImagePicker _picker = ImagePicker();

  final List<String> _regionsCI = [
    'Abidjan',
    'Yamoussoukro',
    'Bouaké',
    'Korhogo',
    'Daloa',
    'San-Pédro',
    'Man',
    'Gagnoa',
  ];

  @override
  void dispose() {
    _nomScientifiqueController.dispose();
    _nomFrController.dispose();
    _nomEnController.dispose();
    _nomBaouleController.dispose();
    _nomDioulaController.dispose();
    _preparationController.dispose();
    _posologieController.dispose();
    _precautionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final user = authService.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Contribuer')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.account_circle,
                  size: 80,
                  color: AppColors.greyMedium,
                ),
                const SizedBox(height: 24),
                Text(
                  'Connectez-vous pour contribuer',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Vous devez être connecté pour ajouter de nouvelles plantes à la bibliothèque',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to login screen
                  },
                  icon: const Icon(Icons.login),
                  label: const Text('Se connecter'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter une plante'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          children: [
            // Introduction
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.info),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Partagez vos connaissances ! Vos contributions seront vérifiées avant publication.',
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Nom scientifique
            TextFormField(
              controller: _nomScientifiqueController,
              decoration: _inputDecoration(
                label: 'Nom scientifique *',
                icon: Icons.science,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Champ obligatoire';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Noms communs
            Text(
              'Noms communs',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            TextFormField(
              controller: _nomFrController,
              decoration: _inputDecoration(
                label: 'Français',
                icon: Icons.language,
              ),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _nomEnController,
              decoration: _inputDecoration(
                label: 'Anglais',
                icon: Icons.language,
              ),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _nomBaouleController,
              decoration: _inputDecoration(
                label: 'Baoulé',
                icon: Icons.language,
              ),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _nomDioulaController,
              decoration: _inputDecoration(
                label: 'Dioula',
                icon: Icons.language,
              ),
            ),

            const SizedBox(height: 24),

            // Régions
            Text(
              'Régions en Côte d\'Ivoire *',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _regionsCI.map((region) {
                final isSelected = _selectedRegions.contains(region);
                return FilterChip(
                  label: Text(region),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedRegions.add(region);
                      } else {
                        _selectedRegions.remove(region);
                      }
                    });
                  },
                  selectedColor: AppColors.primary.withOpacity(0.3),
                  checkmarkColor: AppColors.primary,
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Usages traditionnels
            Text(
              'Usages traditionnels',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _preparationController,
              decoration: _inputDecoration(
                label: 'Mode de préparation *',
                icon: Icons.restaurant,
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Champ obligatoire';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _posologieController,
              decoration: _inputDecoration(
                label: 'Posologie *',
                icon: Icons.medication,
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Champ obligatoire';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _precautionsController,
              decoration: _inputDecoration(
                label: 'Précautions *',
                icon: Icons.warning_amber,
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Champ obligatoire';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Images
            Text(
              'Photos de la plante *',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            if (_selectedImages.isEmpty)
              OutlinedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Ajouter des photos (3-5)'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                  foregroundColor: AppColors.primary,
                ),
              )
            else ...[
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _selectedImages.length) {
                      return GestureDetector(
                        onTap: _pickImages,
                        child: Container(
                          width: 120,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.primary,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 40,
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    }

                    return Stack(
                      children: [
                        Container(
                          width: 120,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: FileImage(_selectedImages[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 16,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedImages.removeAt(index);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Bouton de soumission
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitContribution,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Soumettre ma contribution'),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.primary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.greyLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage(
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images.map((xfile) => File(xfile.path)));
        // Limiter à 5 images max
        if (_selectedImages.length > 5) {
          _selectedImages.removeRange(5, _selectedImages.length);
        }
      });
    }
  }

  Future<void> _submitContribution() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez ajouter au moins une photo'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedRegions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner au moins une région'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final authService = context.read<AuthService>();
      final firestoreService = context.read<FirestoreService>();
      final storageService = context.read<StorageService>();

      // Upload images using StorageService
      final List<String> imageUrls = [];
      for (int i = 0; i < _selectedImages.length; i++) {
        final file = _selectedImages[i];
        final url = await storageService.uploadPlantImage(
          file,
          'contribution_${DateTime.now().millisecondsSinceEpoch}',
          isContribution: true,
        );
        imageUrls.add(url);
      }

      // Create plant object
      final plant = Plant(
        id: '',
        nomScientifique: _nomScientifiqueController.text.trim(),
        nomsCommuns: {
          if (_nomFrController.text.isNotEmpty)
            'fr': _nomFrController.text.trim(),
          if (_nomEnController.text.isNotEmpty)
            'en': _nomEnController.text.trim(),
          if (_nomBaouleController.text.isNotEmpty)
            'baoulé': _nomBaouleController.text.trim(),
          if (_nomDioulaController.text.isNotEmpty)
            'dioula': _nomDioulaController.text.trim(),
        },
        regionsCi: _selectedRegions,
        usagesTraditionnels: UsagesTraditionnels(
          maladies: _maladies,
          preparation: _preparationController.text.trim(),
          posologie: _posologieController.text.trim(),
          precautions: _precautionsController.text.trim(),
        ),
        imagesUrls: imageUrls,
        dateAjout: DateTime.now(),
        dateAjout: DateTime.now(),
        auteurId: (authService.currentUser as Map)['uid'],
        statut: 'en_attente',
        statut: 'en_attente',
      );

      // Submit to Firestore
      await firestoreService.addContribution(plant);

      setState(() {
        _isSubmitting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contribution soumise avec succès ! Elle sera vérifiée par un modérateur.'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 4),
          ),
        );

        // Reset form
        _formKey.currentState!.reset();
        _selectedImages.clear();
        _selectedRegions.clear();
        _maladies.clear();
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la soumission: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

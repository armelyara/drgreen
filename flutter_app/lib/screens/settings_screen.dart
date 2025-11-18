import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/theme.dart';
import '../services/auth_service.dart';

/// Écran de paramètres
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: ListView(
        children: [
          // Section Compte
          _buildSectionHeader('Compte'),

          if (user != null)
            ListTile(
              leading: const Icon(Icons.account_circle, color: AppColors.primary),
              title: Text(user.email ?? 'Utilisateur anonyme'),
              subtitle: const Text('Email'),
            )
          else
            ListTile(
              leading: const Icon(Icons.login, color: AppColors.primary),
              title: const Text('Se connecter'),
              subtitle: const Text('Connectez-vous pour contribuer'),
              onTap: () {
                // Navigate to login screen
              },
            ),

          if (user != null)
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text('Se déconnecter'),
              onTap: () async {
                await authService.signOut();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Déconnexion réussie'),
                    ),
                  );
                }
              },
            ),

          const Divider(),

          // Section À propos
          _buildSectionHeader('À propos'),

          ListTile(
            leading: const Icon(Icons.info_outline, color: AppColors.info),
            title: const Text('À propos de Dr Green'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Dr Green',
                applicationVersion: '2.0.0',
                applicationIcon: const Icon(
                  Icons.local_florist,
                  size: 48,
                  color: AppColors.primary,
                ),
                children: [
                  Text(
                    'Bibliothèque collaborative de la botanique africaine',
                    style: GoogleFonts.poppins(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Dr Green est une application d\'identification de plantes '
                    'médicinales intégrant les méthodes de guérison traditionnelle '
                    'africaine.',
                    style: GoogleFonts.poppins(),
                  ),
                ],
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.policy_outlined, color: AppColors.info),
            title: const Text('Politique de confidentialité'),
            onTap: () {
              // Navigate to privacy policy
            },
          ),

          ListTile(
            leading: const Icon(Icons.article_outlined, color: AppColors.info),
            title: const Text('Conditions d\'utilisation'),
            onTap: () {
              // Navigate to terms
            },
          ),

          const Divider(),

          // Section Support
          _buildSectionHeader('Support'),

          ListTile(
            leading: const Icon(Icons.help_outline, color: AppColors.secondary),
            title: const Text('Aide et FAQ'),
            onTap: () {
              // Navigate to help
            },
          ),

          ListTile(
            leading: const Icon(Icons.feedback_outlined, color: AppColors.secondary),
            title: const Text('Envoyer un feedback'),
            onTap: () {
              // Navigate to feedback form
            },
          ),

          const Divider(),

          // Version
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            child: Text(
              'Version 2.0.0\n© 2024 Dr Green',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

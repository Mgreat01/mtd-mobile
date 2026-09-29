import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moto_taxi_digital_mobile/pages/register/registerCtrl.dart';
import 'kycController.dart';

class KycPage extends ConsumerWidget {
  const KycPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kycState = ref.watch(kycControllerProvider);
    final kycControl = ref.read(kycControllerProvider.notifier);
    final registerState = ref.watch(registerControlProvider);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
            "Documents KYC",
            style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold)
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Veuillez charger les documents requis pour valider votre compte professionnel.",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 30),

            _buildDocTile(context, "Carte d'identité (CNI)", kycState.identityDoc, () => kycControl.pickDocument('identity')),
            _buildDocTile(context, "Permis de conduire", kycState.registrationCard, () => kycControl.pickDocument('registration')),
            _buildDocTile(context, "Document commercial / License", kycState.businessLicense, () => kycControl.pickDocument('business')),

            const SizedBox(height: 30),
            Center(child: _buildSelfieSection(context, kycState.selfie, () => kycControl.pickDocument('selfie'))),

            if (kycState.error != null)
              Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(kycState.error!, style: TextStyle(color: colorScheme.error, fontWeight: FontWeight.w500))
              ),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: (kycState.isLoading || registerState.isLoading) ? null : () => _handleFinalSubmit(ref, context),
                style: theme.elevatedButtonTheme.style, // Utilise le style de AppTheme
                child: (kycState.isLoading || registerState.isLoading)
                    ? CircularProgressIndicator(color: colorScheme.onPrimary)
                    : const Text(
                    "Finaliser l'inscription",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleFinalSubmit(WidgetRef ref, BuildContext context) async {
    final tempUser = ref.read(registerControlProvider).user;
    if (tempUser == null) return;

    final success = await ref.read(kycControllerProvider.notifier).submitKyc(tempUser);

    if (success && context.mounted) {
      context.go('/app/home');

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Inscription réussie ! Votre dossier est en cours d'examen."),
              duration: Duration(seconds: 5),
              backgroundColor: Colors.blueAccent
          )
      );
    }
  }

  Widget _buildDocTile(BuildContext context, String label, File? file, VoidCallback onTap) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
          color: theme.inputDecorationTheme.fillColor, // Utilise la couleur de fond des inputs
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3))
      ),
      child: ListTile(
        title: Text(
            label,
            style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface)
        ),
        trailing: Icon(
            file != null ? Icons.check_circle : Icons.upload_file,
            color: file != null ? Colors.green : theme.colorScheme.onSurface.withOpacity(0.4)
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSelfieSection(BuildContext context, File? selfie, VoidCallback onTap) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          "Photo de profil (Selfie)",
          style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
        ),
        const SizedBox(height: 15),
        GestureDetector(
          onTap: onTap,
          child: CircleAvatar(
              radius: 50,
              backgroundColor: theme.inputDecorationTheme.fillColor,
              backgroundImage: selfie != null ? FileImage(selfie) : null,
              child: selfie == null
                  ? Icon(Icons.camera_alt, size: 30, color: theme.colorScheme.onSurface.withOpacity(0.5))
                  : null
          ),
        ),
      ],
    );
  }
}
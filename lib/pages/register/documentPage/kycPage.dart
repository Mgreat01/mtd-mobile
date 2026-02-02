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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Documents KYC"), backgroundColor: Colors.white, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const Text("Veuillez charger les documents requis pour valider votre compte professionnel."),
            const SizedBox(height: 30),
            _buildDocTile("Carte d'identité (CNI)", kycState.identityDoc, () => kycControl.pickDocument('identity')),
            _buildDocTile("Permis de conduire", kycState.registrationCard, () => kycControl.pickDocument('registration')),
            _buildDocTile("Document commercial / License", kycState.businessLicense, () => kycControl.pickDocument('business')),
            const SizedBox(height: 20),
            _buildSelfieSection(kycState.selfie, () => kycControl.pickDocument('selfie')),

            if (kycState.error != null)
              Padding(padding: const EdgeInsets.all(8.0), child: Text(kycState.error!, style: const TextStyle(color: Colors.red))),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: (kycState.isLoading || registerState.isLoading) ? null : () => _handleFinalSubmit(ref, context),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF008E53), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                child: (kycState.isLoading || registerState.isLoading)
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Finaliser l'inscription", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
      // Redirection directe vers le Login (ton /app/home actuel)
      context.go('/app/home');

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Inscription réussie ! Votre dossier est en cours d'examen par nos administrateurs."),
              duration: Duration(seconds: 5),
              backgroundColor: Colors.blueAccent
          )
      );
    }
  }

  Widget _buildDocTile(String label, File? file, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: ListTile(
        title: Text(label, style: const TextStyle(fontSize: 14)),
        trailing: Icon(file != null ? Icons.check_circle : Icons.upload_file, color: file != null ? Colors.green : Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSelfieSection(File? selfie, VoidCallback onTap) {
    return Column(
      children: [
        const Text("Photo de profil (Selfie)"),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: onTap,
          child: CircleAvatar(radius: 45, backgroundColor: Colors.grey.shade100, backgroundImage: selfie != null ? FileImage(selfie) : null, child: selfie == null ? const Icon(Icons.camera_alt) : null),
        ),
      ],
    );
  }
}
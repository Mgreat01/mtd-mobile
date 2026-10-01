import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moto_taxi_digital_mobile/framework/cache/registrationProgressStore.dart';

class AccountValidatedPage extends StatelessWidget {
  const AccountValidatedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.schedule, size: 80, color: Colors.orange),
              const SizedBox(height: 20),
              const Text(
                'Email v\u00e9rifi\u00e9',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Votre dossier est en attente de validation administrative. '
                'Vous pourrez vous connecter apr\u00e8s son approbation.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 220,
                child: ElevatedButton(
                  onPressed: () async {
                    await RegistrationProgressStore().clear();
                    if (context.mounted) context.go('/public/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Revenir \u00e0 la connexion',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

// Supposons que ceci est la page d'inscription
import '../register/registerPage.dart';


class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});


  Widget _buildDividerWithText() {
    return const Row(
      children: [
        Expanded(child: Divider(color: Colors.grey)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text('Ou', style: TextStyle(color: Colors.grey)),
        ),
        Expanded(child: Divider(color: Colors.grey)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Container(

              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center, // Centrer les widgets
                children: [
                  // Titre "Se connecter"
                  const Padding(
                    padding: EdgeInsets.only(top: 40, bottom: 40),
                    child: Text(
                      'Se connecter',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Champ Email
                  Align(
                    alignment: Alignment.centerLeft,
                    child: const Text('Email'),
                  ),
                  const SizedBox(height: 5),
                  TextField(
                    decoration: InputDecoration(
                      // Pas de hintText pour coller au design minimaliste de la capture
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Champ Mot de passe
                  Align(
                    alignment: Alignment.centerLeft,
                    child: const Text('Mot de passe'),
                  ),
                  const SizedBox(height: 5),
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      // Pas de hintText
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Bouton "Se connecter" (Vert)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E8142), // Une nuance de vert foncé pour le bouton
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        elevation: 0, // Supprimer l'ombre par défaut
                      ),
                      child: const Text(
                        'Se connecter',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Séparateur "Ou"
                  _buildDividerWithText(),
                  const SizedBox(height: 30),

                  // Bouton "Se connecter avec Google"
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Colors.grey, width: 0.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          Image.network(
                            'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/2048px-Google_%22G%22_logo.svg.png',
                            height: 20,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Se connecter avec Google',
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Lien "Créer un compte"
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CreateAccountScreen()),
                      );
                    },
                    child: const Text(
                      'Créer un compte',
                      style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                          fontSize: 16
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Lien "Politique de confidentialité"
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Politique de confidentialité',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 30), // Espace en bas
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
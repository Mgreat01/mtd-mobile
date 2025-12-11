import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moto_taxi_digital_mobile/pages/register/accountValidated/avPage.dart';

class OTPScreen extends StatelessWidget {
  const OTPScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Pas d'AppBar pour correspondre à la capture, on utilise le SafeArea
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Bouton de retour
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),

                const SizedBox(height: 30),

                // Titre principal
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Vérification du code',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 20),

                // Texte descriptif
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Un code à 6 chiffres a été envoyé au',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ),

                const SizedBox(height: 5),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '+243 XXX XXX XXX',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),

                const SizedBox(height: 50),

                // Champs de saisie OTP
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) => SizedBox(
                    width: 45,
                    child: TextField(
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      style: const TextStyle(fontSize: 24),
                      decoration: InputDecoration(
                        counterText: '',
                        // Style du champ inspiré de la capture
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(color: Color(0xFF1E8142), width: 2.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onChanged: (value) {
                        // Déplacer le focus automatiquement au champ suivant
                        if (value.length == 1 && index < 5) {
                          FocusScope.of(context).nextFocus();
                        }
                        // Déplacer le focus automatiquement au champ précédent lors de l'effacement
                        if (value.isEmpty && index > 0) {
                          FocusScope.of(context).previousFocus();
                        }
                      },
                    ),
                  )),
                ),

                const SizedBox(height: 50),

                // Bouton "Vérifier" (Vert)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AccountValidatedScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E8142), // Une nuance de vert foncé
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      elevation: 0,
                    ),
                    child: const Text(
                        'Vérifier',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Liens de renvoi
                const Text(
                  'Tu n\'as pas reçu le code ?',
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                ),

                const SizedBox(height: 10),

                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero, // Supprimer le padding par défaut
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Renvoyer le code',
                    style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        fontWeight: FontWeight.w600
                    ),
                  ),
                ),

                const SizedBox(height: 100), // Espace pour pousser l'élément de sécurité vers le bas

                // Texte de sécurité
                const Text(
                  'Vérification sécurisé par OTP',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
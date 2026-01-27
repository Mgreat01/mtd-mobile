import 'package:flutter/material.dart';
import 'package:moto_taxi_digital_mobile/pages/register/otp/otpPage.dart';

class PhoneNumberScreen extends StatelessWidget {
  const PhoneNumberScreen({super.key});

  // Widget utilitaire pour les cartes de type de compte
  Widget _buildAccountTypeCard({
    required String title,
    required IconData icon,
    required Color color,
    required bool isSelected,
  }) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 40,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: isSelected ? color : Colors.black,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    const Color passagerColor = Color(0xFF1E8142);
    const Color motardColor = Color(0xFFFF8C00);
    const Color proprietaireColor = Color(0xFF1976D2);

    return Scaffold(

      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Container(

              constraints: const BoxConstraints(maxWidth: 450),
              padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 80.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Titre principal
                  const Text(
                    'Entre ton numéro de téléphone\npour continuer',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 40),


                  SizedBox(
                    width: double.infinity,
                    child: TextField(
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.phone, color: Colors.grey),
                        hintText: '+243 XXX XXX XXX',
                        hintStyle: const TextStyle(fontWeight: FontWeight.w500),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade400)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  const SizedBox(height: 50),

                  // Titre du choix de compte
                  const Text(
                    'Choisissez votre type de compte',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 30),

                  // Cartes de type de compte
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [

                      _buildAccountTypeCard(
                        title: 'PASSAGER',
                        icon: Icons.directions_walk,
                        color: passagerColor,
                        isSelected: true,
                      ),
                      // Motard
                      _buildAccountTypeCard(
                        title: 'MOTARD',
                        icon: Icons.two_wheeler,
                        color: motardColor,
                        isSelected: false,
                      ),
                      // Propriétaire
                      _buildAccountTypeCard(
                        title: 'PROPRIÉTAIRE',
                        icon: Icons.work,
                        color: proprietaireColor,
                        isSelected: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),

                  // Bouton "Continuer" (Vert)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {

                        Navigator.push(context, MaterialPageRoute(builder: (context) => const OTPScreen()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E8142),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Continuer',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Message OTP
                  const Text(
                    'Un code OTP sera envoyé pour vérification',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),

                  const SizedBox(height: 30),

                  // Lien de Politique de confidentialité
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Politique de confidentialité',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
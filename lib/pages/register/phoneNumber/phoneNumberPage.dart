import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PhoneNumberPage extends ConsumerStatefulWidget {
  const PhoneNumberPage({super.key});

  @override
  ConsumerState<PhoneNumberPage> createState() => _PhoneNumberPageState();
}

class _PhoneNumberPageState extends ConsumerState<PhoneNumberPage> {
  final _phoneController = TextEditingController();
  String _selectedRole = 'passenger';

  final Color passagerColor = const Color(0xFF1E8142);
  final Color motardColor = const Color(0xFFFF8C00);
  final Color proprietaireColor = const Color(0xFF1976D2);

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Bienvenue !',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF4A4A4A)),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Choisissez votre type de compte et entrez votre numéro pour commencer.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
                const SizedBox(height: 40),

               Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildAccountTypeCard('PASSAGER', Icons.directions_walk, passagerColor, 'passenger'),
                    _buildAccountTypeCard('MOTARD', Icons.two_wheeler, motardColor, 'biker'),
                    _buildAccountTypeCard('PROPRIÉTAIRE', Icons.work, proprietaireColor, 'owner'),
                  ],
                ),

                const SizedBox(height: 50),

                // Champ téléphone
                TextField(
                  controller: _phoneController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2 , color: Colors.black),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.phone_android, color: Colors.grey),
                    hintText: '+243 XXX XXX XXX',
                    hintStyle: const TextStyle(letterSpacing: 0, fontWeight: FontWeight.normal, fontSize: 14),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: passagerColor, width: 2),
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _handleNextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E8142),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Continuer',
                      style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountTypeCard(String title, IconData icon, Color color, String roleValue) {
    bool isSelected = _selectedRole == roleValue;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = roleValue),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 85, height: 85,
            decoration: BoxDecoration(
              color: isSelected ? color : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isSelected ? color : Colors.grey.shade300, width: 2),
              boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 10)] : [],
            ),
            child: Icon(icon, size: 35, color: isSelected ? Colors.white : Colors.grey.shade600),
          ),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: isSelected ? color : Colors.grey.shade700)),
        ],
      ),
    );
  }

  void _handleNextStep() {
    if (_phoneController.text.trim().length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Entrez un numéro valide")));
      return;
    }

    context.pushNamed(
      'register_page',
      extra: {
        'role': _selectedRole,
        'phone': _phoneController.text.trim(),
      },
    );
  }
}
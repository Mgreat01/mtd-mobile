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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.appBarTheme.foregroundColor),
          onPressed: () => context.pop(),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  'Bienvenue !',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Choisissez votre type de compte et entrez votre numéro pour commencer.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
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
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.phone_android, color: colorScheme.outline),
                    hintText: '+243 XXX XXX XXX',
                    hintStyle: const TextStyle(letterSpacing: 0, fontWeight: FontWeight.normal, fontSize: 14),
                    fillColor: theme.inputDecorationTheme.fillColor,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: _getCurrentRoleColor(), width: 2),
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _handleNextStep,
                    style: theme.elevatedButtonTheme.style?.copyWith(
                      backgroundColor: WidgetStateProperty.all(_getCurrentRoleColor()),
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

  Color _getCurrentRoleColor() {
    switch (_selectedRole) {
      case 'biker': return motardColor;
      case 'owner': return proprietaireColor;
      default: return passagerColor;
    }
  }

  Widget _buildAccountTypeCard(String title, IconData icon, Color color, String roleValue) {
    bool isSelected = _selectedRole == roleValue;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => setState(() => _selectedRole = roleValue),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 85, height: 85,
            decoration: BoxDecoration(
              color: isSelected ? color : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: isSelected ? color : theme.colorScheme.outline.withOpacity(0.5),
                  width: 2
              ),
              boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 10)] : [],
            ),
            child: Icon(
                icon,
                size: 35,
                color: isSelected ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.6)
            ),
          ),
          const SizedBox(height: 12),
          Text(
              title,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  color: isSelected ? color : theme.colorScheme.onSurface.withOpacity(0.8)
              )
          ),
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
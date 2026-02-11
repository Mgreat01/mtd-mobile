import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:moto_taxi_digital_mobile/business/models/user/user.dart';
import 'package:moto_taxi_digital_mobile/pages/register/registerCtrl.dart';

class RegisterPage extends ConsumerStatefulWidget {
  final String role;
  final String phone;

  const RegisterPage({super.key, required this.role, required this.phone});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  File? _selectedImage;

  final _nameController = TextEditingController();
  final _postNomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _genderController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _emailController = TextEditingController();
  final _communeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    for (var controller in [
      _nameController, _postNomController, _prenomController,
      _genderController, _birthDateController, _emailController,
      _communeController, _passwordController, _confirmPasswordController
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) setState(() => _selectedImage = File(pickedFile.path));
  }

  Future<void> _selectDate() async {
    FocusScope.of(context).unfocus();
    final theme = Theme.of(context);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.colorScheme.primary, // Utilise la couleur du thème
              onPrimary: Colors.white,
              onSurface: theme.colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _birthDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _handleFinalRegister() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final role = widget.role;

      final tempUser = User(
        name: _nameController.text.trim(),
        postnom: _postNomController.text.trim(),
        prenom: _prenomController.text.trim(),
        gender: _genderController.text,
        birthDate: _birthDateController.text,
        commune: _communeController.text.trim(),
        email: email,
        password: _passwordController.text,
        phone: widget.phone,
        role: role,
        photo: _selectedImage?.path,
      );

      if (role == 'passenger') {
        final success = await ref.read(registerControlProvider.notifier).register(tempUser);
        if (success && mounted) {
          context.go('/public/otp', extra: {'email': email, 'role': role});
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Veuillez vérifier votre email"), backgroundColor: Colors.blue),
          );
        }
      } else {
        ref.read(registerControlProvider.notifier).storeTempUser(tempUser);
        context.push('/public/kyc');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registerControlProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Inscription", style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInput(_nameController, "Nom", theme),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: _buildInput(_postNomController, "Post-nom", theme)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildInput(_prenomController, "Prénom", theme)),
                ],
              ),
              const SizedBox(height: 15),
              _buildInput(_birthDateController, "Date de naissance (AAAA-MM-DD)", theme, readOnly: true, onTap: _selectDate),
              const SizedBox(height: 15),
              _buildDropdownInput(theme),
              const SizedBox(height: 15),
              _buildInput(_emailController, "Email (Optionnel)", theme, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 15),
              _buildInput(_communeController, "Commune", theme),
              const SizedBox(height: 25),
              Text("Photo de profil", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: colorScheme.onSurface)),
              const SizedBox(height: 10),
              _buildPhotoPicker(theme),
              const SizedBox(height: 25),
              _buildInput(_passwordController, "Mot de passe", theme, isPassword: true),
              const SizedBox(height: 15),
              _buildInput(_confirmPasswordController, "Confirmer le mot de passe", theme, isPassword: true, isConfirm: true),
              const SizedBox(height: 35),

              if (state.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Text(state.error!, style: TextStyle(color: colorScheme.error, fontSize: 13)),
                ),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: state.isLoading ? null : _handleFinalRegister,
                  style: theme.elevatedButtonTheme.style, // Utilise le style centralisé
                  child: state.isLoading
                      ? CircularProgressIndicator(color: colorScheme.onPrimary)
                      : const Text("Continuer", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String hint, ThemeData theme, {
    bool isPassword = false,
    bool isConfirm = false,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4), fontSize: 14),
        suffixIcon: readOnly ? Icon(Icons.calendar_today, size: 20, color: theme.colorScheme.primary) : null,
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Ce champ est requis';
        if (isConfirm && v != _passwordController.text) return 'Les mots de passe ne correspondent pas';
        return null;
      },
    );
  }

  Widget _buildDropdownInput(ThemeData theme) {
    return DropdownButtonFormField<String>(
      dropdownColor: theme.colorScheme.surface,
      style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14),
      decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
      items: const [
        DropdownMenuItem(value: "M", child: Text("Masculin")),
        DropdownMenuItem(value: "F", child: Text("Féminin")),
      ],
      onChanged: (v) => _genderController.text = v!,
      hint: Text("Genre", style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4))),
      validator: (v) => v == null ? 'Sélectionnez un genre' : null,
    );
  }

  Widget _buildPhotoPicker(ThemeData theme) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
            color: theme.inputDecorationTheme.fillColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3))
        ),
        child: _selectedImage != null
            ? ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(_selectedImage!, fit: BoxFit.cover)
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined, color: theme.colorScheme.onSurface.withOpacity(0.4), size: 40),
            const SizedBox(height: 8),
            Text("Ajouter une photo", style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5), fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
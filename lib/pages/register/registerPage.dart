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

  // Contrôleurs
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
    _nameController.dispose();
    _postNomController.dispose();
    _prenomController.dispose();
    _genderController.dispose();
    _birthDateController.dispose();
    _emailController.dispose();
    _communeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) setState(() => _selectedImage = File(pickedFile.path));
  }

  Future<void> _selectDate() async {
    FocusScope.of(context).unfocus();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF008E53),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final String formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      setState(() {
        _birthDateController.text = formattedDate;
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
          context.go('/public/otp', extra: {
            'email': email,
            'role': role,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Veuillez vérifier votre email pour le code OTP"),
                backgroundColor: Colors.blue
            ),
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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Inscription", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
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
              _buildInput(_nameController, "Nom"),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: _buildInput(_postNomController, "Post-nom")),
                  const SizedBox(width: 15),
                  Expanded(child: _buildInput(_prenomController, "Prénom")),
                ],
              ),
              const SizedBox(height: 15),

              _buildInput(
                  _birthDateController,
                  "Date de naissance (AAAA-MM-DD)",
                  readOnly: true,
                  onTap: _selectDate
              ),

              const SizedBox(height: 15),
              _buildDropdownInput(),
              const SizedBox(height: 15),
              _buildInput(_emailController, "Email (Optionnel)", keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 15),
              _buildInput(_communeController, "Commune"),
              const SizedBox(height: 25),
              const Text("Photo de profil", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 10),
              _buildPhotoPicker(),
              const SizedBox(height: 25),
              _buildInput(_passwordController, "Mot de passe", isPassword: true),
              const SizedBox(height: 15),
              _buildInput(_confirmPasswordController, "Confirmer le mot de passe", isPassword: true, isConfirm: true),
              const SizedBox(height: 35),

              if (state.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Text(state.error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                ),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: state.isLoading ? null : _handleFinalRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF008E53),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: state.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Continuer", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String hint, {
    bool isPassword = false,
    bool isConfirm = false,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return InkWell(
      onTap: readOnly ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: IgnorePointer(
        ignoring: readOnly,
        child: TextFormField(
          controller: controller,
          obscureText: isPassword,
          readOnly: readOnly,
          keyboardType: keyboardType,
          focusNode: readOnly ? AlwaysDisabledFocusNode() : null,
          style: const TextStyle(
            color: Colors.black, fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            suffixIcon: readOnly ? const Icon(Icons.calendar_today, size: 20, color: Color(0xFF008E53)) : null,
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200)
            ),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF008E53))
            ),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.redAccent)
            ),
            focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.redAccent)
            ),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Ce champ est requis';
            if (isConfirm && v != _passwordController.text) return 'Les mots de passe ne correspondent pas';
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildDropdownInput() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200)
        ),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF008E53))
        ),
      ),
      items: const [
        DropdownMenuItem(value: "M", child: Text("Masculin")),
        DropdownMenuItem(value: "F", child: Text("Féminin")),
      ],
      onChanged: (v) => _genderController.text = v!,
      hint: const Text("Genre"),
      validator: (v) => v == null ? 'Sélectionnez un genre' : null,
    );
  }

  Widget _buildPhotoPicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200)
        ),
        child: _selectedImage != null
            ? ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(_selectedImage!, fit: BoxFit.cover)
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined, color: Colors.grey.shade400, size: 40),
            const SizedBox(height: 8),
            Text("Ajouter une photo", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
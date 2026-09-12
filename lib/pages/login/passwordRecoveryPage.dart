import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moto_taxi_digital_mobile/business/services/user/userNetworkService.dart';
import 'package:moto_taxi_digital_mobile/main.dart';
import 'package:moto_taxi_digital_mobile/utils/themes/appTheme.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final UserNetworkService _service = getIt.get<UserNetworkService>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);
    try {
      await _service.requestPasswordReset(_emailController.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lien de réinitialisation envoyé.')),
      );
      context.pushNamed('reset_password', extra: _emailController.text.trim());
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_cleanError(error))));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _PasswordRecoveryLayout(
      title: 'Mot de passe oublié',
      subtitle: 'Saisissez votre e-mail. Nous vous enverrons un lien sécurisé.',
      icon: Icons.lock_reset_rounded,
      formKey: _formKey,
      children: [
        _label('Adresse e-mail', Icons.alternate_email_rounded),
        const SizedBox(height: 6),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          decoration: _inputDecoration(
            'exemple@mail.com',
            Icons.mail_outline_rounded,
          ),
          validator: _emailValidator,
        ),
        const SizedBox(height: 22),
        _primaryButton(
          label: 'Envoyer le lien',
          isLoading: _isLoading,
          onPressed: _submit,
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: _isLoading
                ? null
                : () => context.pushNamed(
                    'reset_password',
                    extra: _emailController.text.trim(),
                  ),
            child: const Text('J’ai déjà reçu un lien ou un jeton'),
          ),
        ),
      ],
    );
  }
}

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key, this.initialEmail});

  final String? initialEmail;

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();
  final UserNetworkService _service = getIt.get<UserNetworkService>();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.initialEmail ?? '';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);
    try {
      await _service.resetPassword(
        email: _emailController.text.trim(),
        token: _tokenController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mot de passe modifié. Connectez-vous.')),
      );
      context.goNamed('login_page');
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_cleanError(error))));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _PasswordRecoveryLayout(
      title: 'Nouveau mot de passe',
      subtitle:
          'Copiez le jeton reçu par e-mail puis choisissez un nouveau mot de passe.',
      icon: Icons.password_rounded,
      formKey: _formKey,
      children: [
        _label('Adresse e-mail', Icons.alternate_email_rounded),
        const SizedBox(height: 6),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: _inputDecoration(
            'exemple@mail.com',
            Icons.mail_outline_rounded,
          ),
          validator: _emailValidator,
        ),
        const SizedBox(height: 14),
        _label('Jeton de réinitialisation', Icons.vpn_key_outlined),
        const SizedBox(height: 6),
        TextFormField(
          controller: _tokenController,
          textInputAction: TextInputAction.next,
          decoration: _inputDecoration(
            'Jeton reçu par e-mail',
            Icons.key_rounded,
          ),
          validator: (value) => value == null || value.trim().isEmpty
              ? 'Le jeton est requis'
              : null,
        ),
        const SizedBox(height: 14),
        _label('Nouveau mot de passe', Icons.lock_outline_rounded),
        const SizedBox(height: 6),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: _passwordDecoration('Au moins 8 caractères'),
          validator: (value) => value == null || value.length < 8
              ? 'Utilisez au moins 8 caractères'
              : null,
        ),
        const SizedBox(height: 14),
        _label('Confirmer le mot de passe', Icons.lock_reset_outlined),
        const SizedBox(height: 6),
        TextFormField(
          controller: _confirmationController,
          obscureText: _obscurePassword,
          decoration: _passwordDecoration('Répétez le mot de passe'),
          validator: (value) => value != _passwordController.text
              ? 'Les mots de passe ne correspondent pas'
              : null,
        ),
        const SizedBox(height: 22),
        _primaryButton(
          label: 'Modifier le mot de passe',
          isLoading: _isLoading,
          onPressed: _submit,
        ),
      ],
    );
  }

  InputDecoration _passwordDecoration(String hint) =>
      _inputDecoration(hint, Icons.key_rounded).copyWith(
        suffixIcon: IconButton(
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
        ),
      );
}

class _PasswordRecoveryLayout extends StatelessWidget {
  const _PasswordRecoveryLayout({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.formKey,
    required this.children,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final GlobalKey<FormState> formKey;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sécurité du compte'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [AppTheme.primaryDark, AppTheme.cardDark]
                : const [Color(0xFFF8FAFC), Color(0xFFECFDF5)],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: Form(
                  key: formKey,
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.cardDark : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: AppTheme.primaryDarkAccent,
                            child: Icon(icon, color: Colors.white, size: 30),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: isDark
                                ? AppTheme.textDark
                                : const Color(0xFF64748B),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 22),
                        ...children,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _label(String text, IconData icon) => Row(
  children: [
    Icon(icon, size: 16, color: AppTheme.primaryDarkAccent),
    const SizedBox(width: 6),
    Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
  ],
);

InputDecoration _inputDecoration(String hint, IconData icon) => InputDecoration(
  hintText: hint,
  prefixIcon: Icon(icon),
  filled: true,
  fillColor: const Color(0xFFF8FAFC),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide.none,
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
  ),
);

Widget _primaryButton({
  required String label,
  required bool isLoading,
  required VoidCallback onPressed,
}) => SizedBox(
  width: double.infinity,
  height: 50,
  child: ElevatedButton(
    onPressed: isLoading ? null : onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: AppTheme.primaryDarkAccent,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    child: isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          )
        : Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
  ),
);

String? _emailValidator(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty || !email.contains('@')) return 'Adresse e-mail invalide';
  return null;
}

String _cleanError(Object error) =>
    error.toString().replaceFirst('Exception: ', '');

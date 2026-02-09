import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moto_taxi_digital_mobile/pages/login/loginCtrl.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      ref.read(loginControllerProvider.notifier).login(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  Widget _buildDividerWithText(ThemeData theme) {
    return Row(
      children: [
        Expanded(child: Divider(color: theme.colorScheme.outline.withOpacity(0.3))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text('Ou', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5))),
        ),
        Expanded(child: Divider(color: theme.colorScheme.outline.withOpacity(0.3))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginControllerProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;


    ref.listen(loginControllerProvider, (previous, next) {
      if (next.isSuccess) {
        context.go('/app/introUser');
      }

      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: colorScheme.error,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(10),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(30),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Text(
                        'Se connecter',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),

                    // Champ Email
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                            'Email',
                            style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurface)
                        )
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: colorScheme.onSurface),
                      decoration: const InputDecoration(
                        hintText: "exemple@mail.com",
                      ),
                      validator: (v) => v!.isEmpty || !v.contains('@') ? 'Entrez un email valide' : null,
                    ),
                    const SizedBox(height: 20),

                    // Champ Mot de passe
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                            'Mot de passe',
                            style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurface)
                        )
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      style: TextStyle(color: colorScheme.onSurface),
                      decoration: const InputDecoration(
                        hintText: "••••••••",
                      ),
                      validator: (v) => v!.isEmpty ? 'Entrez votre mot de passe' : null,
                    ),
                    const SizedBox(height: 30),

                    // Bouton Login
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: loginState.isLoading ? null : _handleLogin,
                        style: theme.elevatedButtonTheme.style?.copyWith(
                          backgroundColor: WidgetStateProperty.resolveWith((states) {
                            if (states.contains(WidgetState.disabled)) return colorScheme.outline.withOpacity(0.3);
                            return const Color(0xFF1E8142);
                          }),
                        ),
                        child: loginState.isLoading
                            ? CircularProgressIndicator(color: colorScheme.onPrimary, strokeWidth: 2)
                            : const Text('Se connecter', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildDividerWithText(theme),
                    const SizedBox(height: 30),

                    // Bouton Google
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: colorScheme.outline),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network('https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/2048px-Google_%22G%22_logo.svg.png', height: 20),
                            const SizedBox(width: 10),
                            Text('Google', style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    TextButton(
                      onPressed: () => context.pushNamed('pnumber_page'),
                      child: Text(
                          'Créer un compte',
                          style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
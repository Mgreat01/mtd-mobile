import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class IntroPage extends ConsumerWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo_motoTaxi_Digital.png',
              width: 300,
              height: 300,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 80),
            CircularProgressIndicator(color: Colors.blue),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:moto_taxi_digital_mobile/pages/user/profil/profilCtl.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final box = GetStorage();
      final token = box.read('token');
      if (token != null && mounted) {
        ref.read(profileProvider.notifier).loadProfile(token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Mon profil'),
        backgroundColor: Colors.grey,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: profileState.loading
          ? const Center(child: CircularProgressIndicator())
          : profileState.error != null
              ? Center(child: Text('Erreur: ${profileState.error}'))
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundImage: profileState.user?.photo != null && profileState.user!.photo!.isNotEmpty
                            ? NetworkImage(profileState.user!.photo!)
                            : const NetworkImage('https://i.pravatar.cc/150?img=65'),
                        radius: 50,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        profileState.user?.name ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        profileState.user?.email ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              InfoRow(Icons.phone, 'Téléphone', profileState.user?.phone ?? 'N/A'),
                              const SizedBox(height: 10),
                              InfoRow(Icons.location_on, 'Adresse', profileState.user?.commune ?? 'N/A'),
                              const SizedBox(height: 10),
                              InfoRow(Icons.credit_card, 'Paiement', 'Carte enregistrée'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () {
                          // Ajoutez la logique de déconnexion    £   4       .L7  
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Déconnexion',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget InfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
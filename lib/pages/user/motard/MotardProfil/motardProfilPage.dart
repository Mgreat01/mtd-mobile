import 'package:flutter/material.dart';

class MotardProfilPage extends StatelessWidget {
  const MotardProfilPage({super.key});

 Widget _buildSimpleTextField({required String label}) {

    final Widget fieldContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.black54)),
        const SizedBox(height: 5),
        SizedBox(
          height: 40,
          child: TextField(
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              isDense: true,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(5),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black54, width: 1.0),
              ),
            ),
          ),
        ),
      ],
    );

    if (label == 'Nom') {
      return fieldContent;
    }

    return fieldContent;
  }

  Widget _buildPhoneField() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(5),
      ),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 10),
      child: const Text(
        '+243 XXX XXX XXX',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black54,
        ),
      ),
    );
  }


  Widget _buildProfilePhotoField() {
    return Container(
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(5),
      ),
      child: TextButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.camera_alt_outlined, size: 20, color: Colors.grey),
        label: const Text(
          'Ajouter une photo de profil',
          style: TextStyle(color: Colors.black54, fontSize: 14),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Complétez vos informations personnelles',
          style: TextStyle(fontWeight: FontWeight.normal),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Section Informations d'identité ---
            const Text(
              'Informations d\'identité',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black54),
            ),
            const SizedBox(height: 15),

            // Nom (pleine largeur)
            _buildSimpleTextField(label: 'Nom'),
            const SizedBox(height: 15),

            // Post-nom et Prénom (deux colonnes)
            Row(
              children: [
                Expanded(child: _buildSimpleTextField(label: 'Post-nom')),
                const SizedBox(width: 15),
                Expanded(child: _buildSimpleTextField(label: 'Prénom')),
              ],
            ),
            const SizedBox(height: 15),

            // Genre et Date de naissance (deux colonnes)
            Row(
              children: [
                Expanded(child: _buildSimpleTextField(label: 'Genre')),
                const SizedBox(width: 15),
                Expanded(child: _buildSimpleTextField(label: 'Date de naissance')),
              ],
            ),
            const SizedBox(height: 30),

            // --- Section Coordonnées ---
            const Text(
              'Coordonnées',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black54),
            ),
            const SizedBox(height: 15),
            _buildPhoneField(),
            const SizedBox(height: 15),

            // E-mail et Avenue (deux colonnes)
            Row(
              children: [
                Expanded(child: _buildSimpleTextField(label: 'E-mail')),
                const SizedBox(width: 15),
                Expanded(child: _buildSimpleTextField(label: 'Avenue')),
              ],
            ),
            const SizedBox(height: 15),

            // Quartier et Commune (deux colonnes)
            Row(
              children: [
                Expanded(child: _buildSimpleTextField(label: 'Quartier')),
                const SizedBox(width: 15),
                Expanded(child: _buildSimpleTextField(label: 'Commune')),
              ],
            ),
            const SizedBox(height: 30),

            // --- Section Photo de profil ---
            const Text(
              'Photo de profil',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black54),
            ),
            const SizedBox(height: 10),
            _buildProfilePhotoField(),
            const SizedBox(height: 40),

            // --- Bouton Continuer ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A05B),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  elevation: 0,
                ),
                child: const Text(
                  'Continuer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
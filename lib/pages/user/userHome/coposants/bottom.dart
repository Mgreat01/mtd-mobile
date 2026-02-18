import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moto_taxi_digital_mobile/pages/intro/appCtrl.dart';
import 'package:moto_taxi_digital_mobile/pages/user/biker/bikerPage.dart';
import 'package:moto_taxi_digital_mobile/pages/user/owner/ownerPage.dart';
import 'package:moto_taxi_digital_mobile/pages/user/userHome/coposants/composant_controller.dart';
import 'package:moto_taxi_digital_mobile/pages/user/userHome/userHomePage.dart';
import 'package:moto_taxi_digital_mobile/pages/user/userHome/coposants/drawer.dart'; // Import important

class BottomNavBar extends ConsumerWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(navigationIndexProvider);
    final userRole = ref.watch(appCtrlProvider).user?.role ?? 'passenger';
    final theme = Theme.of(context);

    // 1. Définition des pages selon le rôle
    final List<Widget> pages = userRole == 'biker'
        ? [const BikerPage(), const Center(child: Text("Revenus")), const Center(child: Text("Profil"))]
        : userRole == 'owner'
        ? [const OwnerHomePage(), const Center(child: Text("Liste Motos")), const Center(child: Text("Stats Globales"))]
        : [const UserHomePage(), const Center(child: Text("Mes Courses")), const Center(child: Text("Promo"))];

    return Scaffold(

      drawer: const AppDrawer(),

      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => _buildCircleAction(
            icon: Icons.menu,
            theme: theme,
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          _buildCircleAction(
            icon: Icons.notifications_none,
            theme: theme,
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: IndexedStack(
        index: index,
        children: pages,
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: BottomNavigationBar(
          currentIndex: index,
          onTap: (val) => ref.read(navigationIndexProvider.notifier).setIndex(val),
          selectedItemColor: const Color(0xFF1E8142),
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: userRole == 'biker'
              ? _bikerItems()
              : userRole == 'owner'
              ? _ownerItems()
              : _passengerItems(),        ),
      ),
    );
  }

  Widget _buildCircleAction({required IconData icon, required ThemeData theme, required VoidCallback onPressed}) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
      ),
      child: IconButton(
        icon: Icon(icon, color: theme.colorScheme.onSurface, size: 20),
        onPressed: onPressed,
      ),
    );
  }

  List<BottomNavigationBarItem> _ownerItems() {
    return const [
      BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
      BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Motos"),
      BottomNavigationBarItem(icon: Icon(Icons.analytics), label: "Stats"),
    ];
  }

  List<BottomNavigationBarItem> _bikerItems() {
    return const [
      BottomNavigationBarItem(icon: Icon(Icons.motorcycle), label: "Service"),
      BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Revenus"),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: "Compte"),
    ];
  }

  List<BottomNavigationBarItem> _passengerItems() {
    return const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: "Accueil"),
      BottomNavigationBarItem(icon: Icon(Icons.history), label: "Activités"),
      BottomNavigationBarItem(icon: Icon(Icons.local_offer), label: "Promos"),
    ];
  }
}
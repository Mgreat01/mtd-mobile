import 'package:flutter/material.dart';
import 'package:moto_taxi_digital_mobile/pages/user/userHome/userHomePage.dart';
import 'package:moto_taxi_digital_mobile/pages/user/userHome/coposants/drawer.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 0;


  final List<Widget> _pages = [
    const UserHomePage(),
    const Center(child: Text("Mes courses")),
    const Center(child: Text("Profil")),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: const AppDrawer(),
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
        title: Text(
          'MOTO TAXI',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          _buildCircleAction(
            icon: Icons.notifications,
            theme: theme,
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: colorScheme.primary,
          unselectedItemColor: colorScheme.onSurface.withOpacity(0.4),
          backgroundColor: colorScheme.surface,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          onTap: (index) {
            setState(() => _currentIndex = index);
          },
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Accueil'),
            BottomNavigationBarItem(
              icon: Icon(Icons.two_wheeler, size: _currentIndex == 1 ? 32 : 28),
              label: 'Mes courses',
            ),
            const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          ],
        ),
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
}
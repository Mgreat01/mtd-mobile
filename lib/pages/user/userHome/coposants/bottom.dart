import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moto_taxi_digital_mobile/pages/intro/appCtrl.dart';
import 'package:moto_taxi_digital_mobile/pages/login/loginCtrl.dart';
import 'package:moto_taxi_digital_mobile/pages/user/biker/bikerPage.dart';
import 'package:moto_taxi_digital_mobile/pages/user/biker/composant/courseBiker/BikerHistory.dart';
import 'package:moto_taxi_digital_mobile/pages/user/biker/composant/wallet/walletPage.dart';
import 'package:moto_taxi_digital_mobile/pages/user/owner/ownerPage.dart';
import 'package:moto_taxi_digital_mobile/pages/user/userHome/coposants/composant_controller.dart';
import 'package:moto_taxi_digital_mobile/pages/user/userHome/userHomePage.dart';
import 'package:moto_taxi_digital_mobile/pages/user/userHome/coposants/drawer.dart';
import 'package:moto_taxi_digital_mobile/utils/themes/appTheme.dart';

class BottomNavBar extends ConsumerWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(navigationIndexProvider);
    final userRole = ref.watch(appCtrlProvider).user?.role ?? 'passenger';
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    var data = ref.watch(loginControllerProvider).user;
    print("La valeur de user : $data");
    print("le role de l'utilisateur : ${data?.role}");
    print("L'utilisateur connecter ${data?.name} - ${data?.prenom} - ${data?.email} - ${data?.phone} - ${data?.role} - ${data?.photo}");

    final List<Widget> pages = _getPagesForRole(userRole);

    return Scaffold(
      drawer: const AppDrawer(),
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => _buildCircleAction(
            icon: Icons.menu,
            theme: theme,
            isDarkMode: isDarkMode,
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          _buildCircleAction(
            icon: Icons.notifications_none,
            theme: theme,
            isDarkMode: isDarkMode,
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
          color: isDarkMode ? AppTheme.cardDark : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(
              color: (isDarkMode ? Colors.black : Colors.grey).withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          color: Colors.transparent,
          elevation: 0,
          child: Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _buildNavItems(userRole, index, ref, isDarkMode),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _getPagesForRole(String userRole) {
    switch (userRole) {
      case 'passenger':
        return [
          const UserHomePage(),
          const HistoryPage(),
          const WalletPage(),
          const SettingsPage(),
        ];
      case 'biker':
        return [
          const BikerPage(),
          const RideRequestsPage(),
          const BikerHistoryPage(),
          const WalletPage(),
          const ReportingPage(),
          const SettingsPage(),
        ];
      case 'owner':
        return [
          const OwnerHomePage(),
          const OwnerBikesPage(),
          const WalletPage(),
          const SettingsPage(),
        ];
      default:
        return [const UserHomePage()];
    }
  }

  // Méthode pour construire les items de navigation selon le rôle
  List<Widget> _buildNavItems(String userRole, int currentIndex, WidgetRef ref, bool isDarkMode) {
    switch (userRole) {
      case 'passenger':
        return [
          _buildNavItem(
            index: 0,
            currentIndex: currentIndex,
            icon: Icons.home,
            label: 'Accueil',
            isDarkMode: isDarkMode,
            onTap: (val) => ref.read(navigationIndexProvider.notifier).setIndex(val),
          ),
          _buildNavItem(
            index: 1,
            currentIndex: currentIndex,
            icon: Icons.history,
            label: 'Historique',
            isDarkMode: isDarkMode,
            onTap: (val) => ref.read(navigationIndexProvider.notifier).setIndex(val),
          ),
          _buildNavItem(
            index: 2,
            currentIndex: currentIndex,
            icon: Icons.wallet,
            label: 'Wallet',
            isDarkMode: isDarkMode,
            onTap: (val) => ref.read(navigationIndexProvider.notifier).setIndex(val),
          ),
          _buildNavItem(
            index: 3,
            currentIndex: currentIndex,
            icon: Icons.settings,
            label: 'Paramètres',
            isDarkMode: isDarkMode,
            onTap: (val) => ref.read(navigationIndexProvider.notifier).setIndex(val),
          ),
        ];
      case 'biker':
        return [
          _buildNavItem(
            index: 0,
            currentIndex: currentIndex,
            icon: Icons.motorcycle,
            label: 'Service',
            isDarkMode: isDarkMode,
            onTap: (val) => ref.read(navigationIndexProvider.notifier).setIndex(val),
          ),
          _buildNavItem(
            index: 2,
            currentIndex: currentIndex,
            icon: Icons.history,
            label: 'Historique',
            isDarkMode: isDarkMode,
            onTap: (val) => ref.read(navigationIndexProvider.notifier).setIndex(val),
          ),
          _buildNavItem(
            index: 3,
            currentIndex: currentIndex,
            icon: Icons.wallet,
            label: 'Wallet',
            isDarkMode: isDarkMode,
            onTap: (val) => ref.read(navigationIndexProvider.notifier).setIndex(val),
          ),
          _buildNavItem(
            index: 4,
            currentIndex: currentIndex,
            icon: Icons.bar_chart,
            label: 'Reporting',
            isDarkMode: isDarkMode,
            onTap: (val) => ref.read(navigationIndexProvider.notifier).setIndex(val),
          )
        ];
      case 'owner':
        return [
          _buildNavItem(
            index: 0,
            currentIndex: currentIndex,
            icon: Icons.dashboard,
            label: 'Reporting',
            isDarkMode: isDarkMode,
            onTap: (val) => ref.read(navigationIndexProvider.notifier).setIndex(val),
          ),
          _buildNavItem(
            index: 1,
            currentIndex: currentIndex,
            icon: Icons.motorcycle,
            label: 'Motos',
            isDarkMode: isDarkMode,
            onTap: (val) => ref.read(navigationIndexProvider.notifier).setIndex(val),
          ),
          _buildNavItem(
            index: 2,
            currentIndex: currentIndex,
            icon: Icons.wallet,
            label: 'Wallet',
            isDarkMode: isDarkMode,
            onTap: (val) => ref.read(navigationIndexProvider.notifier).setIndex(val),
          ),
          _buildNavItem(
            index: 3,
            currentIndex: currentIndex,
            icon: Icons.settings,
            label: 'Paramètres',
            isDarkMode: isDarkMode,
            onTap: (val) => ref.read(navigationIndexProvider.notifier).setIndex(val),
          ),
        ];
      default:
        return [];
    }
  }

  // Méthode de construction d'un item de navigation adapté au mode sombre
  Widget _buildNavItem({
    required int index,
    required int currentIndex,
    required IconData icon,
    required String label,
    required bool isDarkMode,
    required Function(int) onTap,
  }) {
    final isSelected = currentIndex == index;

    // Couleurs adaptées au mode
    final selectedColor = AppTheme.primaryDarkAccent; // #1E8142 reste la même
    final unselectedColor = isDarkMode ? AppTheme.textDark : Colors.grey[600];
    final backgroundColor = isSelected
        ? selectedColor.withOpacity(0.1)
        : Colors.transparent;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: backgroundColor,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected ? selectedColor : unselectedColor,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? selectedColor : unselectedColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleAction({
    required IconData icon,
    required ThemeData theme,
    required bool isDarkMode,
    required VoidCallback onPressed
  }) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.cardDark : theme.colorScheme.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (isDarkMode ? Colors.black : Colors.grey).withOpacity(0.1),
            blurRadius: 8,
          )
        ],
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: isDarkMode ? AppTheme.textDark : theme.colorScheme.onSurface,
          size: 20
        ),
        onPressed: onPressed,
      ),
    );
  }
}


class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Text(
        'Historique courses',
        style: TextStyle(
          color: isDarkMode ? AppTheme.textDark : AppTheme.textLight,
        ),
      ),
    );
  }
}


class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Text(
        'Paramètres',
        style: TextStyle(
          color: isDarkMode ? AppTheme.textDark : AppTheme.textLight,
        ),
      ),
    );
  }
}

class RideRequestsPage extends StatelessWidget {
  const RideRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Text(
        'Demandes de courses',
        style: TextStyle(
          color: isDarkMode ? AppTheme.textDark : AppTheme.textLight,
        ),
      ),
    );
  }
}


class ReportingPage extends StatelessWidget {
  const ReportingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Text(
        'Reporting',
        style: TextStyle(
          color: isDarkMode ? AppTheme.textDark : AppTheme.textLight,
        ),
      ),
    );
  }
}

class OwnerDashboardPage extends StatelessWidget {
  const OwnerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Text(
        'Dashboard Owner - Reporting',
        style: TextStyle(
          color: isDarkMode ? AppTheme.textDark : AppTheme.textLight,
        ),
      ),
    );
  }
}

class OwnerBikesPage extends StatelessWidget {
  const OwnerBikesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Text(
        'Mes motos',
        style: TextStyle(
          color: isDarkMode ? AppTheme.textDark : AppTheme.textLight,
        ),
      ),
    );
  }
}
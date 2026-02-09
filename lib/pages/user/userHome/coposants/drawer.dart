import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moto_taxi_digital_mobile/pages/user/userHome/coposants/composant_controller.dart';
import 'package:moto_taxi_digital_mobile/providers/themeProvider.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      child: Column(
        children: [
          _buildDrawerHeader(theme),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.home_filled,
                  label: "Accueil",
                  onTap: () => ref.read(navigationIndexProvider.notifier).state = 0,
                  theme: theme,
                ),
                _buildDrawerItem(
                  icon: Icons.history,
                  label: "Historique",
                  onTap: () {},
                  theme: theme,
                ),
                _buildDrawerItem(
                  icon: Icons.settings,
                  label: "Paramètre",
                  onTap: () {},
                  theme: theme,
                ),

                _buildThemeToggle(theme, themeMode, themeNotifier),

                _buildDrawerItem(
                  icon: Icons.share,
                  label: "Partager",
                  onTap: () {},
                  theme: theme,
                ),
                _buildDrawerItem(
                  icon: Icons.help_outline,
                  label: "Aide",
                  onTap: () {},
                  theme: theme,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, left: 20, bottom: 30),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.light
            ? Colors.grey.shade700
            : theme.colorScheme.secondary,
        borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(50),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 35,
            backgroundImage: NetworkImage('https://via.placeholder.com/150'),
          ),
          const SizedBox(height: 15),
          Text(
            "Joelle kabasele",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.onSurface.withOpacity(0.6), size: 26),
      title: Text(
        label,
        style: TextStyle(
          color: theme.colorScheme.onSurface,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
    );
  }


  Widget _buildThemeToggle(ThemeData theme, AppThemeMode currentMode, ThemeNotifier notifier) {
    return ListTile(
      leading: Icon(
          currentMode == AppThemeMode.light ? Icons.light_mode : Icons.dark_mode,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
          size: 26
      ),
      title: Text(
        "Thème sombre",
        style: TextStyle(
          color: theme.colorScheme.onSurface,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Switch(
        value: currentMode == AppThemeMode.dark,
        onChanged: (bool value) {
          notifier.toggleTheme();
        },
        activeColor: const Color(0xFF1E8142),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
    );
  }
}
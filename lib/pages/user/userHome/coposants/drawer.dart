import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart';
import 'package:moto_taxi_digital_mobile/business/models/user/user.dart';
import 'package:moto_taxi_digital_mobile/pages/login/loginCtrl.dart';
import 'package:moto_taxi_digital_mobile/pages/user/userHome/coposants/composant_controller.dart';
import 'package:moto_taxi_digital_mobile/providers/themeProvider.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(loginControllerProvider);
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    var data = authState.user;
    print(data?.photo);
    final String name = authState.user?.name ?? "";
    final String prenom = authState.user?.prenom ?? "";

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.8,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(30)),
      ),
      child: Column(
        children: [
          _buildDrawerHeader(context, theme, authState.user),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: [
                const SizedBox(height: 5),
                _buildDrawerItem(
                  icon: Icons.home_filled,
                  label: "Accueil",
                  onTap: () => ref.read(navigationIndexProvider.notifier).setIndex(0),
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
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: Divider(thickness: 1),
                ),
                _buildThemeToggle(theme, themeMode, themeNotifier),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: Divider(thickness: 1),
                ),
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
                const SizedBox(height: 5),
                _buildDrawerItem(
                  icon: Icons.logout,
                  label: "Déconnexion",
                  onTap: () async {
                    Navigator.pop(context);
                    await ref.read(navigationIndexProvider.notifier).logout();
                  },
                  theme: theme,
                  isLogout: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context, ThemeData theme, User? user) {
    final isDark = theme.brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: double.infinity,
      height: screenHeight * 0.28,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [theme.colorScheme.secondary, theme.colorScheme.secondary.withOpacity(0.8)]
              : [Colors.grey.shade800, Colors.grey.shade600],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundImage: _getImageProvider(user),
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            "${user?.name ?? ''} ${user?.prenom ?? ''}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            user?.email ?? '',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider _getImageProvider(User? user) {
    if (user?.photo == null || user!.photo!.isEmpty) {
      return const AssetImage('assets/images/default_avatar.png');
    }

    final String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://votre-backend.test';
    var imageEndPoint = baseUrl.endsWith("/api")
        ? baseUrl.replaceFirst("/api", "/storage/")
        : baseUrl;
    final String imageUrl = '$imageEndPoint/${user.photo}';

    return NetworkImage(imageUrl);
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required ThemeData theme,
    bool isLogout = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isLogout
                ? Colors.red.withOpacity(0.1)
                : theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isLogout ? Colors.red : theme.colorScheme.primary,
            size: 22,
          ),
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isLogout ? Colors.red : theme.colorScheme.onSurface,
            fontSize: 16,
            fontWeight: isLogout ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildThemeToggle(ThemeData theme, AppThemeMode currentMode, ThemeNotifier notifier) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            currentMode == AppThemeMode.light ? Icons.light_mode : Icons.dark_mode,
            color: theme.colorScheme.primary,
            size: 22,
          ),
        ),
        title: Text(
          "Mode sombre",
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
          activeTrackColor: const Color(0xFF1E8142).withOpacity(0.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      ),
    );
  }
}
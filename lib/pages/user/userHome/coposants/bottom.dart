import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moto_taxi_digital_mobile/business/models/race/race.dart';
import 'package:moto_taxi_digital_mobile/business/services/race/raceService.dart';
import 'package:moto_taxi_digital_mobile/main.dart';
import 'package:moto_taxi_digital_mobile/pages/intro/appCtrl.dart';
import 'package:moto_taxi_digital_mobile/pages/user/biker/bikerPage.dart';
import 'package:moto_taxi_digital_mobile/pages/user/biker/bikerCtrl.dart';
import 'package:moto_taxi_digital_mobile/pages/user/biker/bikerState.dart';
import 'package:moto_taxi_digital_mobile/pages/user/biker/composant/courseBiker/BikerHistory.dart';
import 'package:moto_taxi_digital_mobile/pages/user/biker/composant/wallet/walletPage.dart';
import 'package:moto_taxi_digital_mobile/pages/user/owner/ownerPage.dart';
import 'package:moto_taxi_digital_mobile/pages/user/owner/ownerCtrl.dart';
import 'package:moto_taxi_digital_mobile/pages/user/userHome/coposants/composant_controller.dart';
import 'package:moto_taxi_digital_mobile/pages/user/userHome/userHomePage.dart';
import 'package:moto_taxi_digital_mobile/pages/user/userHome/coposants/drawer.dart';
import 'package:moto_taxi_digital_mobile/utils/themes/appTheme.dart';

class BottomNavBar extends ConsumerStatefulWidget {
  const BottomNavBar({super.key});

  @override
  ConsumerState<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends ConsumerState<BottomNavBar> {
  bool _isNavigationBarVisible = true;

  bool _handleScroll(UserScrollNotification notification) {
    if (notification.metrics.pixels <= 0) {
      _setNavigationBarVisibility(true);
    } else if (notification.direction == ScrollDirection.reverse) {
      _setNavigationBarVisibility(false);
    } else if (notification.direction == ScrollDirection.forward) {
      _setNavigationBarVisibility(true);
    }
    return false;
  }

  void _setNavigationBarVisibility(bool visible) {
    if (_isNavigationBarVisible == visible || !mounted) return;
    setState(() => _isNavigationBarVisible = visible);
  }

  @override
  Widget build(BuildContext context) {
    final index = ref.watch(navigationIndexProvider);
    final userRole = ref.watch(appCtrlProvider).user?.role ?? 'passenger';
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final bikerState = userRole == 'biker'
        ? ref.watch(bikerControllerProvider)
        : null;

    if (userRole == 'biker') {
      ref.listen<int>(
        bikerControllerProvider.select((state) => state.unreadCount),
        (previous, next) {
          if (previous == null || next <= previous || !mounted) return;
          final notifications = ref.read(bikerControllerProvider).notifications;
          final notification = notifications.isEmpty ? null : notifications.first;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(notification?.title ?? 'Nouvelle course disponible'),
                backgroundColor: Colors.green,
                action: SnackBarAction(
                  label: 'VOIR',
                  textColor: Colors.white,
                  onPressed: () => _openNotifications(
                    ref.read(bikerControllerProvider),
                  ),
                ),
              ),
            );
        },
      );
    }

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
          Stack(
            clipBehavior: Clip.none,
            children: [
              _buildCircleAction(
                icon: Icons.notifications_none,
                theme: theme,
                isDarkMode: isDarkMode,
                onPressed: () => _openNotifications(bikerState),
              ),
              if ((bikerState?.unreadCount ?? 0) > 0)
                Positioned(
                  right: 4,
                  top: 3,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      bikerState!.unreadCount > 99
                          ? '99+'
                          : '${bikerState.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: NotificationListener<UserScrollNotification>(
        onNotification: _handleScroll,
        child: IndexedStack(
          index: index,
          children: pages,
        ),
      ),
      bottomNavigationBar: AnimatedSlide(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        offset: _isNavigationBarVisible ? Offset.zero : const Offset(0, 1.15),
        child: Container(
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
            child: SizedBox(
              height: 70,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _buildNavItems(userRole, index, ref, isDarkMode),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openNotifications(BikerState? currentState) async {
    if (currentState == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucune notification disponible.')),
      );
      return;
    }

    await ref.read(bikerControllerProvider.notifier).fetchNotifications();
    await ref
        .read(bikerControllerProvider.notifier)
        .markAllNotificationsAsRead();
    if (!mounted) return;
    final state = ref.read(bikerControllerProvider);

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.65,
          child: state.notifications.isEmpty
              ? const Center(child: Text('Aucune notification.'))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: state.notifications.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (_, index) {
                    final notification = state.notifications[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Icon(
                          notification.isRead
                              ? Icons.notifications_none
                              : Icons.notifications_active,
                        ),
                      ),
                      title: Text(notification.title),
                      subtitle: Text(notification.message),
                      isThreeLine: true,
                    );
                  },
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


class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<Race>> _races;

  @override
  void initState() {
    super.initState();
    _races = getIt<RaceService>().showForCurrentUser();
  }

  Future<void> _refresh() async {
    final request = getIt<RaceService>().showForCurrentUser();
    setState(() => _races = request);
    try {
      await request;
    } catch (_) {
      // FutureBuilder affiche l'erreur et le bouton de nouvelle tentative.
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<List<Race>>(
          future: _races,
          builder: (context, snapshot) {
            final races = snapshot.data ?? const <Race>[];
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 80, 16, 110),
                children: [
                  Text(
                    'Historique des courses',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 20),
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      races.isEmpty)
                    const Center(child: CircularProgressIndicator())
                  else if (snapshot.hasError && races.isEmpty) ...[
                    Text('Impossible de charger les courses : ${snapshot.error}'),
                    TextButton(onPressed: _refresh, child: const Text('Réessayer')),
                  ] else if (races.isEmpty)
                    const Center(child: Text('Aucune course pour le moment.'))
                  else
                    for (final race in races)
                      Card(
                        child: ListTile(
                          leading: Icon(Icons.route, color: colors.primary),
                          title: Text('${race.startingPoint} → ${race.destination}'),
                          subtitle: Text('Course n° ${race.id} • ${race.date}'),
                          trailing: Text(race.status),
                        ),
                      ),
                ],
              ),
            );
          },
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

class OwnerBikesPage extends ConsumerWidget {
  const OwnerBikesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ownerProvider);
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(ownerProvider.notifier).loadOwnerData(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 80, 16, 110),
            children: [
              Text('Mes motos', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 20),
              if (state.isLoading && state.bikes.isEmpty)
                const Center(child: CircularProgressIndicator())
              else if (state.errorMessage != null && state.bikes.isEmpty) ...[
                Text(state.errorMessage!),
                TextButton(
                  onPressed: () => ref.read(ownerProvider.notifier).loadOwnerData(),
                  child: const Text('Réessayer'),
                ),
              ] else if (state.bikes.isEmpty)
                const Center(child: Text('Aucune moto enregistrée.'))
              else
                for (final bike in state.bikes)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.two_wheeler),
                      title: Text('${bike.brand} ${bike.model}'),
                      subtitle: Text('Matricule : ${bike.matricule}'),
                      trailing: Text(
                        bike.bikerId == null ? 'Disponible' : 'Assignée',
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

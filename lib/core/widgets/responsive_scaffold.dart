import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../constants/app_spacing.dart';
import '../constants/user_roles.dart';
import '../routing/navigation_helper.dart';
import '../routing/route_paths.dart';

class NavDestinationItem {
  final String route;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final int? badgeCount;

  const NavDestinationItem({
    required this.route,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    this.badgeCount,
  });
}

class ResponsiveScaffold extends StatelessWidget {
  final Widget body;
  final int currentIndex;
  final List<NavDestinationItem> destinations;
  final String? title;
  final List<Widget>? actions;
  final UserRole userRole;
  final String userName;
  final String? userAvatar;
  final VoidCallback? onLogout;
  final FloatingActionButton? floatingActionButton;

  const ResponsiveScaffold({
    super.key,
    required this.body,
    required this.currentIndex,
    required this.destinations,
    this.title,
    this.actions,
    this.userRole = UserRole.patient,
    this.userName = 'AuraCare User',
    this.userAvatar,
    this.onLogout,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppConstants.tabletBreakpoint;
    final isTablet = width >= AppConstants.mobileBreakpoint && width < AppConstants.tabletBreakpoint;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isDesktop) {
      return Scaffold(
        floatingActionButton: floatingActionButton,
        body: Row(
          children: [
            _buildDesktopSidebar(context, isDark),
            const VerticalDivider(width: 1, thickness: 1, color: AppColors.border),
            Expanded(
              child: Column(
                children: [
                  _buildDesktopHeader(context, isDark),
                  Expanded(child: body),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (isTablet) {
      return Scaffold(
        floatingActionButton: floatingActionButton,
        appBar: _buildMobileAppBar(context),
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: currentIndex.clamp(0, destinations.length - 1),
              onDestinationSelected: (idx) => _onNavigate(context, idx),
              labelType: NavigationRailLabelType.selected,
              destinations: destinations.map((d) {
                return NavigationRailDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.selectedIcon, color: AppColors.primaryDark),
                  label: Text(d.label),
                );
              }).toList(),
            ),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(child: body),
          ],
        ),
      );
    }

    // Mobile layout: Top teal styled AppBar + BottomNavigationBar
    return AppBackScope(
      fallbackRoute: RoutePaths.home,
      child: Scaffold(
        appBar: _buildMobileAppBar(context),
        body: body,
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex.clamp(0, destinations.length - 1),
          onTap: (idx) => _onNavigate(context, idx),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primaryDark,
          unselectedItemColor: AppColors.textSecondary,
          items: destinations.map((d) {
            return BottomNavigationBarItem(
              icon: d.badgeCount != null && d.badgeCount! > 0
                  ? Badge(
                      label: Text('${d.badgeCount}'),
                      child: Icon(d.icon),
                    )
                  : Icon(d.icon),
              activeIcon: Icon(d.selectedIcon, color: AppColors.primaryDark),
              label: d.label,
            );
          }).toList(),
        ),
      ),
    );
  }

  void _onNavigate(BuildContext context, int idx) {
    if (idx < destinations.length) {
      final dest = destinations[idx];
      if (dest.route == RoutePaths.home) {
        if (GoRouterState.of(context).matchedLocation != RoutePaths.home) {
          context.go(RoutePaths.home);
        }
      } else {
        context.push(dest.route);
      }
    }
  }

  PreferredSizeWidget _buildMobileAppBar(BuildContext context) {
    final canGoBack = context.canPop() || (GoRouterState.of(context).matchedLocation != RoutePaths.home);
    return AppBar(
      title: Text(title ?? 'AuraCare HMS'),
      elevation: 0,
      backgroundColor: AppColors.primary,
      leading: canGoBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.safePop(),
            )
          : null,
      actions: [
        if (actions != null) ...actions!,
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded),
          onPressed: () => context.push('/notifications'),
        ),
      ],
    );
  }

  Widget _buildDesktopSidebar(BuildContext context, bool isDark) {
    return Container(
      width: 260,
      color: isDark ? AppColors.darkSurface : Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: const BoxDecoration(
              gradient: AppColors.cardHeaderGradient,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.local_hospital, color: AppColors.primaryDark, size: 24),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AuraCare',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Enterprise Healthcare',
                      style: TextStyle(fontSize: 11, color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // User brief info
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        userRole.label,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Nav items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: destinations.length,
              itemBuilder: (context, idx) {
                final d = destinations[idx];
                final isSelected = idx == currentIndex;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  child: ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    selected: isSelected,
                    selectedTileColor: AppColors.primaryLight,
                    leading: Icon(
                      isSelected ? d.selectedIcon : d.icon,
                      color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
                      size: 20,
                    ),
                    title: Text(
                      d.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? AppColors.primaryDark : AppColors.text,
                      ),
                    ),
                    trailing: d.badgeCount != null && d.badgeCount! > 0
                        ? Badge(label: Text('${d.badgeCount}'))
                        : null,
                    onTap: () => _onNavigate(context, idx),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.settings_outlined, size: 20),
            title: const Text('Settings', style: TextStyle(fontSize: 14)),
            onTap: () => context.push('/settings'),
          ),
          if (onLogout != null)
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error, size: 20),
              title: const Text('Sign Out', style: TextStyle(color: AppColors.error, fontSize: 14)),
              onTap: onLogout,
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildDesktopHeader(BuildContext context, bool isDark) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border(bottom: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border)),
      ),
      child: Row(
        children: [
          Text(
            title ?? 'Dashboard',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.textSecondary),
            onPressed: () => context.push('/search'),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textSecondary),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
    );
  }
}

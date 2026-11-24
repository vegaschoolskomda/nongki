import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nongki/core/theme/app_colors.dart';
import 'package:nongki/providers/cart_provider.dart';
import 'package:nongki/providers/order_provider.dart';
import 'package:nongki/features/home/presentation/home_screen.dart';
import 'package:nongki/features/explore/presentation/explore_screen.dart';
import 'package:nongki/features/orders/presentation/orders_screen.dart';
import 'package:nongki/features/favorites/presentation/favorites_screen.dart';
import 'package:nongki/features/profile/presentation/profile_screen.dart';

class MainScaffold extends ConsumerStatefulWidget {
  final int initialIndex;

  const MainScaffold({super.key, this.initialIndex = 0});

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold>
    with TickerProviderStateMixin {
  late int _currentIndex;
  late List<AnimationController> _iconControllers;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _iconControllers = List.generate(
      5,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 220),
      ),
    );
    _iconControllers[_currentIndex].forward();
  }

  void switchTab(int index) {
    if (index == _currentIndex) return;
    _iconControllers[_currentIndex].reverse();
    setState(() {
      _currentIndex = index;
    });
    _iconControllers[index].forward();
  }

  @override
  void dispose() {
    for (final c in _iconControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final orderState = ref.watch(orderProvider);

    final activeOrdersCount = orderState.orders
        .where((o) => o.status != 'completed' && o.status != 'cancelled')
        .length;
    final badgeCount =
        cartState.isNotEmpty ? cartState.totalItemsCount : activeOrdersCount;

    final screens = [
      HomeScreen(onNavigateToExplore: () => switchTab(1)),
      const ExploreScreen(),
      const OrdersScreen(),
      const FavoritesScreen(),
      const ProfileScreen(),
    ];

    final navItems = [
      _NavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: 'Beranda',
      ),
      _NavItem(
        icon: Icons.search_outlined,
        activeIcon: Icons.search_rounded,
        label: 'Jelajah',
      ),
      _NavItem(
        icon: Icons.receipt_long_outlined,
        activeIcon: Icons.receipt_long_rounded,
        label: 'Pesanan',
        badge: badgeCount,
      ),
      _NavItem(
        icon: Icons.favorite_outline,
        activeIcon: Icons.favorite_rounded,
        label: 'Favorit',
      ),
      _NavItem(
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: 'Profil',
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.border, width: 0.6),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 62,
            child: Row(
              children: List.generate(navItems.length, (index) {
                final item = navItems[index];
                final isActive = _currentIndex == index;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => switchTab(index),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedBuilder(
                      animation: _iconControllers[index],
                      builder: (context, child) {
                        final t = _iconControllers[index].value;
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 3,
                              width: isActive ? 22 : 0,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Transform.scale(
                                  scale: 1.0 + (t * 0.08),
                                  child: Icon(
                                    isActive ? item.activeIcon : item.icon,
                                    size: 24,
                                    color: isActive
                                        ? AppColors.primary
                                        : AppColors.navInactive,
                                  ),
                                ),
                                if (item.badge != null && item.badge! > 0)
                                  Positioned(
                                    top: -4,
                                    right: -8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 1),
                                      constraints: const BoxConstraints(
                                        minWidth: 16,
                                        minHeight: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE67E22),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: Colors.white, width: 1.5),
                                      ),
                                      child: Text(
                                        '${item.badge}',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          height: 1.1,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.label,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 10,
                                fontWeight: isActive
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isActive
                                    ? AppColors.primary
                                    : AppColors.navInactive,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int? badge;

  _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.badge,
  });
}

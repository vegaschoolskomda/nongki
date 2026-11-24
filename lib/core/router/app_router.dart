import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/welcome/welcome_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/home/presentation/main_scaffold.dart';
import '../../features/place/presentation/place_detail_screen.dart';
import '../../features/menu/presentation/menu_screen.dart';
import '../../features/cart/presentation/cart_screen.dart';
import '../../features/checkout/presentation/checkout_screen.dart';
import '../../features/checkout/presentation/order_success_screen.dart';
import '../../features/orders/presentation/order_detail_screen.dart';
import '../../features/orders/presentation/live_order_tracking_screen.dart';
import '../../features/review/presentation/write_review_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/explore/presentation/map_screen.dart';
import '../../features/roulette/presentation/roulette_screen.dart';
import '../../features/swipe/presentation/swipe_screen.dart';
import '../../features/points/presentation/points_screen.dart';
import '../../features/merchant/presentation/merchant_dashboard_screen.dart';
import '../../features/cashier/presentation/cashier_dashboard_screen.dart';
import '../../features/admin/presentation/admin_control_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const MainScaffold(initialIndex: 0),
    ),
    GoRoute(
      path: '/explore-tab',
      builder: (context, state) => const MainScaffold(initialIndex: 1),
    ),
    GoRoute(
      path: '/orders-tab',
      builder: (context, state) => const MainScaffold(initialIndex: 2),
    ),
    GoRoute(
      path: '/favorites-tab',
      builder: (context, state) => const MainScaffold(initialIndex: 3),
    ),
    GoRoute(
      path: '/profile-tab',
      builder: (context, state) => const MainScaffold(initialIndex: 4),
    ),
    GoRoute(
      path: '/place/:id',
      builder: (context, state) {
        final rawId = state.pathParameters['id'] ?? '';
        final id = Uri.decodeComponent(rawId);
        return PlaceDetailScreen(placeId: id);
      },
    ),
    GoRoute(
      path: '/place/:id/menu',
      builder: (context, state) {
        final rawId = state.pathParameters['id'] ?? '';
        final id = Uri.decodeComponent(rawId);
        return MenuScreen(placeId: id);
      },
    ),
    GoRoute(
      path: '/cart',
      builder: (context, state) => const CartScreen(),
    ),
    GoRoute(
      path: '/checkout',
      builder: (context, state) => const CheckoutScreen(),
    ),
    GoRoute(
      path: '/order-success/:orderId',
      builder: (context, state) {
        final orderId = state.pathParameters['orderId']!;
        return OrderSuccessScreen(orderId: orderId);
      },
    ),
    GoRoute(
      path: '/order/:orderId',
      builder: (context, state) {
        final orderId = state.pathParameters['orderId']!;
        return OrderDetailScreen(orderId: orderId);
      },
    ),
    GoRoute(
      path: '/order-tracking/:orderId',
      builder: (context, state) {
        final orderId = state.pathParameters['orderId']!;
        return LiveOrderTrackingScreen(orderId: orderId);
      },
    ),
    GoRoute(
      path: '/write-review/:orderId',
      builder: (context, state) {
        final orderId = state.pathParameters['orderId']!;
        return WriteReviewScreen(orderId: orderId);
      },
    ),
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: '/map',
      builder: (context, state) => const MapScreen(),
    ),
    GoRoute(
      path: '/map/:id',
      builder: (context, state) {
        final rawId = state.pathParameters['id'];
        final id = rawId != null ? Uri.decodeComponent(rawId) : null;
        return MapScreen(initialPlaceId: id);
      },
    ),
    // ── Exhibition Edition New Routes ─────────────────────────────────────────
    GoRoute(
      path: '/roulette',
      builder: (context, state) => const RouletteScreen(),
    ),
    GoRoute(
      path: '/swipe',
      builder: (context, state) => const SwipeDiscoverScreen(),
    ),
    GoRoute(
      path: '/points',
      builder: (context, state) => const PointsScreen(),
    ),
    GoRoute(
      path: '/merchant',
      builder: (context, state) => const MerchantDashboardScreen(),
    ),
    GoRoute(
      path: '/merchant-dashboard',
      builder: (context, state) => const MerchantDashboardScreen(),
    ),
    GoRoute(
      path: '/cashier-dashboard',
      builder: (context, state) => const CashierDashboardScreen(),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminControlScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Halaman tidak ditemukan: ${state.uri}'),
    ),
  ),
);

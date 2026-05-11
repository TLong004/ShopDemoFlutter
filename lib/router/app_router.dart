import 'package:go_router/go_router.dart';
import 'package:shopdemo/models/product.dart';
import 'package:shopdemo/views/cart/cart_page.dart';
import 'package:shopdemo/views/chart/chart.dart';
import 'package:shopdemo/views/google_map/map_tracking_screen.dart';
import 'package:shopdemo/views/home/detail_page.dart';
import 'package:shopdemo/views/home/home_page.dart';
import 'package:shopdemo/views/home/search_page.dart';
import 'package:shopdemo/views/main/main_page.dart';
import 'package:shopdemo/views/profile/profile_page.dart';
import 'package:shopdemo/views/wallet/wallet_page.dart';

final appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => MainPage(shell: shell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomePage(),
            routes: [
              GoRoute(
                path: 'detail',
                builder: (context, state) {
                  final product = state.extra as Product;
                  return DetailPage(product: product);
                },
              ),
              GoRoute(
                path: 'search',
                builder: (context, state) => const SearchPage(),
              ),
            ],
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/cart', builder: (context, state) => const CartPage()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/wallet', builder: (context, state) => const WalletPage()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/profile', builder: (context, state) => const ProfilePage()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/chart', builder: (context, state) => Chart()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/map', builder: (context, state) => const MapTrackingScreen()),
        ]),
      ],
    ),
  ],
);

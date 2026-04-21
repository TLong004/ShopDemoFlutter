import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopdemo/services/bloc/connectivity_bloc.dart';
import 'package:shopdemo/views/cart/cart_page.dart';
import 'package:shopdemo/views/cart/bloc/cart_bloc/cart_bloc.dart';
import 'package:shopdemo/views/chart/chart.dart';
import 'package:shopdemo/views/home/home_page.dart';
import 'package:shopdemo/views/profile/profile_page.dart';
import 'package:shopdemo/views/wallet/wallet_page.dart';
import 'package:shopdemo/views/home/bloc/product_bloc/product_bloc.dart';
import 'package:shopdemo/views/home/cubit/banner_cubit.dart';
import 'package:shopdemo/views/home/cubit/category_cubit.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  List<Widget> _buildPages() {
    return [
      const HomePage(),
      const CartPage(),
      const WalletPage(),
      const ProfilePage(),
      _currentIndex == 4 ? Chart() : const SizedBox.shrink(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ConnectivityBloc, ConnectivityState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();

        if (state.status == ConnectivityStatus.disconnected) {
          messenger.showSnackBar(
            SnackBar(
              content: const Text("Không có kết nối internet"),
              backgroundColor: Colors.red,
              duration: Duration(days: 1), 
              showCloseIcon: true,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state.status == ConnectivityStatus.connected) {
          messenger.showSnackBar(
            SnackBar(
              content: Text("Đã có kết nối trở lại"),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3), 
              behavior: SnackBarBehavior.floating,
            ),
          );
 
          Future.delayed(const Duration(milliseconds: 500), () {
            if (context.mounted) {
              context.read<ProductBloc>().add(LoadProducts());
              context.read<BannerCubit>().loadBanners();
              context.read<CategoryCubit>().loadCategories();
            }
          });
        }
      },
      builder: (context, state) {
        return  Scaffold(
          extendBody: true,
          body: IndexedStack(
            index: _currentIndex,
            children: _buildPages(),
          ),
          bottomNavigationBar: _buildCustomBottomBar(),
        );
      }
    );
  }

  Widget _buildCustomBottomBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(50, 0, 50, 30),
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home, Icons.home_outlined, 0),
          _buildCartNavItem(Icons.shopping_cart, Icons.shopping_cart_outlined, 1),
          _buildNavItem(Icons.account_balance_wallet, Icons.account_balance_wallet_outlined, 2),
          _buildNavItem(Icons.person, Icons.person_outline, 3),
          _buildNavItem(Icons.pie_chart, Icons.pie_chart_outline, 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData activeIcon, IconData inactiveIcon, int index) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: _buildIconContent(activeIcon, inactiveIcon, isSelected),
    );
  }

  Widget _buildCartNavItem(IconData activeIcon, IconData inactiveIcon, int index) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
        context.read<CartBloc>().add(MarkCartAsViewed());
      },
      behavior: HitTestBehavior.opaque,
      child: BlocSelector<CartBloc, CartState, int>(
        selector: (state) => state.unviewedCount,
        builder: (context, count) {
          return Badge(
            label: Text('$count'),
            isLabelVisible: count > 0,
            backgroundColor: Colors.redAccent,
            child: _buildIconContent(activeIcon, inactiveIcon, isSelected),
          );
        },
      ),
    );
  }

  Widget _buildIconContent(IconData activeIcon, IconData inactiveIcon, bool isSelected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isSelected ? activeIcon : inactiveIcon,
            color: isSelected ? Colors.blueAccent : Colors.grey.shade500,
            size: 26,
          ),
        ),
      ],
    );
  }
}
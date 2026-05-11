import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shopdemo/blocs/connectivity_bloc.dart';
import 'package:shopdemo/views/cart/bloc/cart_bloc/cart_bloc.dart';
import 'package:shopdemo/views/home/bloc/product_bloc/product_bloc.dart';
import 'package:shopdemo/views/home/cubit/banner_cubit.dart';
import 'package:shopdemo/views/home/cubit/category_cubit.dart';

class MainPage extends StatefulWidget {
  final StatefulNavigationShell shell;
  const MainPage({super.key, required this.shell});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
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
              duration: const Duration(days: 1),
              showCloseIcon: true,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state.status == ConnectivityStatus.connected) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text("Đã có kết nối trở lại"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
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
        return Scaffold(
          extendBody: true,
          body: widget.shell,
          bottomNavigationBar: _buildCustomBottomBar(),
        );
      },
    );
  }

  Widget _buildCustomBottomBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 30),
      height: 75,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(child: _buildNavItem(Icons.home, Icons.home_outlined, 0, "Trang chủ")),
          Expanded(child: _buildCartNavItem(Icons.shopping_cart, Icons.shopping_cart_outlined, 1)),
          Expanded(child: _buildNavItem(Icons.account_balance_wallet, Icons.account_balance_wallet_outlined, 2, "Ví điện tử")),
          Expanded(child: _buildNavItem(Icons.person, Icons.person_outline, 3, "Tài khoản")),
          Expanded(child: _buildNavItem(Icons.pie_chart, Icons.pie_chart_outline, 4, "Thống kê")),
          Expanded(child: _buildNavItem(Icons.map, Icons.map_outlined, 5, "Bản đồ")),
        ],
      ),
    );
  }

  Widget _buildIconContent(IconData activeIcon, IconData inactiveIcon, bool isSelected, String label) {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withValues(alpha: 0.1) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: isSelected ? Colors.blueAccent : Colors.grey.shade500,
              size: 22,
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? Colors.blueAccent : Colors.grey.shade500,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData activeIcon, IconData inactiveIcon, int index, String label) {
    final isSelected = widget.shell.currentIndex == index;
    return GestureDetector(
      onTap: () => widget.shell.goBranch(index),
      behavior: HitTestBehavior.opaque,
      child: _buildIconContent(activeIcon, inactiveIcon, isSelected, label),
    );
  }

  Widget _buildCartNavItem(IconData activeIcon, IconData inactiveIcon, int index) {
    final isSelected = widget.shell.currentIndex == index;
    return GestureDetector(
      onTap: () {
        widget.shell.goBranch(index);
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
            child: _buildIconContent(activeIcon, inactiveIcon, isSelected, "Giỏ hàng"),
          );
        },
      ),
    );
  }
}

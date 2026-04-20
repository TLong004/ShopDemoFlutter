import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopdemo/views/cart/bloc/cart_bloc/cart_bloc.dart';
import 'package:shopdemo/views/home/bloc/product_bloc/product_bloc.dart';
import 'package:shopdemo/views/home/search_page.dart';
import 'package:shopdemo/views/home/widgets/banner_card.dart';
import 'package:shopdemo/views/home/widgets/category_card.dart';
import 'package:shopdemo/views/home/widgets/product_cart.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Shop Demo'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchPage()),
              );
            },
            icon: Icon(Icons.search),
          ),
        ],
      ),
      body: BlocListener<CartBloc, CartState>(
        listenWhen: (previous, current) => previous.status != current.status && current.status == CartStatus.success,
        listener: (context, state) {
          if (state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message!),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 1),
              ),
            );
          }
        },
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<ProductBloc>().add(LoadProducts());
            await context.read<ProductBloc>().stream.firstWhere(
              (state) => state is ProductLoaded || state is ProductError,
            );
          },
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(
                child: BannerWidget(),
              ),
              const SliverToBoxAdapter(
                child: CategoryCard(),
              ),
              BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  if (state is ProductInitial) {
                    context.read<ProductBloc>().add(LoadProducts());
                    return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (state is ProductLoading) {
                    return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (state is ProductLoaded) {
                    final products = state.products;
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return ProductCart(product: products[index]);
                        },
                        childCount: products.length,
                      ),
                    );
                  } else if (state is ProductError) {
                    return SliverFillRemaining(
                      child: Center(child: Text('Error: ${state.message}')),
                    );
                  } else if (state is ProductByCategoryLoaded) {
                    final products = state.products;
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return ProductCart(product: products[index]);
                        },
                        childCount: products.length,
                      ),
                    );
                  }
                  return const SliverFillRemaining(
                    child: Center(child: Text('No products found.')),
                  );
                },
              ),
            ]
          ),
        ),
      ),
    );
  }
}
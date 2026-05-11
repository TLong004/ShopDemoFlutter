import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopdemo/views/cart/bloc/cart_bloc/cart_bloc.dart';
import 'package:shopdemo/views/home/bloc/product_bloc/product_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shopdemo/views/home/widgets/banner_card.dart';
import 'package:shopdemo/views/home/widgets/category_card.dart';
import 'package:shopdemo/views/home/widgets/product_card.dart';
import 'package:shopdemo/widgets/product_skeleton.dart';

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
            onPressed: () => context.push('/home/search'),
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
                  if (state is ProductLoading) {
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => const ProductSkeleton(),
                        childCount: 6,  // hiện 6 skeleton card
                      ),
                    );
                  } else if (state is ProductLoaded) {
                    final products = state.products;
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return ProductCard(product: products[index]);
                        },
                        childCount: products.length,
                      ),
                    );
                  } else if (state is ProductError) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.cloud_off_rounded, size: 64, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text(
                                state.message,   
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.grey, fontSize: 15),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () => context.read<ProductBloc>().add(LoadProducts()),
                                icon: const Icon(Icons.refresh),
                                label: const Text('Thử lại'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }  else if (state is ProductByCategoryLoaded) {
                    final products = state.products;
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return ProductCard(product: products[index]);
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
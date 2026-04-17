import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopdemo/models/category.dart';
import 'package:shopdemo/views/home/bloc/product_bloc/product_bloc.dart';
import 'package:shopdemo/views/home/cubit/category_cubit.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        BlocBuilder<CategoryCubit, CategoryState>(
          builder: (context, state) {
            if (state is CategoryLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CategoryLoaded) {
              final categories = state.categories;
              return SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return CategoryItem(category: categories[index]);
                  },
                ),
              );
            } else if (state is CategoryError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const Center(child: Text('No categories found.'));
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

class CategoryItem extends StatelessWidget {
  final Category category;
  const CategoryItem({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final _isSelect = context.select<ProductBloc, String>((bloc) {
      final state = bloc.state;
      if (state is ProductLoaded) {
        return state.category;
      } else if (state is ProductByCategoryLoaded) {
        return state.category;
      } else if (state is ProductLoading) {
        return state.category;
      }
      return 'All';
    }) == category.slug;

    return GestureDetector(
      onTap: () {
        context.read<ProductBloc>().add(LoadProductsByCategory(category.slug));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _isSelect ? Colors.blue : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(category.name, style: TextStyle(color: _isSelect ? Colors.white : Colors.black, fontSize: 14  )),
      ),
    );
  }
}
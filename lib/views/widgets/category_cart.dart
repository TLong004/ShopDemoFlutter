import 'package:flutter/material.dart';
import 'package:shopdemo/blocs/product_bloc.dart';
import 'package:shopdemo/models/category.dart';

class CategoryCart extends StatelessWidget {
  final ProductBloc bloc;
  CategoryCart({super.key, required this.bloc});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        SizedBox(
          height: 40,
          child: StreamBuilder<List<Category>>(
            stream: bloc.categoryStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final categories = snapshot.data!;
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(categories[index].name, style: const TextStyle(fontSize: 14)),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
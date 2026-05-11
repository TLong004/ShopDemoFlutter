import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopdemo/models/product.dart';
import 'package:shopdemo/views/home/bloc/product_bloc/product_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shopdemo/views/home/widgets/product_card.dart';

class SearchPage extends StatefulWidget {

  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(ClearSearch());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Shop Demo"),
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            context.read<ProductBloc>().add(ClearSearch());
            context.pop();
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: Column(
        children: [
          Column(
            children: [
              TextField(
                controller: _controller,
                onChanged: (value) {
                  context.read<ProductBloc>().add(SearchProduct(_controller.text));
                },
                onSubmitted: (value) {
                  context.read<ProductBloc>().add(SearchProduct(_controller.text));
                },
                decoration: InputDecoration(
                  hintText: "Nhập tên sản phẩm...",
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  prefixIcon: IconButton(
                    onPressed: () {
                      context.read<ProductBloc>().add(SearchProduct(_controller.text));
                    }, 
                    icon: Icon(Icons.search)
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none, 
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ],
          ),
          Expanded(
            child: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state is ProductLoading) {
                  return Center(child: CircularProgressIndicator(),);
                } else if (state is ProductLoadedSearch) {
                  final List<Product> products = state.products;
                  if (products.isEmpty) {
                    return Center(child: Text("Không tìm thấy sản phẩm"),);
                  }
                  return ListView.builder(
                    itemCount: state.products.length,
                    itemBuilder: (context, index) {
                      return ProductCard(product: products[index]);
                    }
                  );
               } else if (state is ProductError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey),
                          const SizedBox(height: 12),
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () => context.read<ProductBloc>().add(
                              SearchProduct(_controller.text),
                            ),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Center(child: Text("Nhập từ khoá để tìm sản phẩm"),);
              }
            ),
          )
        ],
      ),  
    );
  }
}
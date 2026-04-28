import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopdemo/models/product.dart';
import 'package:shopdemo/views/home/bloc/product_bloc/product_bloc.dart';
import 'package:shopdemo/views/home/widgets/product_cart.dart';

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
            Navigator.pop(context);
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
                  setState(() {
                    
                  });
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
                      return ProductCart(product: products[index]);
                    }
                  );
                } else if (state is ProductError) {
                  return Container(
                    child: Center(child: Text(state.message, style: TextStyle(color: Colors.red))),
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
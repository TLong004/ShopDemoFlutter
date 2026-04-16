import 'package:flutter/material.dart';
import 'package:shopdemo/blocs/product_bloc.dart';
import 'package:shopdemo/blocs/product_event.dart';
import 'package:shopdemo/blocs/product_state.dart';
import 'package:shopdemo/views/widgets/product_cart.dart';

class SearchPage extends StatefulWidget {
  final ProductBloc bloc;
  const SearchPage({super.key, required this.bloc});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    widget.bloc.eventSink.add(SearchProducts(''));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Search products...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    widget.bloc.eventSink.add(SearchProducts(_controller.text));
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<ProductState>(
              stream: widget.bloc.searchStream,
              builder: (context, snapshot) {
                final state = snapshot.data;
                if (state is ProductLoading) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is ProductEmpty) {
                  return const Center(child: Text('Không tìm thấy sản phẩm...'));
                } else if (state is ProductLoaded) {
                  return ListView.builder(
                    itemCount: state.products.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          ProductCart(product: state.products[index]),
                        ],
                      );
                    }
                  );
                } else if (state is ProductInitial) {
                  return const Center(child: Text('Nhập từ khóa để tìm kiếm...'));
                }
                return Container();
              },
            ),
          ),
        ],
      ),
    );
  }
}
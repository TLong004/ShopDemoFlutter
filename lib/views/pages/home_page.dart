import 'package:flutter/material.dart';
import 'package:shopdemo/blocs/product_bloc.dart';
import 'package:shopdemo/blocs/product_event.dart';
import 'package:shopdemo/blocs/product_state.dart';
import 'package:shopdemo/views/pages/search_page.dart';
import 'package:shopdemo/views/widgets/banner.dart';
import 'package:shopdemo/views/widgets/category_cart.dart';
import 'package:shopdemo/views/widgets/product_cart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _bloc = ProductBloc();

  @override
  void initState() {
    super.initState();
    _bloc.eventSink.add(LoadProducts());
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shop Demo'),
        backgroundColor: Colors.white,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Icon(Icons.search, color: Colors.black),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SearchPage(bloc: _bloc))); 
              },
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: StreamBuilder<ProductState>(
        stream: _bloc.stateStream,
        builder: (context, snapshot) {
          final state = snapshot.data;
          if (state is ProductLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is ProductLoaded) {
            return ListView.builder(
              itemCount: state.products.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return BannerWidget(bloc: _bloc);
                } else if (index == 1) {
                  return CategoryCart(bloc: _bloc);
                }
                final product = state.products[index - 2];
                return Column(
                  children: [
                    ProductCart(product: product),
                  ],
                );
              }
            );
          }
          return Container();
        },
      ),
    );
  }
}
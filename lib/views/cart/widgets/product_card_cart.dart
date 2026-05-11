import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopdemo/models/product.dart';
import 'package:shopdemo/views/cart/bloc/cart_bloc/cart_bloc.dart';
import 'package:shopdemo/widgets/network_image_widget.dart';

class ProductCardCart extends StatefulWidget {
  final Product product;
  const ProductCardCart({super.key, required this.product});

  @override
  State<ProductCardCart> createState() => _ProductCardCartState();
}

class _ProductCardCartState extends State<ProductCardCart> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: NetworkImageWidget(url: widget.product.thumbnail, fit: BoxFit.cover),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.product.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('\$${widget.product.price}'),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 5,
            right: 5,
            child: BlocSelector<CartBloc, CartState, int>(
              selector: (state) => state.productMap[widget.product.id]?.quantity ?? 0,
              builder: (context, state) {
                _controller.text = state.toString();
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                final cartState = context.read<CartBloc>().state;
                                final currentProductInCart = cartState.productMap[widget.product.id] ?? widget.product;
                                context.read<CartBloc>().add(DecreaseQuantity(currentProductInCart));
                              },
                              icon: const Icon(Icons.remove, size: 18, color: Colors.blue),
                            ),
                            SizedBox(
                              width: 40,
                              child: TextField(
                                controller: _controller,
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                onSubmitted: (value) {
                                  final int? newQua = int.tryParse(value);
                                  if (newQua != null) {
                                    context.read<CartBloc>().add(UpdateQuantity(widget.product, newQua));
                                  } else {
                                    _controller.text = state.toString();
                                  }
                                },
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.zero,
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                final cartState = context.read<CartBloc>().state;
                                final currentProductInCart = cartState.productMap[widget.product.id] ?? widget.product;
                                context.read<CartBloc>().add(IncreaseQuantity(currentProductInCart));
                              },
                              icon: const Icon(Icons.add, size: 18, color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () {
                          context.read<CartBloc>().add(RemoveToCart(widget.product));
                        },
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                        label: const Text('Remove', style: TextStyle(color: Colors.red)),
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

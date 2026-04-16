import 'package:flutter/material.dart';
import 'package:shopdemo/models/product.dart';

class ProductCart extends StatelessWidget {
  final Product product;
  const ProductCart({super.key, required this.product});

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
                  child: Image.network(
                    product.thumbnail, 
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('\$${product.price}'),
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
            child: ElevatedButton(
              onPressed: () {
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Add to Cart',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
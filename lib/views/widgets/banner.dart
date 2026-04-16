import 'package:flutter/material.dart';
import 'package:shopdemo/blocs/product_bloc.dart';

class BannerWidget extends StatelessWidget {
  final ProductBloc bloc;
  
  const BannerWidget({super.key, required this.bloc});

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      height: 200,
      child: StreamBuilder<List<String>> (
        stream: bloc.bannerStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final bannerImages = snapshot.data!;
          return PageView.builder(
            itemCount: bannerImages.length,
            controller: PageController(viewportFraction: 0.96),
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey.shade200,
                ),
                child: Image.network(
                  bannerImages[index],
                  fit: BoxFit.contain,
                ),
              );
            },
          );
        },
      )
    );
  }
}
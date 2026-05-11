import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopdemo/views/home/cubit/banner_cubit.dart';
import 'package:shopdemo/widgets/network_image_widget.dart';

class BannerWidget extends StatelessWidget {
  
  const BannerWidget({super.key});

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      height: 200,
      child: BlocBuilder<BannerCubit, BannerState>(
        builder: (context, state) {
          if (state is BannerLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is BannerLoaded) {
            final banners = state.banners;
            return SizedBox(
              height: 200,
              child: PageView.builder(
                itemCount: banners.length,
                controller: PageController(viewportFraction: 0.96),
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey.shade200,
                    ),
                    child: NetworkImageWidget(url: banners[index], fit: BoxFit.contain),
                  );
                }
              ),
            );
          } else if (state is BannerError) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.image_not_supported_outlined, size: 40, color: Colors.grey),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            );
          }

          return const Center(child: Text('No banners found.'));
        },
      ),
    );
  }
}
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shopdemo/repositories/product_repository.dart';

part 'banner_state.dart';

class BannerCubit extends Cubit<BannerState> {
  ProductRepository _productRepository;

  BannerCubit({required ProductRepository productRepository}) : _productRepository = productRepository, super(BannerInitial());

  Future<void> loadBanners() async {
    emit(BannerLoading()); 
    try {
      final banners = await _productRepository.fetchBanners();
      emit(BannerLoaded(banners));
    } catch (e) {
      emit(BannerError(e.toString()));
    }
  }
}

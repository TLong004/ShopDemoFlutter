import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopdemo/repositories/product_repository.dart';
import 'package:shopdemo/services/bloc/connectivity_bloc.dart';
import 'package:shopdemo/services/local_notification_service.dart';
import 'package:shopdemo/services/shared_prefs_helper.dart';
import 'package:shopdemo/views/cart/bloc/cart_bloc/cart_bloc.dart';
import 'package:shopdemo/views/home/bloc/product_bloc/product_bloc.dart';
import 'package:shopdemo/views/home/cubit/banner_cubit.dart';
import 'package:shopdemo/views/home/cubit/category_cubit.dart';
import 'package:shopdemo/views/main/main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefsHelper.init();
  await LocalNotificationService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => ProductRepository(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => ProductBloc(
              productRepository: context.read<ProductRepository>(),
            )..add(LoadProducts()),
          ),
          BlocProvider(
            create: (context) => BannerCubit(
              productRepository: context.read<ProductRepository>(),
            )..loadBanners(),
          ),
          BlocProvider(
            create: (context) => CategoryCubit(
              productRepository: context.read<ProductRepository>(),
            )..loadCategories(),
          ),
          BlocProvider(
            create:  (context) => CartBloc()
          ),
          BlocProvider(
            create: (context) => ConnectivityBloc(
              
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(primarySwatch: Colors.blue),
          debugShowCheckedModeBanner: false,
          home: const MainPage(),
        ),
      ),
    );
  }
}

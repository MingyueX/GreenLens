import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tree/screens/profile_page/profile_page.dart';
import 'package:tree/screens/splash_screen/splash_screen_viewmodel.dart';

import '../../base/custom_route.dart';
import '../../base/widgets/loader.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = SplashScreenViewModel();

    return BlocProvider<SplashScreenViewModel>(
        create: (_) => viewModel..loadData(),
        child: BlocBuilder<SplashScreenViewModel, SplashScreenState>(
            builder: (context, state) {
              if (state is DataLoading) {
                WidgetsBinding.instance!.addPostFrameCallback((_) {
                  Navigator.of(context).push(CustomRoute(
                      builder: (context) {
                        return Loader.loaderWidget(context,
                        );
                      }));
                });
              }
              if (state is DataLoaded) {
                WidgetsBinding.instance!.addPostFrameCallback((_) {
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => const ProfilePage()),
                      (route) => false);
                });
              }
              return Center(
                child: Image.asset("assets/images/splash_screen.png"),
              );
            }
        )
    );
  }
}

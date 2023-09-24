import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:tree/screens/main_pages/plot_page/plot_page_viewmodel.dart';
import 'package:tree/screens/profile_collect_page/profile_collect_page.dart';
import 'package:tree/screens/splash_screen/splash_screen_viewmodel.dart';

import '../../base/custom_route.dart';
import '../../base/widgets/loader.dart';
import '../main_pages/profile_page/farmer_provider.dart';
import '../page_navigation/page_navigation.dart';

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
              Navigator.of(context).push(CustomRoute(builder: (context) {
                return Loader.loaderWidget(
                  context,
                );
              }));
            });
          }
          if (state is DataLoadedExistUser) {
            WidgetsBinding.instance!.addPostFrameCallback((_) async {
              await Provider.of<FarmerProvider>(context, listen: false)
                  .setFarmer(state.farmer);
              if (context.mounted) {
                await context
                    .read<PlotPageViewModel>()
                    .setFarmer(state.farmer.participantId);
              }
              if (context.mounted) {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const TabbedPage()));
              }
            });
          }
          if (state is DataLoadedNewUser) {
            WidgetsBinding.instance!.addPostFrameCallback((_) {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => const ProfileCollectPage()),
                  (route) => false);
            });
          }
          return Center(
            child: Image.asset("assets/images/splash_screen.png"),
          );
        }));
  }
}

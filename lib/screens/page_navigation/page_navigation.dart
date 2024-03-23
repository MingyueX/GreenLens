import 'package:GreenLens/base/widgets/shortcut_to_improc.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GreenLens/screens/page_navigation/page_nav_viewmodel.dart';
import 'package:provider/provider.dart';

import '../../../theme/colors.dart';
import '../../base/widgets/shortcut_to_capture.dart';
import '../../model/models.dart';
import '../main_pages/plot_page/plot_page_viewmodel.dart';
import '../main_pages/profile_page/farmer_provider.dart';

class TabbedPage extends StatefulWidget {
  const TabbedPage({super.key});

  @override
  State<TabbedPage> createState() => _TabbedPageState();
}

class _TabbedPageState extends State<TabbedPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TabbedPageViewModel _viewModel;

  static const double labelPadding = 2;
  static const double topIndicatorWidth = 3;

  @override
  void initState() {
    super.initState();

    _viewModel = TabbedPageViewModel();
    _tabController = TabController(length: _viewModel.tabs.length, vsync: this);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _viewModel.switchToPage(MainPage.values[_tabController.index], context);
      }
    });

    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      Farmer? currentUser = Provider.of<FarmerProvider>(context, listen: false).farmer;
      await context
          .read<PlotPageViewModel>()
          .setFarmer(currentUser.participantId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TabbedPageViewModel>(
      create: (_) => _viewModel,
      child: BlocBuilder<TabbedPageViewModel, TabbedPageState>(
          builder: (context, state) {
        int index = MainPage.values.indexOf(state.currentPage);
        if (_tabController.index != index) {
          _tabController.animateTo(index); // Update the tab controller's index.
        }
        return Scaffold(
          backgroundColor: AppColors.baseWhite,
          body: IndexedStack(
              index: MainPage.values.indexOf(state.currentPage),
              children: _viewModel.pages
                  .map((page) => Navigator(
                      onGenerateRoute: (settings) =>
                          MaterialPageRoute(builder: (_) => page)))
                  .toList()),
          // floatingActionButton: ShortCutButton(),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(color: AppColors.primaryGreen),
            child: TabBar(
                controller: _tabController,
                indicator: const BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: AppColors.baseWhite,
                      width: topIndicatorWidth,
                    ),
                  ),
                ),
                tabs: _viewModel.tabs.keys
                    .mapIndexed((index, key) => Tab(
                          icon: Padding(
                              padding:
                                  const EdgeInsets.only(bottom: labelPadding),
                              child: Icon(
                                _viewModel.tabs[key],
                                color: index ==
                                        MainPage.values
                                            .indexOf(state.currentPage)
                                    ? AppColors.baseWhite
                                    : AppColors.baseWhite.withOpacity(0.5),
                                size: 20,
                              )),
                          text: index ==
                                  MainPage.values.indexOf(state.currentPage)
                              ? key
                              : null,
                        ))
                    .toList(),
                labelColor: AppColors.baseWhite,
                labelPadding: const EdgeInsets.all(labelPadding)),
          ),
        );
      }),
    );
  }
}

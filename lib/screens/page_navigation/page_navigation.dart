import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tree/screens/page_navigation/page_nav_viewmodel.dart';
import 'package:tree/theme/themes.dart';

import '../../../theme/colors.dart';
import '../main_pages/plot_page/new_plot_collection.dart';

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
        return Scaffold(
          backgroundColor: AppColors.baseWhite,
          body: IndexedStack(
              index: MainPage.values.indexOf(state.currentPage),
              children: _viewModel.pages
                  .map((page) => Navigator(
                      onGenerateRoute: (settings) =>
                          MaterialPageRoute(builder: (_) => page)))
                  .toList()),
          appBar: state.currentPage == MainPage.profilePage
              ? null
              : AppBar(
                  toolbarHeight: 100,
                  actions: [
                    Padding(
                        padding: const EdgeInsets.only(top: 20, right: 10),
                        child: IconButton(
                            onPressed: () {
                              if (state.currentPage == MainPage.plotPage) {
                                Navigator.of(context, rootNavigator: true).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const AddPlotPage()));
                              }
                            },
                            icon: const Icon(
                              Icons.add,
                              color: AppColors.baseWhite,
                            )))
                  ],
                  automaticallyImplyLeading: false,
                  backgroundColor: AppColors.primaryGreen,
                  title: Padding(
                    padding: const EdgeInsets.only(left: 10, top: 20),
                    child: Text(
                      // TODO: mark tree's plot id with tree listener
                      state.currentPage == MainPage.plotPage
                          ? 'Plots'
                          : "Trees",
                      style: Theme.of(context).textTheme.appbarTitle,
                    ),
                  )),
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

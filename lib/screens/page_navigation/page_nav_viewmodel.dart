import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:GreenLens/screens/main_pages/map_page/map_page.dart';
import 'package:GreenLens/screens/main_pages/plot_page/plot_page.dart';
import 'package:GreenLens/screens/main_pages/profile_page/profile_page.dart';
import 'package:GreenLens/theme/colors.dart';

import '../../theme/icons.dart';
import '../main_pages/tree_page/tree_page.dart';

enum MainPage {
  profilePage,
  plotPage,
  treePage,
  mapPage,
}

class TabbedPageViewModel extends Cubit<TabbedPageState> {
  late List<Widget> pages;
  late Map<String, IconData> tabs;

  static const MainPage initialPage = MainPage.profilePage;

  TabbedPageViewModel()
      : super(TabbedPageState(initialPage)) {
    // TODO: replace with other screens
    pages = [
      const ProfilePage(),
      const PlotPage(),
      const TreePage(),
      const MapPage()
    ];

    tabs = {
      "profile": AppIcons.profile,
      "plots": AppIcons.plot,
      "trees": AppIcons.tree,
      "map": Icons.map,
    };
  }

  void switchToPage(MainPage page, BuildContext context) {
    emit(TabbedPageState(page));
  }
}

class TabbedPageState {
  final MainPage currentPage;

  TabbedPageState(this.currentPage);
}

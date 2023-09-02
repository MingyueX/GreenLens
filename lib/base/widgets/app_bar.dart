import 'package:flutter/material.dart';
import 'package:tree/theme/themes.dart';

import '../../theme/colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({Key? key, required this.title, required this.actions})
      : super(key: key);

  final String title;
  final Map<IconData, Function> actions;

  @override
  Widget build(BuildContext context) {
    return AppBar(
        toolbarHeight: 100,
        actions: actions.entries
            .map((e) => Padding(
                padding: const EdgeInsets.only(top: 20, right: 10),
                child: IconButton(
                    onPressed: () {
                      e.value();
                    },
                    icon: Icon(
                      e.key,
                      color: AppColors.baseWhite,
                    ))))
            .toList(),
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.primaryGreen,
        title: Padding(
          padding: const EdgeInsets.only(left: 10, top: 20),
          child: Text(
            title,
            style: Theme.of(context).textTheme.appbarTitle,
          ),
        ));
  }

  @override
  Size get preferredSize => const Size.fromHeight(100);
}

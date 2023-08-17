import 'package:flutter/material.dart';
import 'package:tree/theme/colors.dart';

import '../../../base/widgets/gradient_bg.dart';
import 'widget/tree_collect_card.dart';

class AddTreePage extends StatelessWidget {
  const AddTreePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: GradientBg(
            child: Center(
                child: SingleChildScrollView(
                    child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        child:
                            Card(color: AppColors.baseWhite, elevation: 1.0, child: TreeCollectCard()))))));
  }
}

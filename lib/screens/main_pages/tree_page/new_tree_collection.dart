import 'package:flutter/material.dart';
import 'package:GreenLens/theme/colors.dart';

import '../../../base/widgets/gradient_bg.dart';
import '../../../model/models.dart';
import 'widget/tree_collect_card.dart';

class AddTreePage extends StatelessWidget {
  const AddTreePage({Key? key, this.tree}) : super(key: key);

  final Tree? tree;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GradientBg(
            child: Center(
                child: SingleChildScrollView(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        child:
                            Card(color: AppColors.baseWhite, elevation: 1.0, child: TreeCollectCard(tree: tree)))))));
  }
}

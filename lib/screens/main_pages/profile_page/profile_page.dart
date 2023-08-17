import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tree/screens/set_up_page/set_up_page.dart';
import 'package:tree/theme/colors.dart';

import '../../../base/widgets/gradient_bg.dart';
import '../../../farmer_provider.dart';
import '../../../model/models.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  static const String editOption = "Edit Profile";
  static const double padding = 25;

  @override
  Widget build(BuildContext context) {
    Farmer farmer = Provider.of<FarmerProvider>(context).farmer!;

    String profileHeading = farmer.name;
    String profileSubHeading = 'Participant#${farmer.participantId}';

    return GradientBg(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(padding),
          child: Column(
            children: [
              const SizedBox(height: 100),

              /// -- IMAGE
              Stack(
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: const Image(
                            image: AssetImage("assets/images/avatar_grey.png"),
                            fit: BoxFit.fitWidth)),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: AppColors.primaryGreen),
                      child: const Icon(
                        Icons.edit,
                        color: AppColors.baseWhite,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(profileHeading,
                  style: Theme.of(context).textTheme.bodyLarge),
              Text(profileSubHeading,
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 20),

              /// -- BUTTON
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                        builder: (context) => const SetUpPage()));
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      side: BorderSide.none,
                      shape: const StadiumBorder()),
                  child: Text(editOption,
                      style: Theme.of(context).textTheme.labelLarge),
                ),
              ),
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 10),

              // TODO: MENU
              const Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.switch_account, color: AppColors.grey),
                    title: Text("Switch Account"),
                  ),
                  ListTile(
                    leading: Icon(Icons.dark_mode, color: AppColors.grey),
                    title: Text("Mode"),
                  ),
                  ListTile(
                    leading: Icon(Icons.settings, color: AppColors.grey),
                    title: Text("Settings"),
                  ),
                  ListTile(
                    leading: Icon(Icons.help, color: AppColors.grey),
                    title: Text("Help"),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

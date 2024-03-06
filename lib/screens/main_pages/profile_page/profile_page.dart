import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:GreenLens/theme/colors.dart';

import '../../../base/custom_route.dart';
import '../../../base/widgets/gradient_bg.dart';
import '../../../utils/file_storage.dart';
import 'farmer_provider.dart';
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
              //
              // // TODO: MENU
              Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      final basePath = await FileStorage.getBasePath();
                      List<String> segments = basePath.split('/');
                      List<String> desiredSegments = segments.sublist(4);
                      String extractedPath = "/${desiredSegments.join('/')}";

                      if (context.mounted) {
                      Navigator.push(
                          context,
                          CustomRoute(
                              builder: (_) => Dialog(child:
                              Container(
                                  padding: const EdgeInsets.only(left: 15, right: 15, top: 30, bottom: 30), child:
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children:[
                                      Text("Where is my data located?", style: Theme.of(context).textTheme.bodyLarge),
                                      Divider(color: AppColors.grey),
                                      const SizedBox(height: 10),
                                      Text("Your data is stored on your device. You can access it by going to the file explorer and navigating to the GreenLens folder:", style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.baseBlack)),
                                      const SizedBox(height: 8),
                                      GestureDetector(
                                        onTap: () async {
                                          const MethodChannel channel = MethodChannel('com.example.tree/sys');
                                          try {
                                            await channel.invokeMethod('open_file_explorer', <String, dynamic>{
                                              'path': basePath,
                                            });
                                          } on PlatformException catch (e) {
                                            print(e);
                                          }
                                        },
                                        child: Text(extractedPath, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.primaryGreen, decoration: TextDecoration.underline)
                                      ),
                                      ),
                                    ]
                              )))));}
                    },
                    child:
                  ListTile(
                    leading: Icon(Icons.help_outline, color: AppColors.grey),
                    title: Text("Common Questions"),
                  )),
              // ListTile(
              //   leading: Icon(Icons.switch_account, color: AppColors.grey),
              //   title: Text("Switch Account"),
              // ),
              //     ListTile(
              //       leading: Icon(Icons.dark_mode, color: AppColors.grey),
              //       title: Text("Mode"),
              //     ),
              //     ListTile(
              //       leading: Icon(Icons.settings, color: AppColors.grey),
              //       title: Text("Settings"),
              //     ),
              //     ListTile(
              //       leading: Icon(Icons.help, color: AppColors.grey),
              //       title: Text("Help"),
              //     ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

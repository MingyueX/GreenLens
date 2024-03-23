import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:GreenLens/base/widgets/confirm_button.dart';
import 'package:GreenLens/screens/main_pages/profile_page/farmer_provider.dart';
import 'package:GreenLens/screens/page_navigation/page_navigation.dart';
import 'package:GreenLens/services/storage/db_service.dart';
import 'package:GreenLens/theme/colors.dart';
import 'package:GreenLens/theme/themes.dart';

import '../../base/widgets/gradient_bg.dart';
import '../../model/models.dart';
import '../main_pages/plot_page/plot_page_viewmodel.dart';

class ProfileCollectPage extends StatefulWidget {
  const ProfileCollectPage({Key? key}) : super(key: key);

  @override
  State<ProfileCollectPage> createState() => _ProfileCollectPageState();
}

class _ProfileCollectPageState extends State<ProfileCollectPage> {
  static const double spaceBetween = 8;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GradientBg(
            child: Center(
                child: SingleChildScrollView(
          child: Container(
              padding: const EdgeInsets.all(25),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/farmer_page.png",
                      height: 240,
                      fit: BoxFit.fitHeight,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: spaceBetween),
                        Text("Welcome to",
                            style: Theme.of(context).textTheme.headlineLarge),
                        const SizedBox(height: spaceBetween),
                        Text("GreenLens",
                            style: Theme.of(context).textTheme.greenTitle),
                        const SizedBox(height: spaceBetween),
                        Text("Please complete personal profile to continue",
                            style: Theme.of(context).textTheme.bodySmall),
                        PlatformTextFormField(
                          controller: _firstNameController,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          showCursor: true,
                          textAlign: TextAlign.start,
                          material: (_, __) => MaterialTextFormFieldData(
                            decoration: InputDecoration(
                              labelText: "First Name",
                              errorStyle: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(color: AppColors.alertRed),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter First Name';
                              }
                              return null;
                            },
                          ),
                        ),
                        PlatformTextFormField(
                          controller: _lastNameController,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          textAlign: TextAlign.start,
                          material: (_, __) => MaterialTextFormFieldData(
                            decoration: const InputDecoration(
                              labelText: "Last Name",
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Last Name';
                              }
                              return null;
                            },
                          ),
                        ),
                        PlatformTextFormField(
                          controller: _idController,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.start,
                          material: (_, __) => MaterialTextFormFieldData(
                            decoration: const InputDecoration(
                              labelText: "Participant ID",
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your ID';
                              }
                              return null;
                            },
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: spaceBetween),
                    ConfirmButton(
                      buttonPrompt: "CONTINUE",
                      onPressed: () async {
                        if (_formKey.currentContext != null &&
                            _formKey.currentState!.validate()) {
                          final Farmer farmer = Farmer(
                              participantId: int.parse(_idController.text),
                              name:
                                  "${_firstNameController.text} ${_lastNameController.text}");
                          await Provider.of<FarmerProvider>(context,
                                  listen: false)
                              .setFarmer(farmer);
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setInt("lastFarmer", farmer.participantId);
                          final dbService = DatabaseService();
                          final existFarmer = await dbService.searchFarmer(farmer.participantId);
                          print(existFarmer);
                          if (existFarmer != null) {
                            WidgetsBinding.instance.addPostFrameCallback((_) async {
                              if (context.mounted) {
                                await context
                                    .read<PlotPageViewModel>()
                                    .setFarmer(existFarmer.participantId);
                              }
                            });
                          } else {
                            await dbService.insertFarmer(farmer);
                          }
                          if (context.mounted) {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const TabbedPage()));
                          }
                        }
                      },
                    )
                  ],
                ),
              )),
        ))));
  }
}

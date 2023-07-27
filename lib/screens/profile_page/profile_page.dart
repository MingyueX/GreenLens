import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:tree/base/widgets/confirm_button.dart';
import 'package:tree/screens/set_up_page/set_up_page.dart';
import 'package:tree/theme/themes.dart';

import '../../base/widgets/gradient_bg.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  static const double spaceBetween = 8;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GradientBg(
            child: Center(
                child: SingleChildScrollView(
      child: Container(
          padding: const EdgeInsets.all(25),
          child: Form(
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
                      showCursor: true,
                      textAlign: TextAlign.start,
                      material: (_, __) => MaterialTextFormFieldData(
                        decoration: const InputDecoration(
                          labelText: "First Name",
                        ),
                      ),
                    ),
                    PlatformTextFormField(
                      textAlign: TextAlign.start,
                      material: (_, __) => MaterialTextFormFieldData(
                        decoration: const InputDecoration(
                          labelText: "Last Name",
                        ),
                      ),
                    ),
                    PlatformTextFormField(
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.start,
                      material: (_, __) => MaterialTextFormFieldData(
                        decoration: const InputDecoration(
                          labelText: "Participant ID",
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: spaceBetween),
                ConfirmButton(
                  buttonPrompt: "CONTINUE",
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const SetUpPage()));
                  },
                )
              ],
            ),
          )),
    ))));
  }
}

import 'dart:io';
import 'dart:typed_data';
import 'package:GreenLens/screens/main_pages/tree_page/species_result_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../base/widgets/confirm_button.dart';
import '../../base/widgets/plain_button.dart';
import '../../model/models.dart';
import '../../services/cloud/cloud_storage.dart';
import '../main_pages/profile_page/farmer_provider.dart';
import 'camera_page.dart';

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  DisplayPictureScreen({Key? key, required this.imagePath}) : super(key: key);

  final CloudStorage cloudStorage = CloudStorage();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.file(File(imagePath)),
          ),
          SizedBox(height: 20),
          ConfirmButton(
            buttonPrompt: "Save",
            onPressed: () async {
              try {
                Uint8List imageBytes = await File(imagePath).readAsBytes();
                String fileName = await CloudStorage.getFileName();
                Farmer? currentUser;
                if (context.mounted) {
                  currentUser = Provider
                      .of<FarmerProvider>(context, listen: false)
                      .farmer;
                }
                String path = "image/${currentUser == null ? "unknown" : "#${currentUser.participantId}_${currentUser.name}/"}species_identify/";
                String result = await cloudStorage.uploadImage(imageBytes, fileName, path);
                if (result.isNotEmpty && context.mounted) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Provider.of<SpeciesResultProvider>(context, listen: false).speciesName = "Unknown";
                    Provider.of<SpeciesResultProvider>(context, listen: false).imageUrl = result;

                    print("Upload successful: $result");
                  });
                  Navigator.of(context).pop();
                }
              } catch (e) {
                print(e);
              }
            },
          ),
          SizedBox(height: 10),
          PlainButton(
            buttonPrompt: "Cancel",
            onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => TakePictureScreen())),
          ),
        ],
      ),
    );
  }
}

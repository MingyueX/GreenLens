import 'dart:io';
import 'dart:typed_data';
import 'package:GreenLens/screens/main_pages/tree_page/species_result_provider.dart';
import 'package:GreenLens/services/storage/db_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../base/widgets/confirm_button.dart';
import '../../base/widgets/plain_button.dart';
import 'camera_page.dart';

class DisplayPictureScreen extends StatelessWidget {
  final Function(String) onImgSaved;
  final String imagePath;

  DisplayPictureScreen({Key? key, required this.imagePath, required this.onImgSaved}) : super(key: key);

  final DatabaseService dbService = DatabaseService();

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
                if (context.mounted) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Provider
                        .of<SpeciesResultProvider>(context, listen: false)
                        .speciesImage = imageBytes;
                  });
                  onImgSaved("Unknown");
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
                builder: (context) => TakePictureScreen(onImgSaved: onImgSaved,))),
          ),
        ],
      ),
    );
  }
}

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:ar_flutter_plugin/models/depth_img_array.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

enum FileType {
  groundTruth,
  rgb,
  depthImgData,
  elevation,
  rawDepthData,
  estDiameter,
  confidenceImgData;

  String get suffix {
    switch (this) {
      case FileType.rgb:
        return '.jpg';
      case FileType.depthImgData:
        return '';
      case FileType.elevation:
        return '.txt';
      case FileType.rawDepthData:
        return '';
      case FileType.confidenceImgData:
        return '';
      case FileType.groundTruth:
        return '.txt';
      case FileType.estDiameter:
        return '.txt';
      default:
        return '';
    }
  }
}

class FileStorage {
  static Future<String> getBasePath() async {
    try {
      final directory = await getExternalStorageDirectory();
      // final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory?.path}/GreenLens';
      return filePath;
    } catch (e) {
      throw Exception(e);
    }
  }

  // construct folder name
  // e.g. Tree#1_Captured_2023-07-01_12:00:00
  static Future<String> getFolderPath(int? treeId) async {
    final now = DateTime.now();
    String date = DateFormat('yyyy-MM-dd').format(now);
    String time = DateFormat.Hms().format(now).replaceAll(':', '');
    final folderName = 'Tree#${treeId ?? "Unknown"}_Captured_${date}_$time';
    final basePath = await getBasePath();
    return '$basePath/$folderName';
  }

  static String getFileName(FileType fileType) {
    final fileName = '${fileType.name}${fileType.suffix}';
    return fileName;
  }

  static Future<void> saveFile(String content, String targetPath) async {
    final file = File(targetPath);
    await file.parent.create(recursive: true);
    await file.writeAsString(content);
  }

  static Future<void> saveDepthImgDataToFile(
      int? treeId, DepthImgArrays? arrays, String targetPath) async {
    if (arrays == null) {
      return;
    }
    final buffer = StringBuffer();
    for (int i = 0; i < arrays.length; i++) {
      buffer.write('${arrays.xBuffer[i]},');
      buffer.write('${arrays.yBuffer[i]},');
      buffer.write('${arrays.dBuffer[i]},');
      buffer.write('${arrays.percentageBuffer[i]}\n');
    }

    await saveFile(buffer.toString(), targetPath);
  }

  static Future<void> saveToFileRGB(
      int? treeId, Uint8List image, String targetPath) async {
    final file = File(targetPath);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(image);
  }

  static Future<void> saveToFileElevation(
      int? treeId, double elevation, String targetPath) async {
    final content = '$elevation\n';

    await saveFile(content, targetPath);
  }

  static Future<void> saveToFileEstDiameter(
      int? treeId, double estDiameter, String targetPath) async {
    final content = '$estDiameter\n';

    await saveFile(content, targetPath);
  }

  static Future<void> saveToFileGroundTruth(
      int? treeId, String groundTruth, String targetPath) async {
    final content = '$groundTruth\n';

    await saveFile(content, targetPath);
  }

  static Future<void> saveToFileResults({
    int? treeId,
    // required double elevation,
    required double estDiameter,
    required Uint8List image,
    required DepthImgArrays arrays,
    required DepthImgArrays? rawDepthArrays,
    required DepthImgArrays? confidenceArrays,
    // required String groundTruth,
  }) async {
    final filePath = await getFolderPath(treeId);
    final targetPathRGB = '$filePath/${getFileName(FileType.rgb)}';
    final targetPathElevation = '$filePath/${getFileName(FileType.elevation)}';
    final targetPathDepthImgData =
        '$filePath/${getFileName(FileType.depthImgData)}';
    final targetPathRawDepthData =
        '$filePath/${getFileName(FileType.rawDepthData)}';
    final targetPathConfidenceImgData =
        '$filePath/${getFileName(FileType.confidenceImgData)}';
    final targetPathEstDiameter =
        '$filePath/${getFileName(FileType.estDiameter)}';
    // final targetPathGroundTruth =
        '$filePath/${getFileName(FileType.groundTruth)}';

    await saveToFileRGB(treeId, image, targetPathRGB);
    // await saveToFileElevation(treeId, elevation, targetPathElevation);
    await saveToFileEstDiameter(treeId, estDiameter, targetPathEstDiameter);
    await saveDepthImgDataToFile(treeId, arrays, targetPathDepthImgData);
    await saveDepthImgDataToFile(
        treeId, rawDepthArrays, targetPathRawDepthData);
    await saveDepthImgDataToFile(
        treeId, confidenceArrays, targetPathConfidenceImgData);
    // await saveToFileGroundTruth(treeId, groundTruth, targetPathGroundTruth);
  }

  static Future<void> deleteFile(String path) async {
    final file = File(path);
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  static Future<void> deleteDirectory(String path) async {
    final directory = Directory(path);
    try {
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    } catch (e) {
      print('Error deleting directory: $e');
    }
  }
}

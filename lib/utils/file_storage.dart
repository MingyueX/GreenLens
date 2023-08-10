import 'dart:async';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

enum FileType {
  jpeg,
  depthImgData,
  result;

  String get suffix {
    switch (this) {
      case FileType.jpeg:
        return '.jpg';
      case FileType.depthImgData:
        return '';
      case FileType.result:
        return '.txt';
      default:
        return '';
    }
  }
}

class FileStorage {
  Future<String> getPath() async {
    try {
    final directory = await getExternalStorageDirectory();
      final filePath = '${directory!.path}/Tree';
      return filePath;
    } catch (e) {
      throw Exception(e);
    }
  }

  // construct file name
  // e.g. Tree#1_Captured_2023-07-01_12:00:00.jpg
  String getFileName(FileType fileType, int treeId) {
    final now = DateTime.now();
    String date = DateFormat('yyyy-MM-dd').format(now);
    String time = DateFormat.Hms().format(now);
    final fileName = 'Tree#${treeId}_Captured_${date}_$time${fileType.suffix}';
    return fileName;
  }

  Future<void> saveFile(String content, String targetPath) async {
    final file = File(targetPath);
    await file.writeAsString(content);
  }
}
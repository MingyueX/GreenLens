import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'package:intl/intl.dart';

class CloudStorage {
  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<String> uploadFile(String path, String fileName) async {
    File file = File(fileName);
    final ref = storage.ref().child(path).child(fileName);
    try {
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      print(e);
      return '';
    }
  }

  Future<String> uploadImage(Uint8List image, String fileName, String path) async {
    final ref = storage.ref().child(path).child(fileName);
    try {
      await ref.putData(image);
      return await ref.getDownloadURL();
    } catch (e) {
      print(e);
      return '';
    }
  }

  Future<void> deleteFile(String path, String fileName) async {
    try {
      await storage.ref().child(path).child(fileName).delete();
    } catch (e) {
      print(e);
    }
  }

  static Future<String> getFileName() async {
    final now = DateTime.now();
    String date = DateFormat('yyyy-MM-dd').format(now);
    String time = DateFormat.Hms().format(now).replaceAll(':', '');
    final fileName = '${date}_$time.jpg';
    return fileName;
  }
}
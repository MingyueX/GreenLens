import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'json_serialize.dart';

/// Class performing the entire CSV generation process.
class DriftSQLToCSV {
  PermissionStatus _permissionStatus = PermissionStatus.denied;

  /// Checks the file write permission status of the app.
  PermissionStatus get permissionStatus => _permissionStatus;

  /// Checks if the user has granted the app permission to write to storage.
  bool get hasFileWritePermission =>
      _permissionStatus == PermissionStatus.granted;

  /// Constructor of the MoorSQLToCSV class that gets the entire process started.
  DriftSQLToCSV() {
    // Ask for permission to write to storage
    getPermission();
  }

  /// Simple dart helper function to generate a String [out], which is the body
  /// of the generated CSV file.
  String _generateCSVBody(List<DataClass> table) {
    // Set up Custom Json Serializer that can handle Dates as-is.
    final CustomJsonSerializer _serializer = const CustomJsonSerializer();
    final Map<String, dynamic> _template = table[0].toJson(
      serializer: _serializer,
    );

    String out = '';
    // Create headings
    _template.forEach((key, _) => out += '\"$key\",');
    out = out.replaceRange(out.length, out.length, '\n');

    // Set Values
    table.forEach((row) {
      final Map<String, dynamic> _template = row.toJson(
        serializer: _serializer,
      );
      _template.forEach((_, value) => out += '\"$value\",');
      out = out.replaceRange(out.length, out.length, '\n');
    });
    return out;
  }

  /// Gets Permission in Android and IOS devices.
  ///
  /// Not required for Desktop. Directly saves to Downloads folder.
  Future<PermissionStatus> getPermission() async {
    // Don't need permission for desktop devices
    if (!Platform.isIOS && !Platform.isAndroid) {
      return _permissionStatus = PermissionStatus.granted;
    }
    return _permissionStatus;
  }

  /// Gets path to permitted file writing directories depending on the OS using
  /// path_provider package.
  Future<String> get _localPath async {
    Directory? directory;
    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    } else if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      directory = await getDownloadsDirectory();
    } else {
      directory = await getTemporaryDirectory();
    }
    return directory?.path ?? '';
  }

  /// Generates the File pointer [thisFile] where the CSV body will then be
  /// written into.
  Future<File> _localFile(
      String fileName, {
        String? overrideFilePath,
        String initialContent = '',
      }) async {
    final String path = overrideFilePath ?? await _localPath;
    final String _pathToFile = '$path/$fileName.csv';
    final File thisFile = File(_pathToFile);

    // Try getting permission again if not already given.
    if (!hasFileWritePermission) {
      await getPermission();
    }

    // If file doesn't exist, create it.
    if (!(await thisFile.exists())) {
      thisFile.writeAsString(initialContent);
    }
    return thisFile;
  }

  /// Final writing is done by this member.
  ///
  /// Pass [table] is a List<DataClass> that the utility iterates over, to
  /// generate CSV.
  ///
  /// [csvFileName] is the file name that generated CSV is to be stored as
  ///
  /// [overrideFilePath] is the path to the directory where the CSV is to be stored. If not provided, the default path is used based on Platform
  ///
  /// Returns a [Future<File>] that can be used to perform further operations on the generated CSV file.
  Future<File> writeToCSV(
      List<DataClass> table, {
        String csvFileName = 'table',
        String? overrideFilePath,
      }) async {
    // Generate the body of the CSV from the passed List<DataClass> _table
    final String csvBody = _generateCSVBody(table);

    // Write the file
    final File? thisFile = await _localFile(
      csvFileName,
      overrideFilePath: overrideFilePath,
    );

    // Generate File pointer.
    // Occurs when file name is not proper
    if (thisFile == null) {
      throw PlatformException(
        code: '404',
        message: 'File Save path not found',
      );
    }

    // If permission is not given, try getting it again.
    if (!hasFileWritePermission) {
      await getPermission();
    }

    // If permission is still not given, throw error.
    if (!hasFileWritePermission) {
      throw new PlatformException(
        code: '401',
        message: 'Permission not granted',
      );
    }

    return await thisFile.writeAsString(csvBody);
  }
}

/// MoorSQLToCSV class extending DriftSQLToCSV for backwards compatibility
class MoorSQLToCSV extends DriftSQLToCSV {
  MoorSQLToCSV() : super();
}
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

Future<Directory?> calculateExternalStoragePicturesDirectory() async {
  List<Directory>? externalStorageDirectories =
      await getExternalStorageDirectories(type: StorageDirectory.pictures);
  if (externalStorageDirectories != null) {
    Directory? externalStorageDirectory = null;
    for (Directory dir in externalStorageDirectories) {
      if (!dir.path.startsWith("/storage/emulated")) {
        externalStorageDirectory = dir;
        break;
      }
    }
    if (externalStorageDirectory != null) {
      int pos = externalStorageDirectory.path.indexOf("/Android");
      if (pos != -1) {
        String externalStorageDirectoryRoot =
            externalStorageDirectory.path.substring(0, pos);
        Directory? externalStoragePicturesDirectory =
            Directory(externalStorageDirectoryRoot + "/Pictures");
        if (externalStoragePicturesDirectory.existsSync()) {
          return externalStoragePicturesDirectory;
        }
      }
    }
    return null;
  }
}

List<String> calculateSuppliersFromExternalStoragePicturesDirectory(
    Directory? externalStoragePicturesDirectory) {
  List<String> suppliers = [];
  if (externalStoragePicturesDirectory != null) {
    List<FileSystemEntity> fseList =
        externalStoragePicturesDirectory.listSync(recursive: false);
    for (FileSystemEntity fse in fseList) {
      if (!fse.path.contains("thumbnails")) {
        suppliers.add(calculateNameFromPath(fse.path));
      }
    }
  }
  suppliers.sort();
  return suppliers;
}

String calculateNameFromPath(String path) {
  int lastIndexOf = path.lastIndexOf("/");
  if (lastIndexOf != -1) {
    return path.substring(lastIndexOf + 1);
  } else {
    return path;
  }
}

String calculateFileExtensionFromPath(String path) {
  int lastIndexOf = path.lastIndexOf(".");
  if (lastIndexOf != -1) {
    return path.substring(lastIndexOf + 1);
  } else {
    return path;
  }
}

String calculateGridName(String path) {
  int lastIndexOf = path.lastIndexOf("_");
  String nameIncludingSuffix;
  if (lastIndexOf != -1) {
    nameIncludingSuffix = path.substring(lastIndexOf + 1);
  } else {
    nameIncludingSuffix = path;
  }
  lastIndexOf = nameIncludingSuffix.lastIndexOf(".");
  return nameIncludingSuffix.substring(0, lastIndexOf - 1);
}

showExternalStorageMessage(BuildContext context) {
  showMessage(context, "external storage directory cannot be calculated");
}

showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

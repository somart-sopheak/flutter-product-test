  import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

SnackBar snackSaveOpen(String fileType, String fileName, String path) {
    return SnackBar(
    content: Text(
      '$fileType saved to Downloads/$fileName',
      style: const TextStyle(color: Colors.white),
    ),
    duration: const Duration(seconds: 5),
    backgroundColor: Colors.blue,
    action: SnackBarAction(
      backgroundColor: Colors.white,
      label: 'OPEN',
      textColor: const Color.fromARGB(255, 56, 12, 176),
      onPressed: () {
        OpenFilex.open(path);
      },
    ),
  );
  }
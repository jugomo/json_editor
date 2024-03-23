import 'dart:convert';
import 'dart:io';

import 'package:file_selector/file_selector.dart';

Future<void> saveData({
  required List<Map> jsonFiles,
  required List<XFile> files,
}) async {
  for (var (index, element) in jsonFiles.indexed) {
    var tosave = const JsonEncoder.withIndent("    ").convert(element);
    File file = File("${files[index].path}.1.json");
    await file.writeAsString(tosave);
  }
}

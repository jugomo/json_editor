// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:html' as webfile;

import 'package:file_selector/file_selector.dart';

Future<void> saveData({
  required List<Map> jsonFiles,
  required List<XFile> files,
}) async {
  for (var (index, element) in jsonFiles.indexed) {
    var tosave = const JsonEncoder.withIndent("    ").convert(element);
    var blob1 = webfile.Blob([tosave], "text/plain", "native");
    webfile.AnchorElement(
      href: webfile.Url.createObjectUrlFromBlob(blob1).toString(),
    )
      ..setAttribute("download", files[index].name)
      ..click();
  }
}

// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:html' as webfile;

import 'package:file_selector/file_selector.dart';

Future<void> saveData({
  required Map json1,
  required Map json2,
  required Map json3,
  required XFile file1,
  required XFile file2,
  required XFile file3,
}) async {
  var tosave1 = const JsonEncoder.withIndent("    ").convert(json1);
  var tosave2 = const JsonEncoder.withIndent("    ").convert(json2);
  var tosave3 = const JsonEncoder.withIndent("    ").convert(json3);

  /* ONLY WEB */

  //
  var blob1 = webfile.Blob([tosave1], "text/plain", "native");
  webfile.AnchorElement(
    href: webfile.Url.createObjectUrlFromBlob(blob1).toString(),
  )
    ..setAttribute("download", "${file1.name}.1.json")
    ..click();

  //
  var blob2 = webfile.Blob([tosave2], "text/plain", "native");
  webfile.AnchorElement(
    href: webfile.Url.createObjectUrlFromBlob(blob2).toString(),
  )
    ..setAttribute("download", "${file2.name}.1.json")
    ..click();

  //
  var blob3 = webfile.Blob([tosave3], "text/plain", "native");
  webfile.AnchorElement(
    href: webfile.Url.createObjectUrlFromBlob(blob3).toString(),
  )
    ..setAttribute("download", "${file3.name}.1.json")
    ..click();
}

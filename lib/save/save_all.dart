import 'dart:convert';
import 'dart:io';

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

  /* OTHER PLATFORMS */

  //
  //File file1 = File("${files![0].path}.1.json");
  File f1 = File("${file1.path}.1.json");
  await f1.writeAsString(tosave1);

  //
  // File file2 = File("${files![1].path}.1.json");
  File f2 = File("${file2.path}.1.json");
  await f2.writeAsString(tosave2);

  //
  // File file3 = File("${files![2].path}.1.json");
  File f3 = File("${file3.path}.1.json");
  await f3.writeAsString(tosave3);
}

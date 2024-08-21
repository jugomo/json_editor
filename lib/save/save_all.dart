import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

Future<void> saveData({
  required List<Map> jsonFiles,
  required List<XFile> files,
}) async {
  for (var (index, element) in jsonFiles.indexed) {
    XFile file = files[index];
    String name = file.path
        .substring(file.path.lastIndexOf('/') + 1, file.path.lastIndexOf('.'));
    name = "$name-1.json";
    var tosave = const JsonEncoder.withIndent("    ").convert(element);
    Uint8List bytes = Uint8List.fromList(utf8.encode(tosave));

    String? result = await FilePicker.platform.saveFile(
      dialogTitle: "hola",
      fileName: name,
      bytes: bytes,
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    print("RESULT: $result");

    // ------------------------------------------
    // String selectedFilePath = file.path;
    // File fileReplace = File(selectedFilePath);
    // await fileReplace.writeAsBytes(bytes);
    // print('File replaced successfully!');
    // ------------------------------------------
  }
}

// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'dart:html' as webfile;

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'json_editor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        scrollbarTheme: const ScrollbarThemeData().copyWith(
          thumbVisibility: MaterialStateProperty.all<bool>(true),
          thumbColor: MaterialStateProperty.all(Colors.blue.shade700),
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController tecKey = TextEditingController();
  TextEditingController tecV1 = TextEditingController();
  TextEditingController tecV2 = TextEditingController();
  TextEditingController tecV3 = TextEditingController();
  TextEditingController tecSearch = TextEditingController();

  ScrollController scrollController = ScrollController();

  final XTypeGroup typeGroup =
      const XTypeGroup(label: 'json-files', extensions: <String>['json']);
  List<XFile>? files;
  bool addingNew = false;
  bool isEdited = false;
  bool searching = false;
  bool darkMode = true;
  String searchStr = "---**";

  int? checkedIndex;
  String? filename1;
  String? filename2;
  String? filename3;
  Map? json1;
  Map? json2;
  Map? json3;
  Map? childs1;
  Map? childs2;
  Map? childs3;

  //
  //

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    tecKey.text =
        checkedIndex != null ? json1!.keys.elementAt(checkedIndex!) : "";

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue.shade700,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: darkMode,
                    onChanged: (value) {
                      setState(() {
                        darkMode = !darkMode;
                      });
                    },
                  ),
                  const Text("darkmode"),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  const Text("THB jotason editor"),
                  if (isEdited) const Text("  (*)"),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
        floatingActionButton: Transform.translate(
          offset: const Offset(0, 9),
          child: SizedBox(
            width: 600,
            child: _mainActions(),
          ),
        ),
        backgroundColor: darkMode ? Colors.black87 : Colors.white,
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /* CONTENT OF FILES */
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: json1?.length ?? 0,
                  itemBuilder: (context, index) {
                    var mainKey = json1!.keys.elementAt(index);
                    childs1 = json1?[mainKey];
                    childs2 = json2?[mainKey];
                    childs3 = json3?[mainKey];
                    var childCount = childs1?.length ?? 0;

                    return Container(
                      padding: const EdgeInsets.only(bottom: 20, right: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          /* HEADER OF THE GROUP */
                          Container(
                            color: Colors.grey,
                            padding: const EdgeInsets.all(3),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: checkedIndex == index,
                                        onChanged: (value) {
                                          setState(() {
                                            checkedIndex =
                                                (value!) ? index : null;
                                            addingNew = value;
                                          });
                                        },
                                      ),
                                      Text('${index + 1}'),
                                      const SizedBox(width: 20),
                                      Text('$mainKey'),
                                    ],
                                  ),
                                ),
                                Container(width: 5),
                                Expanded(
                                    child: Text('$filename1',
                                        textAlign: TextAlign.center)),
                                Container(width: 5),
                                Expanded(
                                    child: Text('$filename2',
                                        textAlign: TextAlign.center)),
                                Container(width: 5),
                                Expanded(
                                    child: Text('$filename3',
                                        textAlign: TextAlign.center)),
                              ],
                            ),
                          ),

                          /* CONTENT OF THE GROUP */
                          SizedBox(
                            height: childCount * 40 + childCount * 2.5 * 2,
                            child: ListView.builder(
                              itemCount: childCount,
                              itemBuilder: (context, index) {
                                String key = childs1!.keys.elementAt(index);
                                var str1 = '-';
                                var str2 = '-';
                                var str3 = '-';
                                try {
                                  str1 = childs1?[key];
                                  str2 = childs2?[key];
                                  str3 = childs3?[key];
                                } catch (_) {}

                                return InkWell(
                                  onTap: () {
                                    _editItem(
                                        ctx: context,
                                        mainkey: mainKey,
                                        selectedkey: key);
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 2.5),
                                    color: searching &&
                                            (key.toUpperCase().contains(
                                                    searchStr.toUpperCase()) ||
                                                str1.toUpperCase().contains(
                                                    searchStr.toUpperCase()) ||
                                                str2.toUpperCase().contains(
                                                    searchStr.toUpperCase()) ||
                                                str3.toUpperCase().contains(
                                                    searchStr.toUpperCase()))
                                        ? Colors.red
                                        : darkMode
                                            ? Colors.grey.shade500
                                            : Colors.grey.shade400,
                                    height: 40,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            key,
                                            style: const TextStyle(
                                              fontStyle: FontStyle.italic,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Container(
                                            color: darkMode
                                                ? Colors.black
                                                : Colors.white,
                                            width: 5),
                                        Expanded(
                                            child: Text(
                                          str1,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        )),
                                        Container(
                                            color: darkMode
                                                ? Colors.black
                                                : Colors.white,
                                            width: 5),
                                        Expanded(
                                            child: Text(
                                          str2,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        )),
                                        Container(
                                            color: darkMode
                                                ? Colors.black
                                                : Colors.white,
                                            width: 5),
                                        Expanded(
                                            child: Text(
                                          str3,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        )),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            /* BOTTOM ROW TO ADD NEW ENTRY */
            if (json1 != null && addingNew) _rowAddNewItem(),
          ],
        ));
  }

  Widget _mainActions() {
    return Row(children: [
      ElevatedButton(
        onPressed: files == null
            ? () async {
                files = await openFiles(
                    confirmButtonText: "abrir todos",
                    acceptedTypeGroups: <XTypeGroup>[typeGroup]);

                await loadData();
                setState(() {});
              }
            : null,
        child: const Text('open'),
      ),
      const SizedBox(width: 10),
      ElevatedButton(
        onPressed: isEdited
            ? () async {
                saveData();
              }
            : null,
        child: const Text('save', style: TextStyle(color: Colors.orange)),
      ),
      const SizedBox(width: 10),
      ElevatedButton(
        onPressed: files != null
            ? () async {
                setState(() {
                  addingNew = !addingNew;
                });
              }
            : null,
        child: const Text('new key', style: TextStyle(color: Colors.green)),
      ),
      const SizedBox(width: 10),
      ElevatedButton(
        onPressed: files != null
            ? () async {
                setState(() {
                  files = null;
                  checkedIndex = null;
                  filename1 = null;
                  filename2 = null;
                  filename3 = null;
                  json1 = null;
                  json2 = null;
                  json3 = null;
                  childs1 = null;
                  childs2 = null;
                  childs3 = null;
                });
              }
            : null,
        child: const Text('reset', style: TextStyle(color: Colors.red)),
      ),
      const SizedBox(width: 10),
      ElevatedButton(
        onPressed: files != null
            ? () async {
                setState(() {
                  searching = !searching;
                  if (!searching) {
                    tecSearch.text = "";
                    searchStr = "---**";
                  }
                });
              }
            : null,
        child: const Text('search', style: TextStyle(color: Colors.blue)),
      ),
      const SizedBox(width: 10),
      if (searching)
        Container(
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          width: 180,
          height: 40,
          padding: const EdgeInsets.all(5),
          child: TextField(
            controller: tecSearch,
            onChanged: (value) {
              setState(() {
                searchStr = value;
                if (value == "") {
                  searchStr = "---**";
                }
                print(value);
              });
            },
          ),
        ),
    ]);
  }

  Widget _rowAddNewItem() {
    tecV1.text = "";
    tecV2.text = "";
    tecV3.text = "";

    return Container(
      color: Colors.green.shade300,
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      height: 100,
      child: Row(
        children: [
          const Text("key:"),
          SizedBox(
            width: 100,
            child: TextField(
              maxLines: 1,
              controller: tecKey,
              // onChanged: (value) {
              //   print("changed: $value");
              //   if (!value.isEmpty) {
              //     setState(() {});
              //   }
              // },
              enabled: checkedIndex == null,
              textAlign: TextAlign.center,
              textAlignVertical: TextAlignVertical.center,
              autocorrect: false,
              style: TextStyle(
                  fontStyle: checkedIndex != null ? FontStyle.italic : null,
                  fontWeight: checkedIndex != null
                      ? FontWeight.bold
                      : FontWeight.normal),
            ),
          ),
          const SizedBox(width: 20),
          const Text("values:"),
          Row(
            children: [
              SizedBox(
                width: 100,
                height: double.infinity,
                child: TextField(
                  decoration: InputDecoration.collapsed(
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(width: 1),
                    ),
                    hintText: filename1,
                    hintStyle: const TextStyle(fontSize: 12),
                  ).copyWith(
                    contentPadding: const EdgeInsets.all(5),
                  ),
                  maxLines: 10,
                  controller: tecV1,
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 100,
                height: double.infinity,
                child: TextField(
                  decoration: InputDecoration.collapsed(
                    border: const OutlineInputBorder(
                        borderSide: BorderSide(width: 1)),
                    hintText: filename2,
                    hintStyle: const TextStyle(fontSize: 12),
                  ).copyWith(
                    contentPadding: const EdgeInsets.all(5),
                  ),
                  maxLines: 10,
                  controller: tecV2,
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 100,
                height: double.infinity,
                child: TextField(
                  decoration: InputDecoration.collapsed(
                    border: const OutlineInputBorder(
                        borderSide: BorderSide(width: 1)),
                    hintText: filename3,
                    hintStyle: const TextStyle(fontSize: 12),
                  ).copyWith(
                    contentPadding: const EdgeInsets.all(5),
                  ),
                  maxLines: 10,
                  controller: tecV3,
                ),
              ),
              const SizedBox(width: 50),
              SizedBox(
                width: 100,
                child: ElevatedButton(
                  onPressed: checkedIndex != null || tecKey.text != ""
                      ? () async {
                          print("TODO insert in the checked group");
                        }
                      : null,
                  child: const Text('Add'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _editItem(
      {required BuildContext ctx,
      required String mainkey,
      required String selectedkey}) {
    tecKey.text = selectedkey;
    tecV1.text = childs1?[selectedkey];
    tecV2.text = childs2?[selectedkey];
    tecV3.text = childs3?[selectedkey];

    showModalBottomSheet<void>(
      context: ctx,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.8,
          padding: const EdgeInsets.all(10),
          color: Colors.grey.shade300,
          child: Center(
            child: Column(
              children: [
                Text(mainkey),
                Expanded(
                  child: Row(children: [
                    const Text("key:"),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        child: TextField(
                          maxLines: 1,
                          controller: tecKey,
                          enabled: checkedIndex == null,
                          textAlign: TextAlign.center,
                          textAlignVertical: TextAlignVertical.center,
                          autocorrect: false,
                          style: TextStyle(
                              fontStyle: checkedIndex != null
                                  ? FontStyle.italic
                                  : null,
                              fontWeight: checkedIndex != null
                                  ? FontWeight.bold
                                  : FontWeight.normal),
                        ),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Row(children: [
                    Text(filename1!),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: double.infinity,
                        child: TextField(
                          decoration: InputDecoration.collapsed(
                            border: const OutlineInputBorder(
                              borderSide: BorderSide(width: 1),
                            ),
                            hintText: filename1,
                            hintStyle: const TextStyle(fontSize: 12),
                          ).copyWith(
                            contentPadding: const EdgeInsets.all(5),
                          ),
                          maxLines: 10,
                          controller: tecV1,
                        ),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Row(children: [
                    Text(filename2!),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: double.infinity,
                        child: TextField(
                          decoration: InputDecoration.collapsed(
                            border: const OutlineInputBorder(
                              borderSide: BorderSide(width: 1),
                            ),
                            hintText: filename2,
                            hintStyle: const TextStyle(fontSize: 12),
                          ).copyWith(
                            contentPadding: const EdgeInsets.all(5),
                          ),
                          maxLines: 10,
                          controller: tecV2,
                        ),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Row(children: [
                    Text(filename3!),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: double.infinity,
                        child: TextField(
                          decoration: InputDecoration.collapsed(
                            border: const OutlineInputBorder(
                              borderSide: BorderSide(width: 1),
                            ),
                            hintText: filename3,
                            hintStyle: const TextStyle(fontSize: 12),
                          ).copyWith(
                            contentPadding: const EdgeInsets.all(5),
                          ),
                          maxLines: 10,
                          controller: tecV3,
                        ),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      child: const Text('Save changes'),
                      onPressed: () {
                        Navigator.pop(context);

                        childs1?[selectedkey] = tecV1.text;
                        childs2?[selectedkey] = tecV2.text;
                        childs3?[selectedkey] = tecV3.text;

                        // print(childs1?[selectedkey]);
                        // print(childs2?[selectedkey]);
                        // print(childs3?[selectedkey]);

                        Future.delayed(const Duration(milliseconds: 500))
                            .then((value) {
                          setState(() {
                            isEdited = true;
                          });
                        });
                      },
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> saveData() async {
    var tosave1 = const JsonEncoder.withIndent("    ").convert(json1);
    var tosave2 = const JsonEncoder.withIndent("    ").convert(json2);
    var tosave3 = const JsonEncoder.withIndent("    ").convert(json3);

    if (kIsWeb) {
      /* ONLY WEB */

      //
      var blob1 = webfile.Blob([tosave1], "text/plain", "native");
      webfile.AnchorElement(
        href: webfile.Url.createObjectUrlFromBlob(blob1).toString(),
      )
        ..setAttribute("download", "$filename1.1.json")
        ..click();

      //
      var blob2 = webfile.Blob([tosave2], "text/plain", "native");
      webfile.AnchorElement(
        href: webfile.Url.createObjectUrlFromBlob(blob2).toString(),
      )
        ..setAttribute("download", "$filename2.1.json")
        ..click();

      //
      var blob3 = webfile.Blob([tosave3], "text/plain", "native");
      webfile.AnchorElement(
        href: webfile.Url.createObjectUrlFromBlob(blob3).toString(),
      )
        ..setAttribute("download", "$filename3.1.json")
        ..click();
    } else {
      /* OTHER PLATFORMS */

      //
      File file1 = File("${files![0].path}.1.json");
      await file1.writeAsString(tosave1);

      //
      File file2 = File("${files![1].path}.1.json");
      await file2.writeAsString(tosave2);

      //
      File file3 = File("${files![2].path}.1.json");
      await file3.writeAsString(tosave3);
    }
  }

  Future<void> loadData() async {
    if (files == null || files!.length != 3) {
      // TODO validate that all files contains the same main keys

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Not supported: you have to select exactly 3 json files')));
      return;
    }

    //

    filename1 = files![0].name;
    filename2 = files![1].name;
    filename3 = files![2].name;
    json1 = json.decode(await files![0].readAsString());
    json2 = json.decode(await files![1].readAsString());
    json3 = json.decode(await files![2].readAsString());

    // print("-------");
    // print(json1!.keys);
    // print(json2!.keys);
    // print(json3!.keys);
  }
}

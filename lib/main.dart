// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:json_editor/save/save.dart';

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
  TextEditingController tecSubkey = TextEditingController();
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
                saveData(
                  json1: json1!,
                  json2: json2!,
                  json3: json3!,
                  file1: files![0],
                  file2: files![1],
                  file3: files![2],
                ).then((value) {
                  setState(() {
                    isEdited = false;
                  });
                });
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
                  isEdited = false;
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
    tecSubkey.text = "";
    tecV1.text = "";
    tecV2.text = "";
    tecV3.text = "";

    return Container(
      color: Colors.green.shade300,
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      height: 450,
      child: Row(
        children: [
          /* KEYS */
          SizedBox(
            height: 120,
            width: 180,
            child: Column(
              children: [
                Row(
                  children: [
                    const Text("mainkey:"),
                    SizedBox(
                      width: 100,
                      height: 35,
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
                            fontStyle:
                                checkedIndex != null ? FontStyle.italic : null,
                            fontWeight: checkedIndex != null
                                ? FontWeight.bold
                                : FontWeight.normal),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text("subkey:"),
                    SizedBox(
                      width: 100,
                      height: 35,
                      child: TextField(
                        maxLines: 1,
                        controller: tecSubkey,
                        // onChanged: (value) {
                        //   print("changed: $value");
                        //   if (!value.isEmpty) {
                        //     setState(() {});
                        //   }
                        // },

                        textAlign: TextAlign.center,
                        textAlignVertical: TextAlignVertical.center,
                        autocorrect: false,
                        style: TextStyle(
                            fontStyle:
                                checkedIndex != null ? FontStyle.italic : null,
                            fontWeight: checkedIndex != null
                                ? FontWeight.bold
                                : FontWeight.normal),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),

          /* VALUES */
          const SizedBox(width: 100, child: Text("values:")),
          SizedBox(
            width: 300,
            height: 450,
            child: Column(
              children: [
                SizedBox(
                  width: 300,
                  height: 100,
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
                const SizedBox(height: 10),
                SizedBox(
                  width: 300,
                  height: 100,
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
                const SizedBox(height: 10),
                SizedBox(
                  width: 300,
                  height: 100,
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
              ],
            ),
          ),
          const SizedBox(width: 50),

          /* ADD BUTTON */
          SizedBox(
            width: 100,
            child: ElevatedButton(
              onPressed: () async {
                setState(() {
                  if (tecKey.text != "" && tecSubkey.text != "") {
                    if (checkedIndex != null) {
                      var subkey = tecSubkey.text;
                      checkedIndex = null;
                      childs1![subkey] = tecV1.text;
                      childs2![subkey] = tecV2.text;
                      childs3![subkey] = tecV3.text;
                      addingNew = false;
                      isEdited = true;
                    } else {
                      json1![tecKey.text] = {tecSubkey.text: tecV1.text};
                      json2![tecKey.text] = {tecSubkey.text: tecV2.text};
                      json3![tecKey.text] = {tecSubkey.text: tecV3.text};
                      addingNew = false;
                      isEdited = true;
                    }
                  } else {
                    print("TODO: show msg fill all data!");
                  }
                });
              },
              child: const Text('Add'),
            ),
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

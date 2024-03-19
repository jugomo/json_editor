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
  final maincolor = Colors.blue.shade700;

  TextEditingController tecKey = TextEditingController();
  TextEditingController tecSubkey = TextEditingController();
  TextEditingController tecSearch = TextEditingController();
  ScrollController scrollController = ScrollController();

  final XTypeGroup typeGroup =
      const XTypeGroup(label: 'json-files', extensions: <String>['json']);
  bool addingNew = false;
  bool isEdited = false;
  bool searching = false;
  bool darkMode = true;
  String searchStr = "---**";
  int? checkedIndex;

  /* following vars depend on amount of files opened */
  List<XFile>? files;
  List<TextEditingController>? tecLanguages;
  List<String>? filenames;
  List<Map>? jsonFiles;

  //
  //

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    tecKey.text =
        checkedIndex != null ? jsonFiles![0].keys.elementAt(checkedIndex!) : "";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: maincolor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MenuBar(
              style: const MenuStyle(
                  backgroundColor:
                      MaterialStatePropertyAll<Color>(Colors.transparent),
                  elevation: MaterialStatePropertyAll<double>(0),
                  shape: MaterialStatePropertyAll<ContinuousRectangleBorder>(
                      ContinuousRectangleBorder())),
              children: [_mainActions()],
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
      backgroundColor: darkMode ? Colors.black87 : Colors.white,
      body: _listView(),
    );
  }

  Widget _listView() {
    final count = files != null ? files!.length + 1 : 0;
    final width = MediaQuery.of(context).size.width / count;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        /* FILE NAMES */
        if (filenames != null)
          Container(
            width: double.infinity,
            height: 50,
            color: maincolor,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: count,
              itemExtent: width,
              itemBuilder: (context, index) {
                return Center(
                  child: index == 0
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              setState() {}
                            },
                            child: const Text('Add Language'),
                          ),
                        )
                      : Text(
                          filenames![index - 1],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                );
              },
            ),
          ),

        /* CONTENT OF FILES */
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              controller: scrollController,
              itemCount: files?.length ?? 0,
              itemBuilder: (context, index) {
                return _group(index: index);
              },
            ),
          ),
        ),

        /* BOTTOM ROW TO ADD NEW ENTRY */
        if (jsonFiles != null && addingNew) _rowAddNewItem(),
      ],
    );
  }

  Widget _group({required int index}) {
    var mainKey = jsonFiles![0].keys.elementAt(index);
    //for (int i = 0; i < files!.length; i++) {}
    List<Map>? childsFiles = [];
    childsFiles.add(jsonFiles![0][mainKey]);
    childsFiles.add(jsonFiles![1][mainKey]);
    childsFiles.add(jsonFiles![2][mainKey]);
    var childCount = childsFiles[0].length;

    return Container(
      padding: const EdgeInsets.only(bottom: 20, right: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /* HEADER OF THE GROUP */
          Container(
            color: maincolor,
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
                            checkedIndex = (value!) ? index : null;
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
              ],
            ),
          ),

          /* CONTENT OF THE GROUP */
          SizedBox(
            height: childCount * 40 + childCount * 2.5 * 2,
            child: ListView.builder(
              itemCount: childCount,
              itemBuilder: (context, index) {
                String key = childsFiles[0].keys.elementAt(index);
                var str1 = '-';
                var str2 = '-';
                var str3 = '-';
                try {
                  str1 = childsFiles[0][key];
                  str2 = childsFiles[1][key];
                  str3 = childsFiles[2][key];
                } catch (_) {}

                return InkWell(
                  onTap: () {
                    _editItem(ctx: context, mainKey: mainKey, selectedKey: key);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 2.5),
                    color: searching &&
                            (key
                                    .toUpperCase()
                                    .contains(searchStr.toUpperCase()) ||
                                str1
                                    .toUpperCase()
                                    .contains(searchStr.toUpperCase()) ||
                                str2
                                    .toUpperCase()
                                    .contains(searchStr.toUpperCase()) ||
                                str3
                                    .toUpperCase()
                                    .contains(searchStr.toUpperCase()))
                        ? Colors.red
                        : darkMode
                            ? Colors.grey.shade500
                            : Colors.grey.shade400,
                    height: 40,
                    child: Row(
                      children: [
                        /* REMOVE ENTRY BUTTON */
                        IconButton(
                          onPressed: () {
                            setState(() => _deleteItem(
                                mainKey: mainKey, selectedKey: key));
                          },
                          icon: const Icon(Icons.delete),
                        ),

                        /* STRING KEY */
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
                            color: darkMode ? Colors.black : Colors.white,
                            width: 5),
                        Expanded(
                            child: Text(
                          str1,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )),
                        Container(
                            color: darkMode ? Colors.black : Colors.white,
                            width: 5),
                        Expanded(
                            child: Text(
                          str2,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )),
                        Container(
                            color: darkMode ? Colors.black : Colors.white,
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
  }

  Widget _mainActions() {
    return Row(children: [
      /* DARKMODE */
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
      const SizedBox(width: 10),
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
                  files: files!,
                  jsonFiles: jsonFiles!,
                  // json1: json1!,
                  // json2: json2!,
                  // json3: json3!,
                  // file1: files![0],
                  // file2: files![1],
                  // file3: files![2],
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
                  tecLanguages = null;
                  isEdited = false;
                  files = null;
                  checkedIndex = null;
                  filenames = null;
                  jsonFiles = null;
                  //childsFiles = null;
                  // filename1 = null;
                  // filename2 = null;
                  // filename3 = null;
                  // json1 = null;
                  // json2 = null;
                  // json3 = null;
                  // childs1 = null;
                  // childs2 = null;
                  // childs3 = null;
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
    _clearEditTexts();
    // tecSubkey.text = "";
    // tecV1.text = "";
    // tecV2.text = "";
    // tecV3.text = "";

    return Container(
      color: Colors.grey.shade600.withOpacity(0.8),
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
// TODO **********************************************************
/*        
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
          Column(
            children: [
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
              const SizedBox(height: 50),

              /* CLOSE BUTTON */
              SizedBox(
                width: 100,
                child: ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      addingNew = false;
                      checkedIndex = null;
                    });
                  },
                  child: const Text('close'),
                ),
              ),
            ],
          )
*/
// TODO **********************************************************
        ],
      ),
    );
  }

  void _clearEditTexts() {
    tecSubkey.text = "";

    for (var element in tecLanguages ?? []) {
      element.text = "";
    }
  }

  void _editItem(
      {required BuildContext ctx,
      required String mainKey,
      required String selectedKey}) {
// TODO *********************************************************************************
/*        
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
*/
// TODO *********************************************************************************
  }

  void _deleteItem({required String mainKey, required String selectedKey}) {
    print("  deleting: $selectedKey");

    for (int i = 0; i < jsonFiles!.length; i++) {
      jsonFiles![i][mainKey].remove(selectedKey);
    }
  }

  Future<void> loadData() async {
    if (files == null || files!.isEmpty) {
      // TODO validate that all files contains the same main keys

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Not supported: you have to select at least one json file')));
      setState(() {
        files = null;
      });
      return;
    }

    //

    var fileAmount = files!.length;
    print("AMOUNT: $fileAmount");

    // initialize data
    tecLanguages = [];
    filenames = [];
    jsonFiles = [];
    for (int i = 0; i < fileAmount; i++) {
      tecLanguages!.add(TextEditingController());
      filenames!.add(files![i].name);
      jsonFiles!.add(json.decode(await files![i].readAsString()));
    }

    // check files have same structure -----------------------------------------------------
    List<List<String>> mainkeyslist = []; // main keys per file
    List<List<int>> valueamountlist = []; // amount values per mainkey
    List<int> mainkeysamount = [];
    for (int j = 0; j < fileAmount; j++) {
      mainkeyslist.add([]);
      valueamountlist.add([]);
      mainkeysamount.add(jsonFiles![j].keys.length);
      for (int k = 0; k < mainkeysamount[j]; k++) {
        List<String> valuelist = [];
        String subkey = jsonFiles![j].keys.elementAt(k);
        mainkeyslist[j].add(subkey);
        for (int va = 0; va < jsonFiles![j][subkey].length; va++) {
          var tmpk = jsonFiles![j][subkey].keys.elementAt(va);
          try {
            valuelist.add(jsonFiles![j][subkey][tmpk]);
          } catch (_) {
            valuelist.add("error");
          }
        }
        valueamountlist[j].add(valuelist.length);
      }
    }
    print("***************** CHECKING ***********************");
    //print("--> mainkeyslist: $mainkeyslist");
    //print("--> valueamountlist: $valueamountlist");
    bool todoOK = true;
    for (int keys = 0; keys < mainkeyslist[0].length; keys++) {
      String? key;
      for (int file = 0; file < mainkeyslist.length; file++) {
        todoOK = todoOK && ((key == null) || (key == mainkeyslist[file][keys]));
        key = mainkeyslist[file][keys];
        //print("--> mainkeyslist: ${mainkeyslist[file][keys]}");
      }
    }
    if (!todoOK) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Not supported: the files dont match')));
      setState(() {
        files = null;
      });
    }
    print("***************** CHECKED ************************");
    // -------------------------------------------------------------------------------------
  }
}

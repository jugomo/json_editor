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
  final dialogBgColor = Colors.grey.shade300;

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
        title: _mainActions(),
      ),
      bottomNavigationBar: Container(
        height: 40,
        color: maincolor,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("THB jotason editor"),
                if (isEdited) const Text("  (*)"),
              ],
            ),
            const Text("- v0.3.0 - ©jugomo", style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
      backgroundColor: darkMode ? Colors.black87 : Colors.white,
      body: _listView(),
    );
  }

  Widget _listView() {
    final countFilenames = files != null ? files!.length + 1 : 0;
    final countMainkeys = jsonFiles != null ? jsonFiles![0].length : 0;
    final width = MediaQuery.of(context).size.width / countFilenames;

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
              itemCount: countFilenames,
              itemExtent: width,
              itemBuilder: (context, index) {
                return Center(
                  child: index == 0
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              setState() {
// TODO - implement add language *****************
                              }
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
            padding: const EdgeInsets.all(8),
            child: ListView.builder(
              controller: scrollController,
              itemCount: countMainkeys,
              itemBuilder: (context, index) {
                return _mainKeyContent(index: index);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _mainKeyContent({required int index}) {
    var mainKey = jsonFiles![0].keys.elementAt(index);
    List<Map>? childsFiles = [];
    for (int i = 0; i < files!.length; i++) {
      childsFiles.add(jsonFiles![i][mainKey]);
    }
    var childCount = childsFiles[0].length;
    final width = MediaQuery.of(context).size.width / (childsFiles.length + 1);

    return Container(
      padding: const EdgeInsets.only(bottom: 20, right: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /* HEADER OF THE MAINKEY GROUP */
          Container(
            color: maincolor.withAlpha(200),
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

          /* CONTENT OF THE MAINKEY GROUP */
          SizedBox(
            height: childCount * 40 + childCount * 2.5 * 2,
            child: ListView.builder(
              itemCount: childCount,
              itemBuilder: (context, index) {
                String key = childsFiles[0].keys.elementAt(index);
                List<String> str = [];
                for (int i = 0; i < childsFiles.length; i++) {
                  try {
                    str.add(childsFiles[i][key]);
                  } catch (_) {}
                }

                return InkWell(
                  onTap: () {
                    _editItemDialog(
                      ctx: context,
                      index: index,
                      mainKey: mainKey,
                      selectedKey: key,
                      childsFiles: childsFiles,
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 2.5),
                    color: _getRowColor(key: key, values: str),
                    height: 40,
                    child: Row(
                      children: [
                        Container(
                          color: maincolor.withAlpha(200),
                          width: width,
                          height: double.infinity,
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
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        /* LIST FOR FILES VALUES */
                        Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: str.length,
                            itemBuilder: (context, index) {
                              return SizedBox(
                                width: width,
                                height: 40,
                                child: Row(
                                  children: [
                                    Container(
                                        color: darkMode
                                            ? Colors.black
                                            : Colors.white,
                                        width: 5),
                                    Expanded(
                                        child: Text(
                                      str[index],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    )),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          /* OPEN */
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

          /* SAVE */
          ElevatedButton(
            onPressed: isEdited
                ? () async {
                    saveData(
                      files: files!,
                      jsonFiles: jsonFiles!,
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

          /* NEW KEY */
          ElevatedButton(
            onPressed: files != null
                ? () async {
                    setState(() {
                      addingNew = !addingNew;
                      _rowAddNewItem(ctx: context);
                    });
                  }
                : null,
            child: const Text('new key', style: TextStyle(color: Colors.green)),
          ),
          const SizedBox(width: 10),

          /* RESET */
          ElevatedButton(
            onPressed: files != null
                ? () async {
                    setState(() {
                      tecLanguages = null;
                      isEdited = false;
                      searching = false;
                      tecSearch.text = "";
                      searchStr = "---**";
                      addingNew = false;
                      files = null;
                      checkedIndex = null;
                      filenames = null;
                      jsonFiles = null;
                    });
                  }
                : null,
            child: const Text('reset', style: TextStyle(color: Colors.red)),
          ),
          const SizedBox(width: 10),

          /* SEARCH */
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
                  });
                },
              ),
            ),

          /* DARKMODE */
          const SizedBox(width: 10),
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
        ],
      ),
    );
  }

  void _rowAddNewItem({required BuildContext ctx}) {
    _clearEditTexts();
    // tecSubkey.text = "";
    // tecV1.text = "";
    // tecV2.text = "";
    // tecV3.text = "";

// TODO *********
// List<Map>? childsFiles = [];
//     for (int i = 0; i < files!.length; i++) {
//       childsFiles.add(jsonFiles![i][mainKey]);
//     }
// TODO *********

    showModalBottomSheet<void>(
        context: ctx,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Container(
            color: dialogBgColor,
            width: double.infinity,
            height: MediaQuery.of(ctx).size.height * 0.8,
            padding: const EdgeInsets.all(8),
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
                                  fontStyle: checkedIndex != null
                                      ? FontStyle.italic
                                      : null,
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
                                  fontStyle: checkedIndex != null
                                      ? FontStyle.italic
                                      : null,
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
                Expanded(
                  child: ListView.builder(
                    itemCount: filenames!.length,
                    itemBuilder: (context, index) {
                      //
                      return SizedBox(
                        width: 300,
                        height: 100,
                        child: TextField(
                          decoration: InputDecoration.collapsed(
                            border: const OutlineInputBorder(
                              borderSide: BorderSide(width: 1),
                            ),
                            hintText: filenames![index],
                            hintStyle: const TextStyle(fontSize: 12),
                          ).copyWith(
                            contentPadding: const EdgeInsets.all(5),
                          ),
                          maxLines: 10,
                          controller: tecLanguages![index],
                        ),
                      );
                    },
                  ),
                ),

// TODO **********************************************************
/*
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
                        for ((index, item) in chil)
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
        });
  }

  void _editItemDialog({
    required BuildContext ctx,
    required int index,
    required String mainKey,
    required String selectedKey,
    required List<Map>? childsFiles,
  }) {
    tecKey.text = selectedKey;
    for (int i = 0; i < childsFiles!.length; i++) {
      tecLanguages![i].text = childsFiles![i][selectedKey];
    }

    showModalBottomSheet<void>(
      context: ctx,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          color: dialogBgColor,
          height: MediaQuery.of(ctx).size.height * 0.8,
          padding: const EdgeInsets.all(10),
          child: Center(
            child: Column(
              children: [
                /* MAIN KEY */
                Text(mainKey),

                /* EDITED KEY */
                Row(children: [
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
                            fontStyle:
                                checkedIndex != null ? FontStyle.italic : null,
                            fontWeight: checkedIndex != null
                                ? FontWeight.bold
                                : FontWeight.normal),
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 10),

                /* ALL VALUES TO EDIT */
                Expanded(
                  child: ListView.builder(
                    itemCount: filenames!.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        height: 160,
                        width: double.infinity,
                        padding: const EdgeInsets.only(bottom: 20, right: 20),
                        child: Row(
                          children: [
                            Text(filenames![index]),
                            const SizedBox(width: 10),
                            Expanded(
                              child: SizedBox(
                                height: double.infinity,
                                child: TextField(
                                  decoration: InputDecoration.collapsed(
                                    border: const OutlineInputBorder(
                                      borderSide: BorderSide(width: 1),
                                    ),
                                    hintText: filenames![index],
                                    hintStyle: const TextStyle(fontSize: 12),
                                  ).copyWith(
                                    contentPadding: const EdgeInsets.all(5),
                                  ),
                                  maxLines: 10,
                                  controller: tecLanguages![index],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),

                /* BUTTONS SAVE AND CANCEL */
                SizedBox(
                  width: double.infinity,
                  height: 30,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        child: const Text('Save changes'),
                        onPressed: () {
                          Navigator.pop(context);

                          for (var (index, _) in childsFiles.indexed) {
                            childsFiles[index][selectedKey] =
                                tecLanguages![index].text;
                          }

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
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _deleteItem({required String mainKey, required String selectedKey}) {
    for (int i = 0; i < jsonFiles!.length; i++) {
      jsonFiles![i][mainKey].remove(selectedKey);
    }
  }

  void _clearEditTexts() {
    tecSubkey.text = "";

    for (var element in tecLanguages ?? []) {
      element.text = "";
    }
  }

  Color _getRowColor({required String key, required List<String> values}) {
    return (searching &&
            (key.toUpperCase().contains(searchStr.toUpperCase()) ||
                values.any(
                  (element) {
                    return element
                        .toUpperCase()
                        .contains(searchStr.toUpperCase());
                  },
                )))
        ? Colors.red
        : darkMode
            ? Colors.grey.shade500
            : Colors.grey.shade400;
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

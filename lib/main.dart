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
  final maincolorLight = Colors.blue.shade600;
  final maincolorDark = Colors.blue.shade900;
  final backgroundColorLight = Colors.grey.shade100;
  final backgroundColorDark = Colors.black;
  final dialogBgColorLight = Colors.grey.shade100;
  final dialogBgColorDark = Colors.grey.shade500;
  final editedBgColorLight = Colors.red;
  final editedBgColorDark = Colors.red.shade900;

  TextEditingController tecKey = TextEditingController();
  TextEditingController tecSubkey = TextEditingController();
  TextEditingController tecSearch = TextEditingController();
  ScrollController scrollController = ScrollController();

  final XTypeGroup typeGroup =
      const XTypeGroup(label: 'json-files', extensions: <String>['json']);
  bool isEdited = false;
  bool searching = false;
  bool darkMode = true;
  String searchStr = "---**";

  /* following vars depend on amount of files opened */
  List<XFile>? files;
  List<TextEditingController>? tecLanguages;
  List<String>? filenames;
  List<Map>? jsonFiles;
  List<bool>? expandedMainkeyContent;

  //
  //

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _getMainColor(),
        title: _mainActions(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: filenames != null
          ? Container(
              margin: const EdgeInsets.only(right: 80),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  /* NEW GROUP */
                  ElevatedButton(
                    onPressed: files != null
                        ? () async {
                            setState(() {
                              tecKey.text = "";
                              _rowAddNewGroupOrString(
                                  ctx: context, checkedIndex: null);
                            });
                          }
                        : null,
                    style: ButtonStyle(
                        elevation: MaterialStateProperty.all(20),
                        backgroundColor:
                            MaterialStateProperty.all(_getBackgoundColor()),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    side: BorderSide(color: maincolorDark)))),
                    child: Text('+', style: TextStyle(color: _getMainColor())),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
      bottomNavigationBar: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: _getMainColor(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text("©jugomo",
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
            const Spacer(),
            const Text("the jotason editor",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            InkWell(
              onTap: () {
                _downloadDialog(ctx: context);
              },
              child: const Row(
                children: [
                  Text("- v0.4.0 -", style: TextStyle(fontSize: 12)),
                  SizedBox(width: 10),
                  Icon(
                    Icons.download,
                    color: Colors.white,
                    size: 15,
                  ),
                ],
              ),
            ),
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
            margin: const EdgeInsets.only(top: 3),
            width: double.infinity,
            height: 50,
            color: !isEdited ? _getMainColor() : _getEditedColor(),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: countFilenames,
              itemExtent: width,
              itemBuilder: (context, index) {
                return Center(
                  child: index == 0
                      /* FIRST ITEM IS HEADER FOR KEYS */
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              /* EDITED HINT */
                              if (isEdited)
                                const Text("(*)",
                                    style: TextStyle(color: Colors.white)),
                              const SizedBox(width: 10),

                              /* NEW LANG */
                              ElevatedButton(
                                onPressed: () {
                                  setState() {
                                    // TODO - implement add language *****************
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: _getBackgoundColor()),
                                child: const Text('+ lang'),
                              ),
                              const SizedBox(width: 10),
                            ],
                          ),
                        )

                      /* OTHER ITEMS ARE HEADERS FOR EACH LANGUAGE */
                      : Row(
                          children: [
                            // separator
                            Container(
                              margin: const EdgeInsets.only(left: 10),
                              width: 5,
                              height: double.infinity,
                              color: darkMode ? Colors.black : Colors.white,
                            ),

                            // language name
                            Expanded(
                              child: Text(
                                filenames![index - 1],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
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
                expandedMainkeyContent!.add(false);
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
          InkWell(
            onTap: () {
              setState(() {
                expandedMainkeyContent![index] =
                    !expandedMainkeyContent![index];
              });
            },
            child: Container(
              color: _getMainColor().withAlpha(200),
              padding: const EdgeInsets.all(3),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            tecKey.text = jsonFiles![0].keys.elementAt(index);
                            _rowAddNewGroupOrString(
                                ctx: context, checkedIndex: index);
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: _getBackgoundColor()),
                          child: Text(
                            "+ String",
                            style: TextStyle(color: _getMainColor()),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '(${index + 1})  $mainKey',
                          style: const TextStyle(color: Colors.white),
                        ),
                        const Spacer(),
                        Icon(expandedMainkeyContent![index]
                            ? Icons.arrow_upward
                            : Icons.arrow_downward)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          /* CONTENT OF THE MAINKEY GROUP */
          expandedMainkeyContent![index]
              ? SizedBox(
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
                                color: _getMainColor().withAlpha(200),
                                width: width,
                                height: double.infinity,
                                child: Row(
                                  children: [
                                    /* REMOVE ENTRY BUTTON */
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          isEdited = true;
                                          _deleteItem(
                                              mainKey: mainKey,
                                              selectedKey: key);
                                        });
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
                )
              : InkWell(
                  onTap: () {
                    setState(() {
                      expandedMainkeyContent![index] =
                          !expandedMainkeyContent![index];
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    height: 15,
                    color: _getMainColor().withAlpha(200),
                    alignment: Alignment.centerRight,
                    child: const Text("tap to expand ...",
                        style: TextStyle(
                            color: Colors.white,
                            fontStyle: FontStyle.italic,
                            fontSize: 10)),
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
            style:
                ElevatedButton.styleFrom(backgroundColor: _getBackgoundColor()),
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
            style:
                ElevatedButton.styleFrom(backgroundColor: _getBackgoundColor()),
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

          /* RESET */
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: _getBackgoundColor()),
            onPressed: files != null
                ? () async {
                    setState(() {
                      tecLanguages = null;
                      isEdited = false;
                      searching = false;
                      tecSearch.text = "";
                      searchStr = "---**";
                      files = null;
                      filenames = null;
                      jsonFiles = null;
                      expandedMainkeyContent = null;
                    });
                  }
                : null,
            child: const Text('reset', style: TextStyle(color: Colors.red)),
          ),
          const SizedBox(width: 10),

          /* SEARCH */
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: _getBackgoundColor()),
            onPressed: files != null
                ? () async {
                    setState(() {
                      searching = !searching;
                      if (!searching) {
                        tecSearch.text = "";
                        searchStr = "---**";
                        setState(() {
                          for (var (index, _)
                              in expandedMainkeyContent!.indexed) {
                            expandedMainkeyContent![index] = false;
                          }
                        });
                      } else {
                        setState(() {
                          for (var (index, _)
                              in expandedMainkeyContent!.indexed) {
                            expandedMainkeyContent![index] = true;
                          }
                        });
                      }
                    });
                  }
                : null,
            child: const Text('search', style: TextStyle(color: Colors.blue)),
          ),
          if (searching)
            Row(
              children: [
                const SizedBox(width: 10),
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
              ],
            ),

          /* DARKMODE */
          const SizedBox(width: 10),
          InkWell(
            onTap: () {
              setState(() {
                darkMode = !darkMode;
              });
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                border: null,
                borderRadius: BorderRadius.circular(20),
                color: _getBackgoundColor(),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Checkbox(
                    value: darkMode,
                    onChanged: null,
                  ),
                  Text("darkmode",
                      style: TextStyle(
                          color: darkMode ? Colors.white : Colors.black,
                          fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _rowAddNewGroupOrString({
    required BuildContext ctx,
    required int? checkedIndex,
  }) {
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
        return SizedBox(
          width: double.infinity,
          height: MediaQuery.of(ctx).size.height * 0.8,
          child: Column(
            children: [
              /* TITLE */
              Container(
                color: _getMainColor(),
                width: double.infinity,
                height: 50,
                alignment: Alignment.center,
                child: Text(checkedIndex == null ? "ADD GROUP" : "ADD STRING",
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center),
              ),

              /* CONTENT */
              Expanded(
                child: Container(
                  color: _getDialogBgColor(),
                  padding: const EdgeInsets.all(10),
                  child: Center(
                    child: Column(
                      children: [
                        /* KEYS */
                        Column(
                          children: [
                            /* mainkey */
                            Row(children: [
                              const Text("Group key:"),
                              const SizedBox(width: 10),
                              Expanded(
                                child: SizedBox(
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
                              ),
                            ]),
                            const SizedBox(height: 20),

                            /* secondary key */
                            Row(children: [
                              const Text("String key:"),
                              const SizedBox(width: 10),
                              Expanded(
                                child: SizedBox(
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
                              ),
                            ]),
                          ],
                        ),
                        const SizedBox(height: 30),

                        /* ALL VALUES TO ADD */
                        Expanded(
                          child: ListView.builder(
                            itemCount: filenames!.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                height: 160,
                                width: double.infinity,
                                padding: const EdgeInsets.only(
                                    bottom: 20, right: 20),
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
                                            hintStyle:
                                                const TextStyle(fontSize: 12),
                                          ).copyWith(
                                            contentPadding:
                                                const EdgeInsets.all(5),
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

                        /* BUTTONS ADD AND CANCEL */
                        SizedBox(
                          width: double.infinity,
                          height: 30,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              /* ADD BUTTON */
                              ElevatedButton(
                                child: const Text('Add'),
                                onPressed: () async {
                                  setState(() {
                                    // if (tecKey.text != "" && tecSubkey.text != "") {
                                    //   for ((index, item) in chil)
                                    //   if (checkedIndex != null) {
                                    //     var subkey = tecSubkey.text;
                                    //     checkedIndex = null;
                                    //     childs1![subkey] = tecV1.text;
                                    //     childs2![subkey] = tecV2.text;
                                    //     childs3![subkey] = tecV3.text;
                                    //     addingNew = false;
                                    //     isEdited = true;
                                    //   } else {
                                    //     json1![tecKey.text] = {tecSubkey.text: tecV1.text};
                                    //     json2![tecKey.text] = {tecSubkey.text: tecV2.text};
                                    //     json3![tecKey.text] = {tecSubkey.text: tecV3.text};
                                    //     addingNew = false;
                                    //     isEdited = true;
                                    //   }
                                    // } else {
                                    //   print("TODO: show msg fill all data!");
                                    // }
                                  });
                                },
                              ),
                              const SizedBox(width: 10),

                              /* CLOSE BUTTON */
                              ElevatedButton(
                                child: const Text('close'),
                                onPressed: () async {
                                  setState(() {
                                    Navigator.pop(context);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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
        return SizedBox(
          width: double.infinity,
          height: MediaQuery.of(ctx).size.height * 0.8,
          child: Column(
            children: [
              /* TITLE */
              Container(
                color: _getMainColor(),
                width: double.infinity,
                height: 50,
                alignment: Alignment.center,
                child: const Text("EDIT STRING",
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center),
              ),

              /* CONTENT */
              Expanded(
                child: Container(
                  color: _getDialogBgColor(),
                  padding: const EdgeInsets.all(10),
                  child: Center(
                    child: Column(
                      children: [
                        /* MAIN KEY */
                        Row(
                          children: [
                            const Text("Group key:"),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(mainKey,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),

                        /* EDITED KEY */
                        Row(children: [
                          const Text("String key:"),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              selectedKey,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ]),
                        const SizedBox(height: 30),

                        /* ALL VALUES TO EDIT */
                        Expanded(
                          child: ListView.builder(
                            itemCount: filenames!.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                height: 160,
                                width: double.infinity,
                                padding: const EdgeInsets.only(
                                    bottom: 20, right: 20),
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
                                            hintStyle:
                                                const TextStyle(fontSize: 12),
                                          ).copyWith(
                                            contentPadding:
                                                const EdgeInsets.all(5),
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
                              /* SAVE BUTTON */
                              ElevatedButton(
                                child: const Text('Save changes'),
                                onPressed: () {
                                  Navigator.pop(context);

                                  for (var (index, _) in childsFiles.indexed) {
                                    childsFiles[index][selectedKey] =
                                        tecLanguages![index].text;
                                  }

                                  Future.delayed(
                                          const Duration(milliseconds: 500))
                                      .then((value) {
                                    setState(() {
                                      isEdited = true;
                                    });
                                  });
                                },
                              ),
                              const SizedBox(width: 20),

                              /* CLOSE BUTTON */
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
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _downloadDialog({required BuildContext ctx}) {
    showModalBottomSheet<void>(
        context: ctx,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return SizedBox(
            width: double.infinity,
            height: MediaQuery.of(ctx).size.height * 0.8,
            child: Column(
              children: [
                /* TITLE */
                Container(
                  color: _getMainColor(),
                  width: double.infinity,
                  height: 50,
                  alignment: Alignment.center,
                  child: const Text("DOWNLOAD",
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center),
                ),

                /* CONTENT */
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: _getDialogBgColor(),
                    padding: const EdgeInsets.all(10),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("WINDOWS"),
                        Text("macOS"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
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

  Color _getMainColor() {
    if (darkMode) {
      return maincolorDark;
    } else {
      return maincolorLight;
    }
  }

  Color _getBackgoundColor() {
    if (darkMode) {
      return backgroundColorDark;
    } else {
      return backgroundColorLight;
    }
  }

  Color _getDialogBgColor() {
    if (darkMode) {
      return dialogBgColorDark;
    } else {
      return dialogBgColorLight;
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

  Color _getEditedColor() {
    if (darkMode) {
      return editedBgColorDark;
    } else {
      return editedBgColorLight;
    }
  }

  Future<void> loadData() async {
    if (files == null || files!.isEmpty) {
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
    expandedMainkeyContent = [];

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

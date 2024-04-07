// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'package:flutter/material.dart';

Widget getDownload(Color dialogBgColor) {
  return Expanded(
    child: Container(
      width: double.infinity,
      color: dialogBgColor,
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              var url = "./release/0.5.0/json_editor_0.5.0_macos.zip";
              html.AnchorElement anchorElement = html.AnchorElement(href: url);
              anchorElement.download = url;
              anchorElement.click();
            },
            child: Text(
              "WINDOWS - v0.5.0",
              style: TextStyle(
                decoration: TextDecoration.underline,
                color: Colors.blue.shade900,
              ),
            ),
          ),
          InkWell(
            onTap: () {
              var url = "./release/0.5.0/json_editor_0.5.0_win.zip";
              html.AnchorElement anchorElement = html.AnchorElement(href: url);
              anchorElement.download = url;
              anchorElement.click();
            },
            child: Text(
              "macOS - v0.5.0",
              style: TextStyle(
                decoration: TextDecoration.underline,
                color: Colors.blue.shade900,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

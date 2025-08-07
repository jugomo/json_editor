import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Widget getDownload(Color dialogBgColor) {
  return Expanded(
    child: Container(
      width: double.infinity,
      // color: dialogBgColor,
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () async {
              final Uri url = Uri.parse(
                  'https://play.google.com/store/apps/details?id=com.jugomo.json_editor&pli=1');
              await launchUrl(url);
            },
            splashColor: Colors.yellowAccent,
            child: const Text(
              "  >> Download from Google Play",
              textAlign: TextAlign.start,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

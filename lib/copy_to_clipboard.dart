/* By Abdullah As-Sadeed */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

void copyToClipBoard(
  String dataType,
  String string,
) {
  if (dataType.isNotEmpty && string.isNotEmpty) {
    Clipboard.setData(
      ClipboardData(
        text: string,
      ),
    );

    Fluttertoast.showToast(
      msg: "$dataType copied to clipboard",
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
    );
  }
}

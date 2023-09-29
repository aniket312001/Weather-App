import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';

import 'package:another_flushbar/flushbar.dart';

showCustomToast({
  required BuildContext context,
  String message = 'Something Went Wrong(C Internet)!',
}) {
  Flushbar(
    message: message,
    duration: Duration(seconds: 2),
    backgroundColor: Colors.black.withOpacity(0.6),
    flushbarStyle: FlushbarStyle.FLOATING,
    margin: EdgeInsets.only(bottom: 16, left: 16, right: 16),
    borderRadius: BorderRadius.circular(5),
    shouldIconPulse: false,
    // isDismissible: false,
  ).show(context);
}

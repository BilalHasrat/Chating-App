import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../main.dart';

class DialogWidget {

  static void showSnackBar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.brown.shade700,
        behavior: SnackBarBehavior.floating,
      ),);}

  static void showProgressBar(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) => Center(
              child: CircularProgressIndicator(
                color: Colors.deepOrange,
                semanticsLabel: 'W a i t',
              ),));}

}

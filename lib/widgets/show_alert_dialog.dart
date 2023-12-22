import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_chat_app/model/chat_user_model.dart';

import '../main.dart';

class ShowAlertDialog extends StatefulWidget {
  final ChatUser user;
  const ShowAlertDialog({super.key, required this.user});

  @override
  State<ShowAlertDialog> createState() => _ShowAlertDialogState();
}

class _ShowAlertDialogState extends State<ShowAlertDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.brown.shade200,
     // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
        height: s.height * .3,
        width: s.width * .6,
        child: Column(
          children: [
            ClipRRect(
             // borderRadius: BorderRadius.circular(s.height * .3),
              child: CachedNetworkImage(
                width: s.width,
                height: s.height * .3,
                fit: BoxFit.cover,
                imageUrl: widget.user.image.toString(),
                // placeholder: (context,url)=> CircularProgressIndicator(),
                errorWidget: (context,url, error)=> CircleAvatar(child: Icon(CupertinoIcons.person)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

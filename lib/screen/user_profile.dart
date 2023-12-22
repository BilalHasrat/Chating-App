import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_chat_app/helper/my_date_utile.dart';
import 'package:my_chat_app/model/chat_user_model.dart';
import '../main.dart';

class UserProfileScreen extends StatefulWidget {
  final ChatUser user;

  const UserProfileScreen({super.key, required this.user});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreen();
}

class _UserProfileScreen extends State<UserProfileScreen> {


  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        // app bar
          appBar: AppBar(
            title: Text(widget.user.name),
          ),

          // floating button to add new user
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Joined on: ',style: TextStyle(fontSize: 20,fontWeight: FontWeight.w600),),
              Text(MyDateTime.getGetLastMessageTime(context: context, time: widget.user.createdAt,showYear: true)
                ,style: TextStyle(fontSize: 18,color: Colors.black54),),
            ],
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: s.width * .05),
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: s.height * .03,
                    ),
                     ClipRRect(
                      borderRadius:
                      BorderRadius.circular(s.height * 1),
                      child: CachedNetworkImage(
                        height: s.height * .2,
                        width: s.height * .2,
                        fit: BoxFit.fitWidth,
                        imageUrl: widget.user.image.toString(),
                        // placeholder: (context,url)=> CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            CircleAvatar(
                                child: Icon(CupertinoIcons.person)),
                      ),
                    ),
                    SizedBox(
                      height: s.height * .03,
                    ),
                    Text(
                      widget.user.email.toString(),
                      style: TextStyle(),
                    ),
                    SizedBox(
                      height: s.height * .03,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('About: ',style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600),),
                        Text(widget.user.about
                          ,style: TextStyle(fontSize: 16,color: Colors.black54,),),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }
}

import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_chat_app/helper/dialogs_widget.dart';
import 'package:my_chat_app/screen/auth_screen/login_screen.dart';
import 'package:my_chat_app/screen/profile_sceen.dart';
import 'package:my_chat_app/widgets/chat_user_card.dart';

import '../apis/apis.dart';
import '../main.dart';
import '../model/chat_user_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  // For Storing all user
  List <ChatUser> _userList = [];

  // For Searching Search lis
  final List<ChatUser> _searchList = [];

  //For Storing Search items
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();

    // For updating user active status according to lifecycle events
    // resume -- active or online
    // pause -- inactive or offline
    SystemChannels.lifecycle.setMessageHandler((message) {
      if(APIs.auth.currentUser != null){
        if(message.toString().contains('resume')) {
          APIs.updateStatusActive(true);
        }
        if(message.toString().contains('pause')) {
          APIs.updateStatusActive(false);
        }
      }
      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=> FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: (){
          if(_isSearching){
            setState(() {
              _isSearching =! _isSearching;
            });
            return Future.value(false);
          }else{
            return Future.value(true);
          }
        },
        child: Scaffold(
          // app bar
          appBar: AppBar(
            leading: Icon(Icons.home_outlined),
            title: _isSearching ? TextField(
              cursorColor: Colors.white,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: ' Name, Email...',
                hintStyle: TextStyle(color: Colors.white,fontSize: 14),
              ),
              autofocus: true,
              // when search text changes then update search list
              onChanged: (val){
                // search logic
                _searchList.clear();
                for(var i in _userList){
                  if(i.name.toLowerCase().contains(val.toLowerCase()) ||
                      i.email.toLowerCase().contains(val.toLowerCase())){
                    _searchList.add(i);
                  }
                  setState(() {
                    _searchList;
                  });
                }
              },
            ):Text('Lets Chat'),
            actions: [
              //search user button
              IconButton(
                  onPressed: (){
                    setState(() {
                      _isSearching =! _isSearching;
                    });
                  },
                  icon: Icon(_isSearching ? CupertinoIcons.clear_circled :Icons.search)
              ),

              // more features button
              IconButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (_)=> ProfileScreen(user: APIs.me,)));
              },
                  icon: Icon(Icons.person)),
            ],
          ),

          // floating button to add new user
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
             _addNewUser();
            },
            child: Icon(Icons.add_comment_rounded),),

          body: StreamBuilder(
            stream: APIs.getMyUserId(),

            // get id of only known user
            builder: (context, snapshot) {
              switch(snapshot.connectionState) {
              // if data is loading
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return  Center(child: CircularProgressIndicator(color: Colors.deepOrange,),);

              // if some data or all data are loading
                case ConnectionState.active:
                case ConnectionState.done:
              return StreamBuilder(
                stream: APIs.getAllUser(snapshot.data!.docs.map((e) => e.id).toList() ?? []),

                // get only those user, who's id's are provided
                builder: (context, snapshot) {
                  switch(snapshot.connectionState) {
                  // if data is loading
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return const Center(child: CircularProgressIndicator(color: Colors.deepOrange,),);

                  // if some data or all data are loading
                    case ConnectionState.active:
                    case ConnectionState.done:

                      final data = snapshot.data?.docs;
                      _userList = data!.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
                      if( snapshot.hasData && snapshot.data!.docs != null){
                  return ListView.builder(
                  itemCount: _isSearching ? _searchList.length : _userList.length,
                  padding: EdgeInsets.only(top: s.height * .008),
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                  return ChatUserCard(user: _isSearching ? _searchList[index] : _userList[index],);
                  });
                  }else {
                        return Center(child: Text('No User Found!',
                          style: TextStyle(fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown),),);
                      }
                      }
                },
              );
              }
            },
          )
        ),
      ),
    );
  }
  // For adding new user
  void _addNewUser(){
    String email = '';
    showDialog(context: context, builder: (context){
      return AlertDialog(
        contentPadding: EdgeInsets.only(top: 20,bottom: 10,left: 24,right: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.message,size: 28,color: Colors.brown,),
            Text('  Add user')
          ],
        ),
        content: TextFormField(
          maxLines: null,
          onChanged: (value) => email = value,
          decoration: InputDecoration(
            hintText: 'xyz@gmail.com',
              prefixIcon: Icon(Icons.person_add_alt),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              )
          ),
        ),
        actions: [
          MaterialButton(
            onPressed: (){
              Navigator.pop(context);
            },
            child: Text('Cancel',style: TextStyle(fontSize: 16,color: Colors.brown),),
          ), MaterialButton(
            onPressed: ()async{
              Navigator.pop(context);
              if(email.isNotEmpty){
               await APIs.addChatUser(email).then((value) {
                 if(value){
                   DialogWidget.showSnackBar(context, 'User does not exist');
                 }
               });
              }
            },
            child: Text('Add',style: TextStyle(fontSize: 16,color: Colors.brown),),
          )
        ],
      );
    });
  }

}

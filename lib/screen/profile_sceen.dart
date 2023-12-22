import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_chat_app/model/chat_user_model.dart';
import '../apis/apis.dart';
import '../helper/dialogs_widget.dart';
import '../main.dart';
import 'auth_screen/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _img;

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          // app bar
          appBar: AppBar(
            title: Text('Profile Screen'),
          ),

          // floating button to add new user
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              DialogWidget.showProgressBar(context);
              await APIs.auth.signOut().then((value) async {
                await GoogleSignIn().signOut().then((value) {
                  // for hiding progress dialog
                  Navigator.pop(context);

                  // for moving to home screen
                  Navigator.pop(context);

                   APIs.auth = FirebaseAuth.instance;

                  //for replacing home screen with login screen
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => LoginScreen()));
                });
              });
            },
            label: Text('LogOut'),
            icon: Icon(Icons.chat),
          ),
          body: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: s.width * .05),
              child: SingleChildScrollView(
                child: Column(
                  //mainAxisAlignment: MainAxisAlignment.center,
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: s.height * .03,
                    ),
                    Stack(
                      children: [
                        _img != null
                            ? ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(s.height * 1),
                                child: Image.file(File(_img!),
                                  height: s.height * .2,
                                  width: s.height * .2,
                                  fit: BoxFit.fitWidth,
                                ),
                              )
                            : ClipRRect(
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
                        Positioned(
                            bottom: 0,
                            right: 0,
                            child: MaterialButton(
                              child: Icon(
                                Icons.edit,
                                color: Colors.deepOrange,
                              ),
                              color: Colors.white,
                              shape: CircleBorder(),
                              onPressed: () {
                                showBottomNavBar();
                              },
                            ))
                      ],
                    ),
                    SizedBox(
                      height: s.height * .03,
                    ),
                    Text(
                      widget.user.email.toString(),
                      style: TextStyle(color: Colors.black54),
                    ),
                    SizedBox(
                      height: s.height * .03,
                    ),
                    TextFormField(
                      initialValue: widget.user.name,
                      decoration: InputDecoration(
                        hintText: 'e.g Mr. xyz',
                        label: Text('name'),
                        prefixIcon: Icon(
                          Icons.person,
                          color: Colors.red,
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15)),
                      ),
                      onSaved: (val) => APIs.me.name = val!,
                      validator: (value) => value != null && value.isNotEmpty
                          ? null
                          : 'Required Field',
                    ),
                    SizedBox(
                      height: s.height * .03,
                    ),
                    TextFormField(
                      initialValue: widget.user.about,
                      decoration: InputDecoration(
                        hintText: 'e.g Hey! i m using Lets chat',
                        label: Text('about'),
                        prefixIcon: Icon(
                          Icons.info_outline,
                          color: Colors.red,
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15)),
                      ),
                      onSaved: (val) => APIs.me.about = val!,
                      validator: (value) => value != null && value.isNotEmpty
                          ? null
                          : 'Required Field',
                    ),
                    SizedBox(
                      height: s.height * .03,
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          APIs.updateUserInfo().then((value) {
                            DialogWidget.showSnackBar(
                                context, 'Profile Updated Successfully');
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: StadiumBorder(),
                        minimumSize: Size(s.width * .5, s.height * .06),
                      ),
                      icon: Icon(
                        Icons.edit,
                        size: 28,
                      ),
                      label: Text(
                        'Update',
                        style: TextStyle(fontSize: 20),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )),
    );
  }

  void showBottomNavBar(){
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20))
        ),
        builder: (_){
          return ListView(
            padding: EdgeInsets.only(top: s.height * .03,bottom: s.height * .06),
            shrinkWrap: true,
            children: [
              Text('Pick Profile Picture',textAlign: TextAlign.center,style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: CircleBorder(),
                          fixedSize: Size(s.width * .32, s.height * .2)
                      ),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                        if(image !=  null){
                          setState(() {
                            _img = image.path;
                          });
                          APIs.updateUserProfile(File(_img!));
                          Navigator.pop(context);
                        }
                      },
                      child: Icon(CupertinoIcons.photo,color: Colors.brown,size: s.height * .1,)),

                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: CircleBorder(),
                          fixedSize: Size(s.width * .32, s.height * .2)
                      ),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(source: ImageSource.camera);
                        if(image !=  null){
                          setState(() {
                            _img = image.path;
                          });
                          APIs.updateUserProfile(File(_img!));
                          Navigator.pop(context);
                        }
                      },
                      child: Icon(CupertinoIcons.camera_circle,color: Colors.brown,size: s.height * .12,))
                ],
              )
            ],
          );
        });
  }

}

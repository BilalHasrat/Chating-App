import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_chat_app/screen/home_screen.dart';
import '../../apis/apis.dart';
import '../../helper/dialogs_widget.dart';
import '../../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  bool _isAnimate = false;

  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 300),(){
      setState(() {
        _isAnimate = true;
      });
    });
    // TODO: implement initState
    super.initState();
  }
  _handleGoogleButtonClick(){
    DialogWidget.showProgressBar(context);
    _signInWithGoogle().then((user) async{
      Navigator.pop(context);
      if(user != null ){
        log('\n User: ${user.user}');
        log('\n User Addition: ${user.additionalUserInfo}');
        if((await APIs.userExist())){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
        }else{
          await APIs.createUser().then((value) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
          });
        }
      }});
  }

  Future<UserCredential?> _signInWithGoogle() async {
   try{
     await InternetAddress.lookup('google.com');
     // Trigger the authentication flow
     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

     // Obtain the auth details from the request
     final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

     // Create a new credential
     final credential = GoogleAuthProvider.credential(
       accessToken: googleAuth?.accessToken,
       idToken: googleAuth?.idToken,
     );

     // Once signed in, return the UserCredential
     return await APIs.auth.signInWithCredential(credential);
   }catch(e){
     print('\n_signInWithGoogle: $e');
     DialogWidget.showSnackBar(context, 'Something went wrong(Or Check Internet)');
     return null;
   }
  }

  @override
  Widget build(BuildContext context) {
     s = MediaQuery.of(context).size;
    return Scaffold(
      // app bar
      appBar: AppBar(
        title: Text('Welcome to Lets Chat'),
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          AnimatedPositioned(
              top: s.height * .20,
              left: s.width * .25,
              width: _isAnimate ? s.width * .5 : s.width * .01,
              duration: Duration(seconds: 2),
              child: Image.asset('assets/chating.png',)),
          Positioned(
              bottom: s.height * .15,
              left: s.width * .05,
              width: s.width * .9,
              height: s.height * .07,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange.shade300,
                  shape: StadiumBorder()
                ),
                onPressed: () {
                  _handleGoogleButtonClick();
                },
                icon: Image.asset('assets/google.png',height: s.height * .04,),
                label: RichText(
                    text: TextSpan(
                        style: TextStyle(color: Colors.blue,),
                      children: [
                        TextSpan(text: 'Sign in with'),
                        TextSpan(text: ' Google',style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold,fontSize: 20)),
                      ]
                    )),
              ))

        ],
      ),
    );
  }
}

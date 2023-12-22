import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_chat_app/screen/auth_screen/login_screen.dart';
import 'package:my_chat_app/screen/home_screen.dart';
import '../../main.dart';
import '../apis/apis.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 2000),(){

      print(APIs.auth.currentUser);

      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.white70,statusBarColor: Colors.transparent));

      if(APIs.auth.currentUser != null){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));

      }else{
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));

      }
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    s = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.deepOrange.shade100,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          AnimatedPositioned(
              top: s.height * .20,
              left: s.width * .25,
              width: s.width * .5 ,
              duration: Duration(seconds: 2),
              child: Image.asset('assets/chating.png',)),
          Positioned(
              bottom: s.height * .15,
              left: s.width * .05,
              width: s.width * .9,
              height: s.height * .07,
              child: Align(
                  alignment: Alignment.center,
                  child: Text('Made it by Bilal Hasrat',style: TextStyle(fontSize: 20,fontWeight: FontWeight.w700),))
          )

        ],
      ),
    );
  }
}

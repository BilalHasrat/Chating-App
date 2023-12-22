import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:my_chat_app/screen/auth_screen/login_screen.dart';
import 'package:my_chat_app/screen/home_screen.dart';
import 'package:my_chat_app/screen/splash_screen.dart';

import 'firebase_options.dart';

// global object for accessing device screen size
late Size s;

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );

  // Enter full-screen
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // for setting orientation to portrait only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]).then((value) => {
    _initializeFirebase(),
    runApp(const MyApp())
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lets Chats',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Color(0xff59260B)),
        appBarTheme: AppBarTheme(
          titleTextStyle: TextStyle(fontWeight: FontWeight.bold),
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white)
        )
      ),
      home: const SplashScreen(),
    );
  }
}
_initializeFirebase()async{
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  var result = await FlutterNotificationChannel.registerNotificationChannel(
    description: 'For Showing message notification',
    id: 'chats',
    importance: NotificationImportance.IMPORTANCE_HIGH,
    name: 'Chats',
  );
  print(result);
}

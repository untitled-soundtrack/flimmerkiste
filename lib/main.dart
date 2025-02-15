import 'dart:io';
import 'package:flimmerkiste/profilepage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'home.dart';
import 'login.dart';
import 'register.dart';
class PostHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient( context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}
void main() async {
  HttpOverrides.global = new PostHttpOverrides();
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyDfepxCFy4I907oQtxRm_ZN4N7JbDIBzDU",
          authDomain: "flimmerkiste-396c9.firebaseapp.com",
          projectId: "flimmerkiste-396c9",
          storageBucket: "flimmerkiste-396c9.appspot.com",
          messagingSenderId: "212562935234",
          appId: "1:212562935234:web:332fe094b9bd136153aa5b",
          measurementId: "G-XY6RGF6W65"),
    );
  } catch (e) {}
  runApp(MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  final routes = <String, WidgetBuilder>{
    Register.tag: (context) => const Register(),
    Login.tag: (context) => const Login(),
    ProfilePage.tag: (context) => const ProfilePage(),
    HomePage.tag: (context) => const HomePage(),
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: MaterialApp(
          color: Colors.black,
          debugShowCheckedModeBanner: false,
          home: MaterialApp(
            color: Colors.black,
            title: 'Login',
            theme: ThemeData(
              primarySwatch: Colors.lightBlue,
              fontFamily: 'NUnit',
            ),
            home: const Login(),
            routes: routes,
          )),
    );
  }
}

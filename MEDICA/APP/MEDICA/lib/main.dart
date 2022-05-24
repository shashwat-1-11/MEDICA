import 'package:flutter/material.dart';
import 'loginPage.dart';
import 'dashboard.dart';
import 'registration page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/dashboard',
      routes: {
        '/login' : (context) => LoginPage(),
        '/register' : (context) => RegistrationPage(),
        '/dashboard' :(context) => Dashpage()
    },

    );
  }
}







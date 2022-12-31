import 'package:flutter/material.dart';
import 'loginPage.dart';
import 'dashboard.dart';
import 'registration page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'bluetooth.dart';
import 'relatives.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login' : (context) => LoginPage(),
        '/register' : (context) => RegistrationPage(),
        '/dashboard' :(context) => Dashpage(),
        '/bluetooth': (context) => BluetoothApp(),
        '/relatives': (context) => RelativesPage()
      },
    );
  }
}







import 'package:flutter/material.dart';
import 'package:progmob_flutter/pages/login.dart';
import 'package:progmob_flutter/pages/register.dart';
import 'package:progmob_flutter/pages/homepage.dart';
import 'package:progmob_flutter/pages/userpage.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';

Future<void> main() async {
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      routes: {
        '/': (context) => LoginPage(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/homepage': (context) => HomePage(),
        '/userpage': (context) => UserPage(),
      },
      debugShowCheckedModeBanner: false,
      title: 'Progmob',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
    );
  }
}

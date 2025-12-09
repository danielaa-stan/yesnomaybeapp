import 'auth.dart';
import '../pages/homepage.dart';
import 'package:flutter/material.dart';
import '../pages/loginpage.dart';
import '../pages/signuppage.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({Key ? key}) : super(key: key);

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Auth().authStateChanges,
        builder: (context, snapshot) {
          //loading state showing
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          //user logged in
          if(snapshot.hasData) {
            return HomePage();
        } else {
            //user logged out or was not authorized
          return const LoginPage();
         }
        },
    );
  }
}


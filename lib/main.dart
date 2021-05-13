import 'package:flutter/material.dart';
import 'package:grupospequenos/screens/wrapper.dart';
import 'package:grupospequenos/services/auth.dart';
import 'package:provider/provider.dart';
import 'package:grupospequenos/models/user.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User>.value(
        value: AuthService().user,
        child: MaterialApp(
            title: 'Grupos Pequeños Online',
            home: Wrapper(),
            color: Colors.blue[700],
            theme: ThemeData(
                accentColor: Colors.blue,
                appBarTheme:
                    AppBarTheme(color: Colors.grey.shade200, elevation: 5),
                cursorColor: Colors.blue,
                buttonTheme: ButtonThemeData(
                    buttonColor: Colors.blue[700],
                    textTheme: ButtonTextTheme.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20))),
                iconTheme: IconThemeData(color: Colors.blue[700]),
                primaryColor: Colors.blue[700],
                primaryColorDark: Colors.blue[800],
                primaryColorLight: Colors.blue[200],
                scaffoldBackgroundColor: Colors.grey.shade100,
                textSelectionColor: Colors.blue[200]),
            debugShowCheckedModeBanner: false));
  }
}

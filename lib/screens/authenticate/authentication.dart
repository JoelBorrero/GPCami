import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grupospequenos/screens/authenticate/sign_in.dart';
import 'package:grupospequenos/screens/authenticate/register.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

PageController _mainController = PageController();
void goToPageMain(int page) {
  _mainController.animateToPage(page,
      duration: Duration(milliseconds: 800), curve: Curves.bounceInOut);
}


class _AuthenticateState extends State<Authenticate> {
  @override
  Widget build(BuildContext context) {
    return PageView(
        controller: _mainController,
        physics: AlwaysScrollableScrollPhysics(),
        children: <Widget>[SignIn(), Register()]);
  }
}

Future<bool> get isRoot async {
  return await Firestore.instance
      .collection('userData')
      .getDocuments()
      .then((d) => d.documents.length == 0);
}

import 'package:flutter/material.dart';
import 'package:grupospequenos/models/user.dart';
import 'package:grupospequenos/screens/authenticate/authentication.dart';
import 'package:grupospequenos/screens/home/sidebar/sidebar_layout.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    //Return Home or Authenticate widget
    if (user == null) {
      return Authenticate();
    } else {
      return SideBarLayout();
    }
  }
}

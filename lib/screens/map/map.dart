import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grupospequenos/models/group.dart';
import 'package:grupospequenos/services/database.dart';
import 'package:grupospequenos/screens/map/groups_map.dart';
import 'package:grupospequenos/services/navigation_bloc.dart';

class Map extends StatelessWidget with NavigationStates {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<Group>>.value(
      value: DatabaseService().groupList,
      child: Scaffold(
          body: Stack(
        children: <Widget>[
          GroupsMap(),
          Container(
            height: 86,
            child: AppBar(
                title: Text(
                  'Mapa',
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 30),
                ),
                centerTitle: true,
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.only(bottomRight: Radius.circular(80)))),
          ),
        ],
      )),
    );
  }
}

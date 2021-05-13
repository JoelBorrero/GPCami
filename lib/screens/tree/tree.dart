import 'package:flutter/material.dart';
import 'package:grupospequenos/shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grupospequenos/screens/tree/tree_tile.dart';
import 'package:grupospequenos/services/navigation_bloc.dart';

class Tree extends StatelessWidget with NavigationStates {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            'Árbol general',
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w800,
                fontSize: 30),
          ),
          centerTitle: true,
          shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.only(bottomRight: Radius.circular(80)))),
      body: TreeData(),
    );
  }
}

class TreeData extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Firestore.instance
            .collection('userData')
            .orderBy('level')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Loading();
          } else {
            int lv = 0;
            List<DocumentSnapshot> list = [];
            List<Widget> widgets = [];
            snapshot.data.documents.forEach((document) {
              if (document.data['level'] == lv) {
                list.add(document);
              } else {
                widgets.add(TreeTile(documents: list, general: true));
                list = [];
                list.add(document);
                lv = lv + 1;
                widgets.add(Text('    Líderes nivel $lv:',
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w300)));
              }
            });
            widgets.add(TreeTile(documents: list,general: true));
            return ListView(
                padding: EdgeInsets.only(top: 20), children: widgets);
          }
        });
  }
}

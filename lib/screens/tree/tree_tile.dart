import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grupospequenos/models/user.dart';
import 'package:grupospequenos/shared/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TreeTile extends StatelessWidget {
  final List<DocumentSnapshot> documents;
  final bool general;
  TreeTile({this.documents, this.general});
  @override
  Widget build(BuildContext context) {
    bool isRoot = general
        ? documents[0].data['leader'] == ''
        : documents[0].documentID == Provider.of<User>(context).uid;
    return Container(
        padding: EdgeInsets.only(left: 10),
        height: isRoot ? 174 : 110,
        child: Center(
            child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  return Column(children: <Widget>[
                    isRoot
                        ? Card(
                            color: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            child: Column(children: <Widget>[
                              Text(
                                  '  ' +
                                      documents[0].data['name'] +
                                      ' ' +
                                      documents[0].data['lastName'] +
                                      '  ',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20)),
                              //Text('890 alcanzados', style: TextStyle(color: Colors.white, fontSize: 12)),
                            ]))
                        : Row(
                            children: <Widget>[
                              SizedBox(width: 10),
                              profilePic(documents[index], 50, context,true),
                              SizedBox(width: 10)
                            ],
                          ),
                    isRoot
                        ? profilePic(documents[index], 100, context,true)
                        : Text(
                            '  ${documents[index].data['name']} ${documents[index].data['lastName']}  ',
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 14))
                  ]);
                })));
  }
}

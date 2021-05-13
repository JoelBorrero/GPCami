import 'package:flutter/material.dart';
import 'package:grupospequenos/models/user.dart';
import 'package:grupospequenos/shared/loading.dart';
import 'package:grupospequenos/shared/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grupospequenos/services/database.dart';
import 'package:grupospequenos/services/navigation_bloc.dart';
import 'package:provider/provider.dart';

class Notifications extends StatefulWidget with NavigationStates {
  @override
  _NotificationsState createState() => _NotificationsState();
}

User _user;

class _NotificationsState extends State<Notifications> {
  @override
  Widget build(BuildContext context) {
    _user = Provider.of<User>(context);
    return Scaffold(
        appBar: AppBar(
            title: Text('Solicitudes',
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 30)),
            centerTitle: true,
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.only(bottomRight: Radius.circular(80)))),
        body: StreamBuilder(
            stream: Firestore.instance.collection('userData').snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return Loading();
              } else {
                return ListView.builder(
                    padding: EdgeInsets.only(bottom: 70, left: 20, right: 20),
                    itemCount: snapshot.data.documents
                        .where((d) => d.documentID.contains('child'))
                        .length,
                    itemBuilder: (context, i) {
                      return tile(snapshot.data.documents
                          .where((d) => d.documentID.contains('child'))
                          .toList()[i]);
                    });
              }
            }));
  }
}

Widget tile(DocumentSnapshot doc) {
  bool _autonomy = doc.data['autonomy'];
  return Padding(
      padding: EdgeInsets.symmetric(vertical:4),
      child: Card(
          margin: EdgeInsets.fromLTRB(20, 6, 20, 0),
          child: ExpansionTile(
              title: Text('${doc.data['name']} ${doc.data['lastName']}'),
              backgroundColor:
                  _autonomy ? Colors.lightGreen[50] : Colors.red[50],
              trailing: profilePic(doc, 50, null, false),
              leading: _autonomy?Icon(Icons.timelapse):null,
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: _autonomy
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                                RaisedButton.icon(
                                    onPressed: doc.data['waiting']
                                        ? null
                                        : () => _approve(doc, true),
                                    icon: Icon(Icons.check_circle_outline),
                                    label: Text('Aprobar')),
                                RaisedButton.icon(
                                    onPressed: () => _approve(doc, false),
                                    icon: Icon(Icons.update),
                                    color: Colors.redAccent[700],
                                    label: Text('Posponer'))
                              ])
                        : Text(
                            'El líder aún no ha solicitado autonomía para ${doc.data['name']}'))
              ])));
}

void _approve(DocumentSnapshot doc, bool approve) {
  DatabaseService(uid: doc.documentID).approveAutonomy(approve);
  DatabaseService(uid: _user.uid).getPending();
}

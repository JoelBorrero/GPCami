import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grupospequenos/models/user.dart';
import 'package:grupospequenos/shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grupospequenos/shared/constants.dart';
import 'package:grupospequenos/services/database.dart';
import 'package:grupospequenos/screens/tree/tree_tile.dart';
import 'package:grupospequenos/services/navigation_bloc.dart';

List<DocumentSnapshot> _mainList = [];
User _user;

class MyTree extends StatefulWidget with NavigationStates {
  @override
  _MyTreeState createState() => _MyTreeState();
}
bool allow(String doc, String parent) {
  String _leader = doc;
  while (_leader != '') {
    for (int i = 0; i < _mainList.length; i++) {
      if (_leader == parent) return true;
      if (_leader == _mainList[i].documentID)
        _leader = _mainList[i].data['leader'];
    }
  }
  return false;
}
class _MyTreeState extends State<MyTree> {
  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    String _newName, _newLastName, _newPhone, _newParent;
    int _level = 1;
    _user = Provider.of<User>(context);
    DatabaseService(uid: _user.uid)
        .personalInfo
        .first
        .then((value) => _level = value.level);
        int _newLevel=_level+1;
    return Scaffold(
        appBar: AppBar(
            title: Text('Mi árbol',
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 30)),
            centerTitle: true,
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.only(bottomRight: Radius.circular(80)))),
        body: MyTreeData(),
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              _newName = '';
              _newLastName = '';
              _newPhone = '';
              _newParent = _user.uid;
              showDialog(
                  context: context,
                  child: Dialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                          padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
                          child: SingleChildScrollView(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                SizedBox(height: 20),
                                Text('Añadir nuevo lider',
                                    style: TextStyle(
                                        fontSize: 24,
                                        color: Theme.of(context).primaryColor)),
                                TextField(
                                    decoration: textInputDecoration.copyWith(
                                        labelText: 'Nombre'),
                                    onChanged: (value) => setState(() {
                                          _newName = value;
                                        })),
                                TextField(
                                    decoration: textInputDecoration.copyWith(
                                        labelText: 'Apellido'),
                                    onChanged: (value) => setState(() {
                                          _newLastName = value;
                                        })),
                                TextField(
                                    decoration: textInputDecoration.copyWith(
                                        labelText: 'Teléfono'),
                                    onChanged: (value) => setState(() {
                                          _newPhone = value;
                                        })),
                                DropdownButtonFormField(
                                    value: _mainList.singleWhere((d) => d.documentID == _user.uid),
                                    items: _mainList
                                        .where((element) =>
                                            allow(element.documentID,
                                                    _user.uid) &&
                                                element.data['level'] - _level <
                                                    3 &&
                                                !element.data['autonomy'] ||
                                            element.documentID == _user.uid)
                                        .map((p) {
                                      return DropdownMenuItem(
                                          value: p,
                                          child: Text(
                                              '${p.data['name']} ${p.data['lastName']}',
                                              style: TextStyle(
                                                  color: _user.uid ==
                                                          p.documentID
                                                      ? Theme.of(context)
                                                          .primaryColor
                                                      : Colors.black)));
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _newParent =
                                            value.documentID.toString();
                                        _newLevel = value.data['level'] + 1;
                                      });
                                    },
                                    icon: Icon(Icons.person,
                                        color: Theme.of(context).accentColor)),
                                Center(
                                    child: Container(
                                  width: _size.width,
                                  child: RaisedButton(
                                      child: Text('Añadir',
                                          style:
                                              TextStyle(color: Colors.white)),
                                      onPressed: () {
                                        if (_newName != '' &&
                                            _newLastName != '' &&
                                            _newParent != '') {
                                          DatabaseService(uid: _user.uid)
                                              .createTempUser(
                                                  _newName,
                                                  _newLastName,
                                                  _newPhone,
                                                  _newParent,
                                                  _newLevel);
                                          Navigator.pop(context);
                                        } else {
                                          showDialog(
                                              context: context,
                                              child: Dialog(
                                                  child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: <Widget>[
                                                        SizedBox(height: 20),
                                                        Text(
                                                            'Revise los siguientes datos',
                                                            style: TextStyle(
                                                                fontSize: 20,
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColor)),
                                                        SizedBox(height: 10),
                                                        Text('Nombre',
                                                            style: TextStyle(
                                                                color: _newName !=
                                                                        ''
                                                                    ? Colors
                                                                        .green
                                                                    : Colors
                                                                        .red)),
                                                        Text('Apellido',
                                                            style: TextStyle(
                                                                color: _newLastName !=
                                                                        ''
                                                                    ? Colors
                                                                        .green
                                                                    : Colors
                                                                        .red)),
                                                        Text('Teléfono',
                                                            style: TextStyle(
                                                                color: _newPhone !=
                                                                        ''
                                                                    ? Colors
                                                                        .green
                                                                    : Colors
                                                                        .amber)),
                                                        Text('Líder',
                                                            style: TextStyle(
                                                                color: _newParent !=
                                                                        ''
                                                                    ? Colors
                                                                        .green
                                                                    : Colors
                                                                        .red)),
                                                        SizedBox(height: 20)
                                                      ]),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20))));
                                        }
                                      },
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20))),
                                )),
                                SizedBox(height: 20)
                              ])))));
            },
            label: Text('Añadir lider'),
            icon: Icon(Icons.person_add)));
  }
}

class MyTreeData extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Firestore.instance
            .collection('userData')
            .orderBy('level')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData)
            return Loading();
          else {
            _mainList = [];
            snapshot.data.documents.forEach((doc) {
              _mainList.add(doc);
            });
            int lv;
            List<DocumentSnapshot> list = [];
            List<Widget> widgets = [];
            snapshot.data.documents.forEach((doc) {
              if (allow(doc.documentID, _user.uid)) {
                if (lv == null) lv = doc.data['level'];
                if (doc.data['level'] == lv)
                  list.add(doc);
                else {
                  widgets.add(TreeTile(documents: list, general: false));
                  list = [];
                  list.add(doc);
                  lv = lv + 1;
                  widgets.add(Text('    Líderes nivel $lv:',
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w300)));
                }
              }
            });
            if (list.isNotEmpty)
              widgets.add(TreeTile(documents: list, general: false));
            return ListView(
                padding: EdgeInsets.only(top: 20), children: widgets);
          }
        });
  }
}

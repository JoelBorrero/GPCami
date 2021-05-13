import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grupospequenos/models/user.dart';
import 'package:grupospequenos/shared/loading.dart';
import 'package:grupospequenos/shared/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grupospequenos/services/database.dart';
import 'package:grupospequenos/services/navigation_bloc.dart';

class Help extends StatefulWidget with NavigationStates {
  @override
  _HelpState createState() => _HelpState();
}

User _user;
TextEditingController _searchController = TextEditingController();
DatabaseService _db;

class _HelpState extends State<Help> {
  @override
  Widget build(BuildContext context) {
    _user = Provider.of<User>(context);
    _db = DatabaseService(uid: _user.uid);
    return Scaffold(
        appBar: AppBar(
            title: Text('Ayuda',
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 30)),
            centerTitle: true,
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.only(bottomRight: Radius.circular(80)))),
        body: StreamBuilder(
            stream: Firestore.instance.collection('faq').snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return Loading();
              } else {
                return CustomScrollView(
                    slivers: _listToSliver(
                        context,
                        snapshot.data.documents
                            .where((d) => d.data['theme']
                                .contains(_searchController.text))
                            .toList()));
              }
            }),
        //extendBodyBehindAppBar: true,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _questionDialog(context),
          label: Text('Nueva pregunta'),
          icon: Icon(Icons.question_answer),
        ));
  }
}

void _questionDialog(BuildContext context) {
  TextEditingController _questionController = TextEditingController(),
      _themeController = TextEditingController();
  showDialog(
      context: context,
      child: AlertDialog(
          title: Text('Preguntar'),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                        controller: _themeController,
                        decoration: textInputDecoration.copyWith(
                            labelText: 'Tema central'),
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                        textCapitalization: TextCapitalization.sentences),
                    TextField(
                        controller: _questionController,
                        decoration:
                            textInputDecoration.copyWith(labelText: 'Pregunta'),
                        maxLines: 4,
                        textCapitalization: TextCapitalization.sentences),
                    RaisedButton(
                        child: Text('Preguntar'),
                        onPressed: () {
                          if (_themeController.text != '' &&
                              _questionController.text != '') {
                            _db.newQuestion(_themeController.text,
                                _questionController.text);
                            Navigator.pop(context);
                          }
                        })
                  ]))));
}

Padding _buildDivider() {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Container(
        width: double.infinity, height: 1, color: Colors.grey.shade100),
  );
}

Widget questTile(BuildContext context, DocumentSnapshot doc) {
  TextEditingController _newCommentController = TextEditingController();
  List<Widget> _comments = [
    Text('${doc.data['question']}', style: TextStyle(fontSize: 18))
  ];
  doc.data['answers'].forEach((a) {
    _comments.add(_buildDivider());
    _comments.add(Text(a));
  });
  _comments.add(_buildDivider());
  _comments.add(Padding(
    padding: const EdgeInsets.all(8.0),
    child: TextField(
        controller: _newCommentController,
        decoration: InputDecoration(hintText: 'Escribe un comentario...')),
  ));
  _comments.add(FlatButton(
      onPressed: () {
        if (_newCommentController.text != '') {
          _db.addComment(doc, _newCommentController.text);
        }
      },
      child: Text('Comentar')));
  return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Card(
          margin: EdgeInsets.fromLTRB(20, 6, 20, 0),
          child: ExpansionTile(
              title: Text(
                '${doc.data['theme']}',
                style: TextStyle(fontSize: 24),
              ),
              subtitle: Text('${doc.data['answers'].length} comentarios'),
              trailing: doc.data['author'] == _user.uid
                  ? IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => showDialog(
                          context: context,
                          child: AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            title: Text('Borrar'),
                            content: Text(
                                '¿Estás seguro que deseas borrar la pregunta?\nÉsta acción es irreversible'),
                            actions: <Widget>[
                              RaisedButton(
                                child: Text('Borrar'),
                                color: Colors.redAccent[700],
                                onPressed: () {
                                  _db.deleteQuestion(doc.documentID);
                                  Navigator.pop(context);
                                },
                              )
                            ],
                          )))
                  : null,//IconButton(icon: Icon(Icons.message), onPressed: null),
              children: _comments)));
}

List<Widget> _listToSliver(BuildContext context, List<DocumentSnapshot> list) {
  List<Widget> _list = [];
  //List<DocumentSnapshot> _query = list.where((d) => d.data['theme'].contains(_searchController.text)).toList();
  /*_list.add(SliverAppBar(
      title: Padding(
        padding: const EdgeInsets.only(left: 10, right: 20),
        child: TextField(
            controller: _searchController,
            cursorColor: Colors.white,
            style: TextStyle(color: Colors.white),
            onChanged: (s) {
              //print('Bef: ${_query.length}');_query = list.where((d) => d.data['theme'].contains(s)).toList();print(_query.length);
            },
            decoration: InputDecoration(
                labelText: 'Buscar',
                labelStyle: TextStyle(color: Colors.white),
                border: UnderlineInputBorder(borderSide: BorderSide.none))),
      ),
      centerTitle: true,
      floating: true,
      //pinned: true,
      leading: Padding(
        padding: EdgeInsets.only(left: 50),
        child: Icon(Icons.search),
      ),
      elevation: 5,
      backgroundColor: Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(bottomRight: Radius.circular(80)))));*/
  _list.add(SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
    return questTile(context, list[index]);
  }, childCount: list.length)));
  return _list;
}

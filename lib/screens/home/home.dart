import 'package:flutter/material.dart';
import 'package:grupospequenos/shared/constants.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grupospequenos/services/database.dart';
import 'package:grupospequenos/services/navigation_bloc.dart';

List<DocumentSnapshot> _mainList = [];
DocumentSnapshot getDoc(String uid) {
  return _mainList.singleWhere((d) => d.documentID == uid);
}

bool allow(String doc, String parent) {
  String _leader = doc;
  int _try = 0;
  while (_leader != '' && _try < 1000) {
    _try++;
    for (int i = 0; i < _mainList.length; i++) {
      if (_leader == parent) return true;
      if (_leader == _mainList[i].documentID)
        _leader = _mainList[i].data['leader'];
    }
  }
  return false;
}

List<DocumentSnapshot> getUsersList() {
  return _mainList;
}

TextEditingController _suggestController = TextEditingController();

class Home extends StatelessWidget with NavigationStates {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<QuerySnapshot>.value(
        value: DatabaseService().userData,
        child: StreamBuilder(
            stream: Firestore.instance
                .collection('userData')
                .orderBy('level')
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData)
                return Center(child: Icon(Icons.add_shopping_cart, size: 300));
              else {
                _mainList = [];
                snapshot.data.documents.forEach((doc) {
                  _mainList.add(doc);
                });
                return Scaffold(
                    appBar: AppBar(
                        title: Text('Grupos CAMI',
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 30)),
                        centerTitle: true,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(80)))),
                    body: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 70),
                        child: Column(children: <Widget>[
                          Text(
                              'La iniciativa de los grupos pequeños es una estrategia de evangelismo ágil, rápida y efectiva.',
                              style: TextStyle(
                                  fontWeight: FontWeight.w300, fontSize: 20)),
                          Text('\n\nA continuación verás un breve resumen\n'),
                          ExpansionTile(
                              title: Text('Mis grupos',
                                  style: TextStyle(fontSize: 20)),
                              leading: Icon(Icons.group, size: 50),
                              trailing: IconButton(
                                  icon: Icon(Icons.open_in_new),
                                  onPressed: () =>
                                      BlocProvider.of<NavigationBloc>(context)
                                          .add(NavigationEvents
                                              .MyGroupsClickedEvent)),
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                      'Aquí encontrarás la lista de todos tus grupos y de los líderes a tu cargo.'),
                                )
                              ]),
                          ExpansionTile(
                              title:
                                  Text('Mapa', style: TextStyle(fontSize: 20)),
                              leading: Icon(Icons.map, size: 50),
                              trailing: IconButton(
                                  icon: Icon(Icons.open_in_new),
                                  onPressed: () => BlocProvider.of<
                                          NavigationBloc>(context)
                                      .add(NavigationEvents.MapClickedEvent)),
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                      'Aquí encontrarás todos tus grupos, podrás ver su ubicación en el mapa y así planear dónde será tu próximo grupo.'),
                                )
                              ]),
                          ExpansionTile(
                              title: Text('Mi árbol',
                                  style: TextStyle(fontSize: 20)),
                              leading: Icon(Icons.nature_people, size: 50),
                              trailing: IconButton(
                                  icon: Icon(Icons.open_in_new),
                                  onPressed: () =>
                                      BlocProvider.of<NavigationBloc>(context)
                                          .add(NavigationEvents
                                              .MyTreeClickedEvent)),
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                      'Aquí encontrarás un diagrama con todos los líderes a tu cargo. Tú eres la raíz y así medirás tu desempeño individual.'),
                                )
                              ]),
                          ExpansionTile(
                              title: Text('Árbol general',
                                  style: TextStyle(fontSize: 20)),
                              leading: Icon(Icons.nature, size: 50),
                              trailing: IconButton(
                                  icon: Icon(Icons.open_in_new),
                                  onPressed: () => BlocProvider.of<
                                          NavigationBloc>(context)
                                      .add(NavigationEvents.TreeClickedEvent)),
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                      'Aquí encontrarás un diagrama con todos los líderes de tu iglesia. Podrás ver su perfil y contactarlos.'),
                                )
                              ]),
                          ExpansionTile(
                              title: Text('Configuración',
                                  style: TextStyle(fontSize: 20)),
                              leading: Icon(Icons.settings, size: 50),
                              trailing: IconButton(
                                  icon: Icon(Icons.open_in_new),
                                  onPressed: () =>
                                      BlocProvider.of<NavigationBloc>(context)
                                          .add(NavigationEvents
                                              .SettingsClickedEvent)),
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                      'Aquí podrás cambiar tu foto de perfil, editar tu información personal y definir tu privacidad.'),
                                )
                              ]),
                          ExpansionTile(
                              title:
                                  Text('Ayuda', style: TextStyle(fontSize: 20)),
                              leading: Icon(Icons.help_outline, size: 50),
                              trailing: IconButton(
                                  icon: Icon(Icons.open_in_new),
                                  onPressed: () => BlocProvider.of<
                                          NavigationBloc>(context)
                                      .add(NavigationEvents.HelpClickedEvent)),
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                      'Aquí encontrarás una lista de preguntas y comentarios realizados por la comunidad para ayuda mutua.'),
                                )
                              ]),
                          Text(
                              '\n\nEsperamos que tengas una experiencia única. Si tienes sugerencias'),
                          FlatButton(
                              child: Text('¡Avísanos!'),
                              onPressed: () => showModalBottomSheet(
                                  isScrollControlled: true,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20))),
                                  context: context,
                                  builder: (context) {
                                    return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Text('\nEnvía tu comentario\n',
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  fontSize: 20)),
                                          Padding(
                                            padding: EdgeInsets.all(8),
                                            child: TextField(
                                                controller: _suggestController,
                                                decoration: textInputDecoration
                                                    .copyWith(
                                                        labelText:
                                                            'Sugerencia'),
                                                maxLines: 4,
                                                textCapitalization:
                                                    TextCapitalization
                                                        .sentences),
                                          ),
                                          Padding(
                                              padding: EdgeInsets.only(
                                                  bottom: MediaQuery.of(context)
                                                      .viewInsets
                                                      .bottom),
                                              child: RaisedButton(
                                                  child: Text('Enviar'),
                                                  onPressed: () {
                                                    if (_suggestController
                                                            .text !=
                                                        '') {
                                                      DatabaseService()
                                                          .newSuggest(
                                                              _suggestController
                                                                  .text);
                                                      _suggestController.text =
                                                          '';
                                                      Navigator.pop(context);
                                                      showDialog(
                                                          context: context,
                                                          child: Dialog(
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20)),
                                                            child: Text(
                                                                '\n     Gracias, lo tendremos en cuenta     \n'),
                                                          ));
                                                    }
                                                  }))
                                        ]);
                                  }))
                        ])));
              }
            }));
  }
}

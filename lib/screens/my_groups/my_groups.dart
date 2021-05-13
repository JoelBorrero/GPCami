import 'dart:async';
import 'group_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grupospequenos/models/user.dart';
import 'package:grupospequenos/models/group.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grupospequenos/services/database.dart';
import 'package:grupospequenos/screens/home/home.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:grupospequenos/services/navigation_bloc.dart';

class Groups extends StatefulWidget with NavigationStates {
  @override
  _GroupsState createState() => _GroupsState();
}

DocumentSnapshot filter;
void setFilter(DocumentSnapshot filtering) {
  filter = filtering;
}

DocumentSnapshot get getFilter {
  return filter;
}

class _GroupsState extends State<Groups> {
  String uid = '';
  GeoPoint _newGroupLocation = GeoPoint(10.933, -74.797);
  LatLng _tempLocation;
  double _newGroupMembers;
  Completer<GoogleMapController> _controller = Completer();
  final List<String> days = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábados',
    'Domingos'
  ];
  final List<String> levels = [
    'Evangelismo',
    'Avance',
    'Liderazgo',
    'Instituto'
  ];
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    uid = user.uid;
    return StreamProvider<List<Group>>.value(
        value: DatabaseService().groupList,
        child: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
                actions: [
                  IconButton(
                      icon: Icon(Icons.filter_list),
                      color: Theme.of(context).primaryColorDark,
                      onPressed: () => _showFilter(context)),
                  IconButton(
                      icon: Icon(Icons.help_outline),
                      color: Theme.of(context).primaryColorDark,
                      onPressed: () => _showColors(context),
                      padding: EdgeInsets.only(right: 30))
                ],
                title: Text(
                  'Mis grupos',
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 30),
                ),
                centerTitle: true,
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.only(bottomRight: Radius.circular(80)))),
            body: GroupList(),
            floatingActionButton: FloatingActionButton.extended(
                icon: Icon(Icons.group_add),
                label: Text('Nuevo grupo'),
                onPressed: () {
                  _mainDialog(context);
                }),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            resizeToAvoidBottomPadding: false));
  }

  void _showColors(BuildContext context) {
    showDialog(
        context: context,
        child: Container(
            height: 300,
            width: 200,
            child: AlertDialog(
                title: Text('Colores'),
                content: Column(mainAxisSize: MainAxisSize.min, children: [
                  Row(children: [
                    Icon(Icons.color_lens, color: Colors.teal, size: 100),
                    Text('Evangelismo',
                        style: TextStyle(
                            color: Colors.teal,
                            fontSize: 20,
                            fontWeight: FontWeight.w600))
                  ]),
                  Row(children: [
                    Icon(Icons.color_lens, color: Colors.cyan, size: 100),
                    Text('Avance',
                        style: TextStyle(
                            color: Colors.cyan,
                            fontSize: 20,
                            fontWeight: FontWeight.w600))
                  ]),
                  Row(children: [
                    Icon(Icons.color_lens, color: Colors.amber, size: 100),
                    Text('Liderazgo',
                        style: TextStyle(
                            color: Colors.amber,
                            fontSize: 20,
                            fontWeight: FontWeight.w600))
                  ]),
                  Row(children: [
                    Icon(Icons.color_lens, color: Colors.pink, size: 100),
                    Text('Instituto',
                        style: TextStyle(
                            color: Colors.pink,
                            fontSize: 20,
                            fontWeight: FontWeight.w600))
                  ])
                ]),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)))));
  }

  void _showFilter(BuildContext context) {
    List childs = getUsersList()
        .where((u) => allow(u.documentID, uid) && u.documentID != uid)
        .toList();
    showDialog(
        context: context,
        child: Container(
            height: 300,
            width: 200,
            child: AlertDialog(
                title: Text('Filtrar'),
                actionsPadding: EdgeInsets.symmetric(horizontal: 100),
                actions: <Widget>[
                  RaisedButton(
                      child: Text('Borrar filtro'),
                      color: Colors.redAccent[700],
                      onPressed: filter == null
                          ? null
                          : () {
                              setState(() {
                                filter = null;
                              });
                              Navigator.pop(context);
                            })
                ],
                content: SingleChildScrollView(
                    child: ExpansionTile(
                        title: Text('Sólo ver grupos de'),
                        children: childs
                            .map((c) => RaisedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    filter = c;
                                  });
                                  Navigator.pop(context);
                                },
                                icon: Icon(filter == c
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked),
                                label: Text(
                                    '${c.data['name']} ${c.data['lastName']}')))
                            .toList())),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)))));
  }

  void _mainDialog(BuildContext context) {
    String _newGroupName = '',
        _newGroupDay = 'Lunes',
        _newGroupDirection = '',
        _newGroupLevel = 'Evangelismo',
        _newGroupLeader = uid;
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
              child: Padding(
                  padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          SizedBox(height: 20),
                          Text('Crear nuevo grupo',
                              style: TextStyle(
                                  fontSize: 24,
                                  color: Theme.of(context).primaryColor)),
                          TextField(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                labelText: 'Nombre personalizado',
                              ),
                              onChanged: (value) => setState(() {
                                    _newGroupName = value;
                                  })),
                          TextField(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                labelText: 'Dirección',
                              ),
                              onChanged: (value) => setState(() {
                                    _newGroupDirection = value;
                                  })),
                          Card(
                              child: ListTile(
                                  onTap: () {
                                    Navigator.pop(context);
                                    _mapDialog(context);
                                  },
                                  leading: Text(
                                      '(${_newGroupLocation.latitude},${_newGroupLocation.longitude})'),
                                  trailing: Icon(Icons.location_on,
                                      color: Theme.of(context).accentColor))),
                          DropdownButtonFormField(
                              value: days[0],
                              items: days.map((day) {
                                return DropdownMenuItem(
                                    value: day, child: Text('$day'));
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _newGroupDay = value;
                                });
                              },
                              icon: Icon(Icons.calendar_today,
                                  color: Theme.of(context).accentColor)),
                          TextField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                labelText: 'Miembros'),
                            onChanged: (m) => setState(() {
                              _newGroupMembers = double.tryParse(m);
                            }),
                          ),
                          DropdownButtonFormField(
                              value: levels[0],
                              items: levels.map((l) {
                                return DropdownMenuItem(
                                    value: l, child: Text(l));
                              }).toList(),
                              onChanged: (l) {
                                setState(() {
                                  _newGroupLevel = l;
                                });
                              },
                              icon: Icon(Icons.show_chart,
                                  color: Theme.of(context).accentColor)),
                          DropdownButtonFormField(
                              value: getDoc(uid),
                              items: getUsersList()
                                  .where((u) =>
                                          //{print(u.documentID);print(uid);return
                                          allow(u.documentID, uid) &&
                                              !u.data['autonomy'] ||
                                          u.documentID == uid
                                      //;}
                                      )
                                  .map((p) {
                                return DropdownMenuItem(
                                    value: p,
                                    child: Text(
                                        '${p.data['name']} ${p.data['lastName']}',
                                        style: TextStyle(
                                            color: uid == p.documentID
                                                ? Theme.of(context).primaryColor
                                                : Colors.black)));
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _newGroupLeader = value.documentID.toString();
                                });
                              },
                              icon: Icon(Icons.person,
                                  color: Theme.of(context).accentColor)),
                          SizedBox(
                              width: 320,
                              child: RaisedButton(
                                  onPressed: () {
                                    if (_newGroupName != '' &&
                                        _newGroupLocation != GeoPoint(0, 0) &&
                                        _newGroupDirection != '' &&
                                        _newGroupLeader != '') {
                                      DatabaseService(uid: uid).addGroup(
                                        _newGroupLeader,
                                        _newGroupName,
                                        _newGroupDay,
                                        _newGroupDirection,
                                        _newGroupLocation,
                                        _newGroupMembers ?? 0,
                                        _newGroupLevel,
                                      );
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: Text('Crear'),
                                  textColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(20)))),
                          SizedBox(height: 20)
                        ]),
                  )),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)));
        });
  }

  void _mapDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                  height: 500,
                  child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                      child: Align(
                          alignment: Alignment.bottomRight,
                          heightFactor: 0.3,
                          widthFactor: 2.5,
                          child: Stack(children: <Widget>[
                            GoogleMap(
                              mapType: MapType.normal,
                              initialCameraPosition: CameraPosition(
                                target: LatLng(_newGroupLocation.latitude,
                                    _newGroupLocation.longitude),
                                zoom: 14,
                              ),
                              onCameraMove: _onCameraMove,
                              onMapCreated: (GoogleMapController controller) {
                                try {
                                  _controller.complete(controller);
                                } catch (e) {}
                              },
                            ),
                            Align(
                                alignment: Alignment.topCenter,
                                child: Text(' Seleccionar ubicación ',
                                    style: TextStyle(
                                        color: Colors.white,
                                        backgroundColor:
                                            Theme.of(context).accentColor,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500))),
                            Align(
                                alignment: Alignment.bottomCenter,
                                child: RaisedButton(
                                    onPressed: () {
                                      _newGroupLocation = GeoPoint(
                                          _tempLocation.latitude,
                                          _tempLocation.longitude);
                                      Navigator.pop(context);
                                      _mainDialog(context);
                                    },
                                    child: Text('Continuar'),
                                    color: Theme.of(context).accentColor,
                                    textColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)))),
                            Center(
                                child: Icon(Icons.pin_drop,
                                    color: Theme.of(context).primaryColor,
                                    size: 40))
                          ])))));
        });
  }

  void _onCameraMove(CameraPosition pos) {
    setState(() {
      _tempLocation = pos.target;
    });
  }
}

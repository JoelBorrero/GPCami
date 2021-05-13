import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grupospequenos/models/user.dart';
import 'package:grupospequenos/shared/loading.dart';
import 'package:grupospequenos/shared/constants.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:grupospequenos/screens/home/home.dart';
import 'package:grupospequenos/services/database.dart';
import 'package:grupospequenos/services/navigation_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grupospequenos/screens/my_groups/my_groups.dart';
import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';

class EditForm extends StatefulWidget {
  final dynamic snap;
  const EditForm(this.snap);
  @override
  _EditFormState createState() => _EditFormState();
}

class _EditFormState extends State<EditForm> {
  final _formKey = GlobalKey<FormState>();
  String _currentName;
  String _currentLastName;
  String _currentPhone;
  @override
  Widget build(BuildContext context) {
    String _uid;
    try {
      _uid = widget.snap.documentID;
    } catch (e) {
      _uid = Provider.of<User>(context).uid;
    }
    DatabaseService db = DatabaseService(uid: _uid);
    return StreamBuilder<PersonalInfo>(
        stream: db.personalInfo,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            PersonalInfo personalInfo = snapshot.data;
            return Form(
                key: _formKey,
                child:
                    Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  Text('Información personal',
                      style: TextStyle(
                          fontSize: 24, color: Theme.of(context).primaryColor)),
                  SizedBox(height: 20),
                  TextFormField(
                      initialValue: personalInfo.name,
                      decoration:
                          textInputDecoration.copyWith(labelText: 'Nombre'),
                      validator: (val) => val.isEmpty ? 'Nombre' : null,
                      onChanged: (val) => setState(() => _currentName = val)),
                  SizedBox(height: 10),
                  TextFormField(
                      initialValue: personalInfo.lastName,
                      decoration:
                          textInputDecoration.copyWith(labelText: 'Apellido'),
                      validator: (val) => val.isEmpty ? 'Apellido' : null,
                      onChanged: (val) =>
                          setState(() => _currentLastName = val)),
                  SizedBox(height: 10),
                  TextFormField(
                      keyboardType: TextInputType.phone,
                      initialValue: personalInfo.phone,
                      decoration:
                          textInputDecoration.copyWith(labelText: 'Teléfono'),
                      onChanged: (val) => setState(() => _currentPhone = val)),
                  SizedBox(height: 20),
                  RaisedButton(
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          await DatabaseService(uid: _uid).updateUserData(
                              _currentName ?? personalInfo.name,
                              _currentLastName ?? personalInfo.lastName,
                              _currentPhone ?? personalInfo.phone,
                              personalInfo.leader,
                              personalInfo.level,
                              personalInfo.autonomy);
                          Navigator.pop(context);
                        }
                      },
                      child: Text('Guardar',
                          style: TextStyle(color: Colors.white)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)))
                ]));
          } else {
            return Loading();
          }
        });
  }
}

int _level = 1;
void showProfile(dynamic snap, BuildContext context) {
  print('show 1');
  String _uid = Provider.of<User>(context).uid;
  DatabaseService(uid: _uid)
      .personalInfo
      .first
      .then((value) => _level = value.level);
  bool _autonomy = snap.data['autonomy'];
  print('dialog');
  showDialog(
      context: context,
      child: Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 20),
                Text('${snap.data['name']} ${snap.data['lastName']}',
                    style: TextStyle(
                        color: Theme.of(context).primaryColor, fontSize: 20)),
                profilePic(snap, 100, context, false),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      IconButton(
                          icon: Icon(Icons.phone),
                          onPressed: snap.data['phone'] != ''
                              ? () {
                                  launch('tel:${snap.data['phone']}');
                                }
                              : null),
                      Text(snap.data['phone']),
                      IconButton(
                          color: Color.fromRGBO(27, 215, 65, 1),
                          disabledColor: Colors.grey,
                          icon: FaIcon(FontAwesomeIcons.whatsapp),
                          onPressed: snap.data['phone'].length == 10
                              ? () {
                                  FlutterOpenWhatsapp.sendSingleMessage(
                                      '+57${snap.data['phone']}',
                                      'Hola ${snap.data['name']}, conseguí tu número desde la app de nuestra iglesia');
                                }
                              : null)
                    ]),
                allow(snap.documentID, _uid) || snap.data['public']
                    ? RaisedButton(
                        child: Text('Ver grupos'),
                        onPressed: () {
                          Navigator.pop(context);
                          BlocProvider.of<NavigationBloc>(context)
                              .add(NavigationEvents.MyGroupsClickedEvent);
                          setFilter(snap);
                        })
                    : Container(),
                allow(snap.documentID, _uid) &&
                        snap.data['level'] - _level < 4 &&
                        snap.documentID.contains('child')
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                            RaisedButton.icon(
                                icon: Icon(Icons.edit),
                                label: Text('Editar'),
                                onPressed: !_autonomy || snap.documentID == _uid
                                    ? () {
                                        Navigator.pop(context);
                                        showEdit(snap, context);
                                      }
                                    : null),
                            RaisedButton.icon(
                                icon: FaIcon(_autonomy
                                    ? FontAwesomeIcons.child
                                    : FontAwesomeIcons.peopleArrows),
                                color: _autonomy
                                    ? Colors.redAccent[700]
                                    : Theme.of(context).primaryColor,
                                label: Text(
                                    _autonomy ? 'Manejar' : 'Independizar'),
                                onPressed: () {
                                  TextEditingController _codeController =
                                      TextEditingController();
                                  Navigator.pop(context);
                                  showDialog(
                                      context: context,
                                      child: Dialog(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          child: Padding(
                                              padding: EdgeInsets.all(20),
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: <Widget>[
                                                    Text(
                                                        _autonomy
                                                            ? 'Manejar'
                                                            : 'Independizar',
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor,
                                                            fontSize: 20)),
                                                    Text(_autonomy
                                                        ? '\nSi procedes, cancelarás la solicitud hecha previamente.\n\nPor seguridad, ingrese:'
                                                        : '\nÉstos son los cinco dígitos necesarios para el registro de ${snap.data['name']}.\n\nPor seguridad, ingrese:'),
                                                    Text(
                                                        '\n${snap.data['key']}\n',
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor,
                                                            fontSize: 24)),
                                                    TextFormField(
                                                        controller:
                                                            _codeController,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        maxLength: 5,
                                                        textAlign:
                                                            TextAlign.center,
                                                        decoration:
                                                            textInputDecoration
                                                                .copyWith(
                                                                    labelText:
                                                                        'Código')),
                                                    RaisedButton(
                                                        child:
                                                            Text('Confirmar'),
                                                        onPressed: () {
                                                          if (_codeController
                                                                  .text ==
                                                              snap.data[
                                                                  'key']) {
                                                            DatabaseService(
                                                                    uid: snap
                                                                        .documentID)
                                                                .askForAutonomy(
                                                                    !_autonomy);
                                                            Navigator.pop(
                                                                context);
                                                            showDialog(
                                                                context:
                                                                    context,
                                                                child: Dialog(
                                                                    insetPadding:
                                                                        EdgeInsets.all(
                                                                            20),
                                                                    child:
                                                                        Padding(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              20),
                                                                      child: Column(
                                                                          mainAxisSize: MainAxisSize.min,
                                                                          children: _autonomy
                                                                              ? <Widget>[
                                                                                  Text('¡Éxito!', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 20)),
                                                                                  Text('\nSe ha cancelado la solicitud\n'),
                                                                                  RaisedButton(child: Text('Continuar'), onPressed: () => Navigator.pop(context))
                                                                                ]
                                                                              : <Widget>[
                                                                                  Text('¡Éxito!', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 20)),
                                                                                  Text('\nSe ha creado una solicitud\n'),
                                                                                  Text('Éste es el código con el que ${snap.data['name']} podrá realizar su registro'),
                                                                                  Text('\n${snap.data['key']}\n', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 24)),
                                                                                  RaisedButton.icon(
                                                                                    color: Color.fromRGBO(27, 215, 65, 1),
                                                                                    disabledColor: Colors.grey,
                                                                                    disabledElevation: 0,
                                                                                    icon: FaIcon(FontAwesomeIcons.whatsapp, color: snap.data['phone'].length == 10 ? Colors.white : null),
                                                                                    label: Text('Enviar', style: TextStyle(color: snap.data['phone'].length == 10 ? Colors.white : null)),
                                                                                    onPressed: snap.data['phone'].length == 10 && snap.data['phone'].toString().startsWith('3')
                                                                                        ? () {
                                                                                            FlutterOpenWhatsapp.sendSingleMessage('+57${snap.data['phone']}', 'Hola ${snap.data['name']}, ya realicé la solicitud para que te puedas registrar en nuestra aplicación. El código que debes ingresar es ${snap.data['key']}');
                                                                                          }
                                                                                        : null,
                                                                                  ),
                                                                                  RaisedButton(child: Text('Continuar'), onPressed: () => Navigator.pop(context))
                                                                                ]),
                                                                    ),
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(20))));
                                                          }
                                                        })
                                                  ]))));
                                })
                          ])
                    : Container(),
                RaisedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cerrar'))
              ])));
}

void showEdit(dynamic snap, BuildContext context) {
  showModalBottomSheet(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(50), topRight: Radius.circular(50))),
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 60),
          child: EditForm(snap),
        );
      });
}

Widget profilePic(
    dynamic snapshot, double radius, BuildContext context, bool button) {
  Widget _icon() {
    try {
      print('ENTRó en try');
      return Stack(alignment: Alignment.center, children: [
        Image.network(snapshot.data['profilePicUrl'], fit: BoxFit.cover),
        RaisedButton(
            highlightElevation: 0,
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            color: Colors.transparent,
            elevation: 0,
            onPressed: () => button ? showProfile(snapshot, context) : {})
      ]);
    } catch (e) {
      print('ENTRó en try');
      return IconButton(
          icon: Icon(Icons.perm_identity,
              size: radius / 2, color: Colors.grey.shade200),
          onPressed: () => button ? showProfile(snapshot, context) : {});
    }
  }

  return CircleAvatar(
      child: ClipOval(
          child: SizedBox(width: radius, height: radius, child: _icon())),
      radius: radius / 2,
      backgroundColor: Colors.cyan[400]);
}

Widget chart(List<double> data, Color color) {
  List<charts.Series<double, num>> series = [
    charts.Series<double, int>(
      id: 'Asistencia',
      colorFn: (_, i) => charts.ColorUtil.fromDartColor(
          Color.lerp(color.withAlpha(150), color, i * 0.25)),
      areaColorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
      fillColorFn: (_, __) => charts.MaterialPalette.teal.shadeDefault,
      patternColorFn: (_, __) => charts.MaterialPalette.teal.shadeDefault,
      seriesColor: charts.MaterialPalette.teal.shadeDefault,
      fillPatternFn: (_, __) => charts.FillPatternType.forwardHatch,
      domainFn: (value, index) => index,
      measureFn: (value, _) => value,
      data: data,
      strokeWidthPxFn: (_, __) => 4,
    )
  ];
  return Container(
      height: 250,
      child: charts.LineChart(
        series,
        animate: true,
        selectionModels: [
          charts.SelectionModelConfig(
              //changedListener: (s) => a = s.selectedDatum.first.index,
              type: charts.SelectionModelType.action)
        ],
        domainAxis: charts.NumericAxisSpec(
            tickProviderSpec: charts.StaticNumericTickProviderSpec([
          charts.TickSpec(0, label: 'Día 1'),
          charts.TickSpec(1, label: 'Día 2'),
          charts.TickSpec(2, label: 'Día 3'),
          charts.TickSpec(3, label: 'Día 4'),
          charts.TickSpec(4, label: 'Día 5'),
        ])),
        primaryMeasureAxis: charts.NumericAxisSpec(
            tickProviderSpec:
                charts.BasicNumericTickProviderSpec(desiredTickCount: 6)),
      ));
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:grupospequenos/models/user.dart';
import 'package:grupospequenos/shared/loading.dart';
import 'package:grupospequenos/shared/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grupospequenos/services/database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:grupospequenos/services/navigation_bloc.dart';

class Settings extends StatefulWidget with NavigationStates {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    String imageUrl = 'users/${user.uid}/profilePic.jpeg';
    Future _setImage(ImageSource source) async {
      final image = await ImagePicker().getImage(source: source);
      if (image != null) {
        StorageReference storageReference =
            FirebaseStorage.instance.ref().child(imageUrl);
        StorageUploadTask uploadTask =
            storageReference.putFile(File(image.path));
        await uploadTask.onComplete;
        Firestore.instance.collection('userData').document(user.uid).setData({
          'profilePicUrl': (await storageReference.getDownloadURL()).toString()
        }, merge: true);
      }
    }

    return StreamProvider<QuerySnapshot>.value(
        value: DatabaseService().userData,
        child: Scaffold(
            appBar: AppBar(
                title: Text('Ajustes',
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 30)),
                centerTitle: true,
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.only(bottomRight: Radius.circular(80)))),
            body: StreamBuilder(
                stream: Firestore.instance
                    .collection('userData')
                    .document(user.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Loading();
                  } else {
                    return SingleChildScrollView(
                        child: Column(children: <Widget>[
                      SizedBox(height: 25),
                      Center(
                          child: Stack(
                              alignment: Alignment.bottomRight,
                              children: <Widget>[
                            profilePic(snapshot, 200, context, false),
                            FloatingActionButton(
                                child:
                                    Icon(Icons.camera_alt, color: Colors.white),
                                onPressed: () {
                                  showModalBottomSheet(
                                      context: context,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(50),
                                              topRight: Radius.circular(50))),
                                      builder: (context) {
                                        return Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: <Widget>[
                                              RaisedButton.icon(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    _setImage(
                                                        ImageSource.camera);
                                                  },
                                                  icon: Icon(Icons.camera_alt),
                                                  label: Text('Cámara')),
                                              RaisedButton.icon(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    _setImage(
                                                        ImageSource.gallery);
                                                  },
                                                  icon:
                                                      Icon(Icons.photo_library),
                                                  label: Text('Galería'))
                                            ]);
                                      });
                                })
                          ])),
                      Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          margin: EdgeInsets.fromLTRB(24, 48, 26, 8),
                          child: ListTile(
                              onTap: () => showEdit(snapshot, context),
                              title: Text(
                                  snapshot.data['name'] +
                                      ' ' +
                                      snapshot.data['lastName'],
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w300)),
                              trailing: Icon(Icons.edit, color: Colors.white)),
                          color: Theme.of(context).accentColor),
                      Card(
                          elevation: 4,
                          margin: EdgeInsets.fromLTRB(32, 8, 32, 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          child: Column(children: <Widget>[
                            ListTile(
                                leading: Icon(Icons.lock_outline,
                                    color: Theme.of(context).primaryColor),
                                title: Text('Cambiar contraseña'),
                                trailing: Icon(Icons.keyboard_arrow_right,
                                    color: Theme.of(context).primaryColor),
                                onTap: () {
                                  print('Cambiar contraseña');
                                }),
                            _buildDivider(),
                            ListTile(
                                leading: Icon(Icons.translate,
                                    color: Theme.of(context).primaryColor),
                                title: Text('Cambiar idioma'),
                                trailing: Icon(Icons.keyboard_arrow_right,
                                    color: Theme.of(context).primaryColor),
                                onTap: () {
                                  print('Cambiar idioma');
                                }),
                            _buildDivider(),
                            ListTile(
                                leading: Icon(Icons.location_on,
                                    color: Theme.of(context).primaryColor),
                                title: Text('Estado de GPS'),
                                trailing: Icon(Icons.keyboard_arrow_right,
                                    color: Theme.of(context).primaryColor),
                                onTap: () {
                                  print('Verificar gps');
                                })
                          ])),
                      SwitchListTile(
                          subtitle: Text(snapshot.data['public']
                              ? 'Cualquier persona puede ver tus grupos'
                              : 'Sólo tus líderes pueden ver tus grupos'),
                          secondary: Icon(snapshot.data['public']
                              ? Icons.public
                              : Icons.vpn_lock),
                          activeColor: Theme.of(context).primaryColorDark,
                          activeTrackColor: Theme.of(context).primaryColorLight,
                          inactiveThumbColor:
                              Theme.of(context).primaryColorLight,
                          inactiveTrackColor:
                              Theme.of(context).primaryColorDark,
                          contentPadding: EdgeInsets.all(32),
                          value: snapshot.data['public'],
                          title: Text(snapshot.data['public']
                              ? 'Perfil público'
                              : 'Sólo mis líderes'),
                          onChanged: (p) {
                            DatabaseService(uid: user.uid).setPublic(p);
                          })
                    ]));
                  }
                })));
  }

  Container _buildDivider() {
    return Container(
        width: double.infinity, height: 1, color: Colors.grey.shade200);
  }
}

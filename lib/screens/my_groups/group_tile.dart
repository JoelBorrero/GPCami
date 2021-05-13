import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grupospequenos/models/user.dart';
import 'package:grupospequenos/models/group.dart';
import 'package:grupospequenos/shared/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grupospequenos/shared/constants.dart';
import 'package:grupospequenos/screens/home/home.dart';
import 'package:grupospequenos/services/database.dart';
import 'package:grupospequenos/screens/map/groups_map.dart';

class GroupTile extends StatelessWidget {
  final Group group;
  GroupTile({this.group});
  @override
  Widget build(BuildContext context) {
    DocumentSnapshot _document = getDoc(group.leader);
    bool _editable = allow(group.leader, Provider.of<User>(context).uid) &&
            !_document.data['autonomy'] ||
        group.leader == Provider.of<User>(context).uid;
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            margin: EdgeInsets.fromLTRB(20, 6, 20, 0),
            child: ExpansionTile(
                leading: CircleAvatar(
                    radius: 25,
                    backgroundColor: group.color,
                    child: Text(group.members[0].toString(),
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold))),
                title: Text(group.name),
                subtitle: Text(group.direction),
                trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text('${_document.data['name']}'),
                      _editable
                          ? Icon(Icons.edit, color: group.color)
                          : Icon(Icons.block, color: Colors.grey)
                    ]),
                children: <Widget>[
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.label, color: group.color),
                    Text(group.level)
                  ]),
                  stars(group.members[0] / 8 * 5, 25),
                  Text('${group.day}'),
                  Text('Últimas cinco asistencias'),
                  chart(group.members.sublist(1, 6), group.color),
                  _editable
                      ? RaisedButton.icon(
                        icon: Icon(Icons.multiline_chart),
                        label: Text('Reportar asistencia'),
                          onPressed: () => _addMembers(context, group))
                      : SizedBox(height: 20),
                  _editable
                      ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            RaisedButton.icon(
                              icon:Icon(Icons.edit),
                                label: Text('Editar'),
                                onPressed: null),
                            RaisedButton.icon(
                              icon:Icon(Icons.delete),
                                label: Text('Eliminar'),
                                color: Colors.redAccent[700],
                                onPressed: null)
                          ],
                        )
                      : Container()
                ])));
  }
}

void _addMembers(BuildContext context, Group group) {
  TextEditingController _controller = TextEditingController();
  showDialog(
      context: context,
      builder: (context) {
        return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
                padding: EdgeInsets.fromLTRB(50, 0, 50, 12),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('\nReportar asistencia\n',
                          style: TextStyle(
                              fontSize: 24,
                              color: Theme.of(context).primaryColor)),
                      TextField(
                          controller: _controller,
                          keyboardType: TextInputType.number,
                          decoration: textInputDecoration.copyWith(
                              labelText: 'Última asistencia')),
                      RaisedButton(
                          child: Text('Confirmar'),
                          onPressed: () {
                            if(double.tryParse(_controller.text)!=null){
                            group.addMembers(double.parse(_controller.text));
                            DatabaseService(uid: Provider.of<User>(context).uid)
                                .addGroupMembers(
                                    double.parse(_controller.text), group);}
                            Navigator.pop(context);
                          })
                    ])));
      });
}

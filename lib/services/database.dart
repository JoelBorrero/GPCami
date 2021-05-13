import 'dart:math';
import 'package:grupospequenos/models/user.dart';
import 'package:grupospequenos/models/group.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grupospequenos/shared/constants.dart';

class DatabaseService {
  final String uid;
  DatabaseService({this.uid});
  //Collection reference
  final CollectionReference userDataCollection =
          Firestore.instance.collection('userData'),
      groupsDataCollection = Firestore.instance.collection('groupsData'),
      faqCollection = Firestore.instance.collection('faq'),
      suggestCollection = Firestore.instance.collection('suggest');
  //USER FUNCTIONS
  Future updateUserData(String name, String lastName, String phone,
      String leader, int level, bool autonomy) async {
    if (leader == '') getPending();
    return await userDataCollection.document(uid).setData({
      'autonomy': autonomy,
      'lastName': format(lastName),
      'leader': leader,
      'level': level,
      'name': format(name),
      'phone': phone,
      'public': false
    }, merge: true);
  }

  Future setPublic(bool p) async {
    return await userDataCollection
        .document(uid)
        .setData({'public': p}, merge: true);
  }

  Future getPending() async {
    int pending = await userDataCollection.getDocuments().then((d) => d
        .documents
        .where((dc) => dc.documentID.contains('child'))
        .where((doc) => doc.data['autonomy'] && !doc.data['waiting'])
        .toList()
        .length);
    await userDataCollection
        .document(uid)
        .setData({'pending': pending}, merge: true);
  }

  Future<int> getChildIndex(bool first) async {
    List<DocumentSnapshot> _docs =
        await userDataCollection.getDocuments().then((d) => d.documents);
    int _max = 0;
    if (first) {
      for (int i = 0; i < _docs.length; i++) {
        if (!await userDataCollection
            .document('child$i')
            .get()
            .then((value) => value.exists)) {
          return i;
        }
      }
    } else {
      _docs.where((d) => d.documentID.contains('child')).forEach((doc) {
        print(doc.documentID);
        if (int.parse(doc.documentID.substring(5, doc.documentID.length)) >
            _max) {
          _max = int.parse(doc.documentID.substring(5, doc.documentID.length));
          print(_max);
        }
      });
    }
    return _max;
  }

  Future createTempUser(String name, String lastName, String phone,
      String leader, int level) async {
    int _childs = await getChildIndex(false) + 1, _last = 0;
    Random _rnd = Random();
    String _securityCode =
        '${_rnd.nextInt(9)}${_rnd.nextInt(9)}${_rnd.nextInt(9)}${_rnd.nextInt(9)}${_rnd.nextInt(9)}';
    while (_last < _childs) {
      if (await userDataCollection.document('child$_last').get().then((value) {
        if (value.exists) {
          return value.data['key'] == _securityCode;
        }
        return false;
      })) {
        _last = -1;
        _securityCode =
            '${_rnd.nextInt(9)}${_rnd.nextInt(9)}${_rnd.nextInt(9)}${_rnd.nextInt(9)}${_rnd.nextInt(9)}';
      }
      _last++;
    }
    int _min = await getChildIndex(true);
    return await userDataCollection.document('child$_min').setData({
      'autonomy': false,
      'key': _securityCode,
      'lastName': format(lastName),
      'leader': leader,
      'level': level,
      'name': format(name),
      'phone': phone,
      'public': false,
      'waiting': false
    });
  }

  Future createExistingUser(
      DocumentSnapshot doc, String name, String lastName, String phone) async {
    await updateUserData(
        name, lastName, phone, doc.data['leader'], doc.data['level'], true);
    await userDataCollection
        .getDocuments()
        .then((d) => d.documents.forEach((dc) {
              if (dc.data['leader'] == doc.documentID) {
                userDataCollection
                    .document(dc.documentID)
                    .setData({'leader': uid}, merge: true);
              }
            }));
    await groupsDataCollection
        .getDocuments()
        .then((d) => d.documents.forEach((dc) {
              if (dc.data['leader'] == doc.documentID) {
                userDataCollection
                    .document(dc.documentID)
                    .setData({'leader': uid}, merge: true);
              }
            }));
    await userDataCollection.document(doc.documentID).delete();
  }

  Future askForAutonomy(bool a) async {
    return await userDataCollection
        .document(uid)
        .setData({'autonomy': a, 'waiting': false}, merge: true);
  }

  Future approveAutonomy(bool approve) async {
    return await userDataCollection.document(uid).setData(
        approve ? {'waiting': true} : {'autonomy': false, 'waiting': false},
        merge: true);
  }

  Future<DocumentSnapshot> getByKey(String key) async {
    try {
      return await userDataCollection.getDocuments().then(
          (d) => d.documents.singleWhere((doc) => doc.data['key'] == key));
    } catch (e) {
      return null;
    }
  }

  Future newQuestion(String theme, String question) async {
    return await faqCollection.document().setData({
      'answers': [],
      'author': this.uid,
      'question': question,
      'theme': theme
    });
  }

  Future newSuggest(String suggest) async {
    return await suggestCollection.document().setData({'suggest': suggest});
  }

  Future addComment(DocumentSnapshot doc, String comment) async {
    List<String> _ans = [];
    doc.data['answers'].forEach((a) => _ans.add(a));
    _ans.add(comment);
    return await faqCollection
        .document(doc.documentID)
        .setData({'answers': _ans}, merge: true);
  }

  Future deleteQuestion(String quest) async {
    return await faqCollection.document(quest).delete();
  }

  //PersonalInfo from snapshot
  PersonalInfo _personalInfoFromSnapshot(DocumentSnapshot snapshot) {
    return PersonalInfo(
        uid: uid,
        name: snapshot.data['name'],
        lastName: snapshot.data['lastName'],
        phone: snapshot.data['phone'],
        leader: snapshot.data['leader'],
        level: snapshot.data['level'],
        autonomy: snapshot.data['autonomy']);
  }

  //Get user doc stream
  Stream<PersonalInfo> get personalInfo {
    return userDataCollection
        .document(uid)
        .snapshots()
        .map(_personalInfoFromSnapshot);
  }

  //Get userData stream
  Stream<QuerySnapshot> get userData {
    return userDataCollection.snapshots();
  }

  //GROUPS FUNCTIONS
  //Get groupList stream
  Stream<List<Group>> get groupList {
    return groupsDataCollection.snapshots().map(_groupListFromSnapshot);
  }

  //GroupList from snapshot
  List<Group> _groupListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc) {
      List<double> _members = [];
      for (int i = 0; i < doc.data['members'].length; i++) {
        _members.add(doc.data['members'][i] + .0);
      }
      return Group(
          id: doc.documentID,
          leader: doc.data['leader'],
          name: doc.data['name'],
          day: doc.data['day'],
          direction: doc.data['direction'],
          location: doc.data['location'],
          members: _members,
          level: doc.data['level']);
    }).toList();
  }

  Future addGroup(String leader, String name, String day, String direction,
      GeoPoint location, double members, String level) {
    return groupsDataCollection.add({
      'leader': leader,
      'name': format(name),
      'day': day,
      'direction': format(direction),
      'location': location,
      'members': [members, members, members, members, members, members],
      'level': level,
    });
  }

  void addGroupMembers(double newMem, Group group) async {
    try {
      await groupsDataCollection
          .document(group.id)
          .setData({'members': group.members}, merge: true);
    } catch (e) {}
  }
}

import 'group.dart';

class User {
  final String uid;
  User({this.uid});
}

class PersonalInfo {
  final String uid;
  final String name;
  final String lastName;
  final String phone;
  final String leader;
  final int level;
  final bool autonomy;
  final List<Group> groups;
  PersonalInfo(
      {this.uid,
      this.name,
      this.lastName,
      this.phone,
      this.leader,
      this.level,
      this.autonomy,
      this.groups});
}

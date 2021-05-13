import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  final String id, leader, name, day, direction;
  final GeoPoint location;
  List<double> members;
  String level; //1=Evangelismo, 2=Avance, 3=Liderazgo, 4=Instituto
  void promote(bool b) {
    if (this.level == 'Evangelismo' && b) {
      this.level = 'Avance';
    } else if (this.level == 'Avance') {
      this.level = b ? 'Instituto' : 'Evangelismo';
    } else if (this.level == 'Instituto') {
      this.level = b ? 'Liderazgo' : 'Avance';
    } else if (this.level == 'Liderazgo' && !b) {
      this.level = 'Instituto';
    }
  }

  Group(
      {this.id,
      this.leader,
      this.name,
      this.day,
      this.direction,
      this.location,
      this.members,
      this.level});
  Color get color {
    if (this.level == 'Evangelismo') {
      return Colors.teal;
    } else if (this.level == 'Avance') {
      return Colors.cyan;
    } else if (this.level == 'Instituto') {
      return Colors.pink;
    } else if (this.level == 'Liderazgo') {
      return Colors.amber;
    } else {
      return Colors.blue;
    }
  }

  void addMembers(double newMem) {
    for (int i = 0; i < 5; i++) {
      this.members[i] = this.members[i + 1];
    }
    this.members[5] = newMem;
    this.members[0] = 0.0;
    for (int i = 1; i < 6; i++) {
      this.members[0] += this.members[i] / 5;
    }
    this.members[0]=double.parse(this.members[0].toStringAsFixed(1));
  }
}

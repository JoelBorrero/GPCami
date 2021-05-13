import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:grupospequenos/models/user.dart';
import 'package:grupospequenos/models/group.dart';
import 'package:grupospequenos/shared/loading.dart';
import 'package:grupospequenos/screens/home/home.dart';
import 'package:grupospequenos/screens/my_groups/my_groups.dart';
import 'package:grupospequenos/screens/my_groups/group_tile.dart';

class GroupList extends StatefulWidget {
  @override
  _GroupListState createState() => _GroupListState();
}

List<Group> groupList = [], myGroups = [], childsGroups = [];

class _GroupListState extends State<GroupList> {
  @override
  Widget build(BuildContext context) {
    try {
      String _uid = Provider.of<User>(context).uid,_filter='';
      groupList = Provider.of<List<Group>>(context);
      groupList.sort((a, b) => a.leader.compareTo(b.leader));
      myGroups = groupList.where((e) => e.leader == _uid).toList();
      childsGroups.clear();
      if(getFilter!=null){_filter=getFilter.documentID;}
      groupList.forEach((g) {
        if (g.leader != _uid && allow(g.leader, _uid)||g.leader==_filter) {
          if (filter == null) {
            childsGroups.add(g);
          } else {
            if (g.leader == filter.documentID) {
              childsGroups.add(g);
            }
          }
        }
      });
      childsGroups.sort((a, b) => a.leader.compareTo(b.leader));
      return CustomScrollView(
        slivers: _listToSliver(context),
      );
    } catch (e) {
      print(e);
      return Loading();
    }
  }
}

List<Widget> _listToSliver(BuildContext context) {
  List<Widget> _list = [];
  _list.add(SliverAppBar(
      title: Text('Propios'),
      backgroundColor: Theme.of(context).primaryColor,
      centerTitle: true,
      floating: true,
      elevation: 5,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(bottomRight: Radius.circular(80)))));
  _list.add(SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
    return GroupTile(group: myGroups[index]);
  }, childCount: myGroups.length)));
  _list.add(SliverToBoxAdapter(
      child: Container(
          alignment: Alignment.center,
          child: Text(
              filter != null
                  ? '\n${filter.data['name']} ${filter.data['lastName']}\n'
                  : '\nDelegados\n',
              style: TextStyle(color: Colors.white, fontSize: 20)),
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Theme.of(context).accentColor,
                Theme.of(context).primaryColor
              ]),
              borderRadius:
                  BorderRadius.only(bottomRight: Radius.circular(80))))));
  _list.add(SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
    return GroupTile(group: childsGroups[index]);
  }, childCount: childsGroups.length)));
  _list.add(SliverToBoxAdapter(child:SizedBox(height:70)));
  return _list;
}

import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grupospequenos/models/user.dart';
import 'package:grupospequenos/shared/loading.dart';
import 'package:grupospequenos/shared/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grupospequenos/services/navigation_bloc.dart';
import 'package:grupospequenos/screens/home/sidebar/menu_item.dart';

class SideBar extends StatefulWidget {
  @override
  _SideBarState createState() => _SideBarState();
}

class _SideBarState extends State<SideBar>
    with SingleTickerProviderStateMixin<SideBar> {
  AnimationController _animationController;
  StreamController<bool> isSideBarOpenStreamController;
  Stream<bool> isSideBarOpenStream;
  StreamSink<bool> isSideBarOpenSink;
  final bool isSideBarOpen = true;
  final _animationDuration = const Duration(milliseconds: 500);
  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: _animationDuration);
    isSideBarOpenStreamController = PublishSubject<bool>();
    isSideBarOpenStream = isSideBarOpenStreamController.stream;
    isSideBarOpenSink = isSideBarOpenStreamController.sink;
  }

  @override
  void dispose() {
    _animationController.dispose();
    isSideBarOpenStreamController.close();
    isSideBarOpenSink.close();
    super.dispose();
  }

  void onIconPressed() {
    final animationStatus = _animationController.status;
    final isAnimationCompleted = animationStatus == AnimationStatus.completed;
    if (isAnimationCompleted) {
      isSideBarOpenSink.add(false);
      _animationController.reverse();
    } else {
      isSideBarOpenSink.add(true);
      _animationController.forward();
    }
  }

  User user;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    user = Provider.of<User>(context);
    return StreamBuilder(
        stream: Firestore.instance
            .collection('userData')
            .document(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            String name = snapshot.data['name'];
            String lastName = snapshot.data['lastName'];
            String phone = snapshot.data['phone'];
            return StreamBuilder<bool>(
                initialData: false,
                stream: isSideBarOpenStream,
                builder: (context, isSidebarOpenAsync) {
                  return AnimatedPositioned(
                      duration: _animationDuration,
                      top: 0,
                      bottom: 0,
                      left: isSidebarOpenAsync.data ? 0 : -size.width,
                      right: isSidebarOpenAsync.data ? 0 : size.width - 45,
                      child: Row(
                        children: <Widget>[
                        Expanded(
                            child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [
                                  Theme.of(context).primaryColorDark,
                                  Theme.of(context).accentColor
                                ])),
                                child: Stack(
                                  children: [
                                  Container(
                                      child: SizedBox(
                                          width: size.width, height: 200),
                                      decoration: BoxDecoration(
                                          gradient: LinearGradient(colors: [
                                            Theme.of(context).primaryColorDark,
                                            Theme.of(context).accentColor
                                          ]),
                                          image: DecorationImage(
                                              image: AssetImage(
                                                  'assets/images/LogoCAMI.png')))),
                                  ListView(children: <Widget>[
                                    ListTile(
                                        contentPadding: EdgeInsets.only(
                                            top: size.height / 5),
                                        leading: CircleAvatar(
                                            child: profilePic(
                                                snapshot, 50, context, false)),
                                        title: Text('$name $lastName',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 30,
                                                fontWeight: FontWeight.bold)),
                                        subtitle: Text('$phone',
                                            style: TextStyle(
                                                color: Colors.white30,
                                                fontSize: 20))),
                                    _divider(),
                                    MenuItem(
                                        icon: Icons.home,
                                        title: 'Inicio',
                                        onTap: () {
                                          onIconPressed();
                                          BlocProvider.of<NavigationBloc>(
                                                  context)
                                              .add(NavigationEvents
                                                  .HomePageClickedEvent);
                                        }),
                                    MenuItem(
                                        icon: Icons.group,
                                        title: 'Mis grupos',
                                        onTap: () {
                                          onIconPressed();
                                          BlocProvider.of<NavigationBloc>(
                                                  context)
                                              .add(NavigationEvents
                                                  .MyGroupsClickedEvent);
                                        }),
                                    MenuItem(
                                        icon: Icons.map,
                                        title: 'Mapa',
                                        onTap: () {
                                          onIconPressed();
                                          BlocProvider.of<NavigationBloc>(
                                                  context)
                                              .add(NavigationEvents
                                                  .MapClickedEvent);
                                        }),
                                    MenuItem(
                                        icon: Icons.nature_people,
                                        title: 'Mi árbol',
                                        onTap: () {
                                          onIconPressed();
                                          BlocProvider.of<NavigationBloc>(
                                                  context)
                                              .add(NavigationEvents
                                                  .MyTreeClickedEvent);
                                        }),
                                    MenuItem(
                                        icon: Icons.nature,
                                        title: 'Árbol general',
                                        onTap: () {
                                          onIconPressed();
                                          BlocProvider.of<NavigationBloc>(
                                                  context)
                                              .add(NavigationEvents
                                                  .TreeClickedEvent);
                                        }),
                                    snapshot.data['leader'] == ''
                                        ? MenuItem(
                                            icon: Icons.notifications_active,
                                            title:
                                                'Solicitudes ( ${snapshot.data['pending']} )',
                                            onTap: () {
                                              onIconPressed();
                                              BlocProvider.of<NavigationBloc>(
                                                      context)
                                                  .add(NavigationEvents
                                                      .NotificationsClickedEvent);
                                            })
                                        : Container(),
                                    _divider(),
                                    MenuItem(
                                        icon: Icons.settings,
                                        title: 'Configuración',
                                        onTap: () {
                                          onIconPressed();
                                          BlocProvider.of<NavigationBloc>(
                                                  context)
                                              .add(NavigationEvents
                                                  .SettingsClickedEvent);
                                        }),
                                    MenuItem(
                                        icon: Icons.help,
                                        title: 'Ayuda',
                                        onTap: () {
                                          onIconPressed();
                                          BlocProvider.of<NavigationBloc>(
                                                  context)
                                              .add(NavigationEvents
                                                  .HelpClickedEvent);
                                        }),
                                    MenuItem(
                                        icon: Icons.exit_to_app,
                                        title: 'Salir',
                                        onTap: () {
                                          onIconPressed();
                                          BlocProvider.of<NavigationBloc>(
                                                  context)
                                              .add(NavigationEvents.LogOut);
                                        })
                                  ])
                                ]))),
                        Align(
                            alignment: Alignment(0, -0.9),
                            child: GestureDetector(
                                onTap: () {
                                  onIconPressed();
                                },
                                child: ClipPath(
                                    clipper: CustomMenuClipper(),
                                    child: Container(
                                        width: 35,
                                        height: 110,
                                        color: Theme.of(context).accentColor,
                                        alignment: Alignment.centerLeft,
                                        child: AnimatedIcon(
                                            icon: AnimatedIcons.menu_close,
                                            progress: _animationController.view,
                                            color: Colors.white,
                                            size: 25)))))
                      ]));
                });
          } else {
            return Loading();
          }
        });
  }
}

Widget _divider() {
  return Divider(
      height: 64,
      thickness: 0.5,
      color: Colors.blue[200],
      indent: 32,
      endIndent: 32);
}

class CustomMenuClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Paint paint = Paint();
    paint.color = Colors.white;
    final width = size.width;
    final height = size.height;
    Path path = Path();
    path.moveTo(0, 0);
    path.quadraticBezierTo(0, 8, 10, 16);
    path.quadraticBezierTo(width - 1, height / 2 - 20, width, height / 2);
    path.quadraticBezierTo(width + 1, height / 2 + 20, 10, height - 16);
    path.quadraticBezierTo(0, height - 8, 0, height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

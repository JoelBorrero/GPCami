/*
Filtro en mis grupos y mapas
Lid-inst
Error add
Chat interno ayuda
*/
import 'package:bloc/bloc.dart';
import 'package:grupospequenos/screens/help.dart';
import 'package:grupospequenos/services/auth.dart';
import 'package:grupospequenos/screens/map/map.dart';
import 'package:grupospequenos/screens/home/home.dart';
import 'package:grupospequenos/screens/tree/tree.dart';
import 'package:grupospequenos/screens/tree/my_tree.dart';
import 'package:grupospequenos/screens/notifications.dart';
import 'package:grupospequenos/screens/settings/settings.dart';
import 'package:grupospequenos/screens/my_groups/my_groups.dart';

enum NavigationEvents {
  HomePageClickedEvent,
  MyGroupsClickedEvent,
  MapClickedEvent,
  MyTreeClickedEvent,
  TreeClickedEvent,
  NotificationsClickedEvent,
  SettingsClickedEvent,
  HelpClickedEvent,
  LogOut
}

abstract class NavigationStates {}

class NavigationBloc extends Bloc<NavigationEvents, NavigationStates> {
  final AuthService _auth = AuthService();
  @override
  NavigationStates get initialState => Home();

  @override
  Stream<NavigationStates> mapEventToState(NavigationEvents event) async* {
    switch (event) {
      case NavigationEvents.HomePageClickedEvent:
        yield Home();
        break;
      case NavigationEvents.MyGroupsClickedEvent:
        yield Groups();
        break;
      case NavigationEvents.MapClickedEvent:
        yield Map();
        break;
      case NavigationEvents.MyTreeClickedEvent:
        yield MyTree();
        break;
      case NavigationEvents.TreeClickedEvent:
        yield Tree();
        break;
      case NavigationEvents.NotificationsClickedEvent:
        yield Notifications();
        break;
      case NavigationEvents.SettingsClickedEvent:
        yield Settings();
        break;
      case NavigationEvents.HelpClickedEvent:
        yield Help();
        break;
      case NavigationEvents.LogOut:
        _auth.signOut();
        break;
    }
  }
}

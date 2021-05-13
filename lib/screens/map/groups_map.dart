import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:grupospequenos/models/user.dart';
import 'package:grupospequenos/shared/loading.dart';
import 'package:provider/provider.dart';
import 'package:grupospequenos/models/group.dart';

class GroupsMap extends StatefulWidget {
  @override
  _GroupsMapState createState() => _GroupsMapState();
}

class _GroupsMapState extends State<GroupsMap> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> markers = new Set<Marker>();
  List<Group> groups = [];
  double _latProm=0,_lngProm=0;
  @override
  Widget build(BuildContext context) {
    try {
      String uid = Provider.of<User>(context).uid;
      groups = Provider.of<List<Group>>(context)
          .where((g) => g.leader == uid)
          .toList();
      groups.forEach((g) {
        _latProm+=g.location.latitude/groups.length;
        _lngProm+=g.location.longitude/groups.length;
        markers.add(new Marker(
            markerId: MarkerId(
              g.location.latitude.toString() + g.location.longitude.toString(),
            ),
            position: LatLng(g.location.latitude, g.location.longitude),
            infoWindow: InfoWindow(title: g.name, snippet: g.day),
            icon: BitmapDescriptor.defaultMarkerWithHue(g.color == Colors.teal
                ? BitmapDescriptor.hueGreen
                : g.color == Colors.cyan
                    ? BitmapDescriptor.hueCyan
                    : g.color == Colors.amber
                        ? BitmapDescriptor.hueOrange
                        : BitmapDescriptor.hueRose)));
      });
      return Stack(
        children: <Widget>[
          _googleMap(context),
          _buildContainer(context),
        ],
      );
    } catch (e) {
      return Loading();
    }
  }

  Widget _googleMap(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: LatLng(_latProm, _lngProm),
          zoom: 14,
        ),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: this.markers,
        myLocationButtonEnabled: true,
        myLocationEnabled: true,
      ),
    );
  }

  Widget _buildContainer(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
          margin: EdgeInsets.symmetric(vertical: 20),
          height: 150,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: groups.length,
              itemBuilder: (context, index) {
                return Padding(
                    padding: EdgeInsets.all(8),
                    child: _box(
                      groups[index],
                    ));
              })),
    );
  }

  Widget _box(Group group) {
    return GestureDetector(
      onTap: () {
        _goToLocation(group.location);
      },
      child: Container(
        child: FittedBox(
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Icon(Icons.home, color: group.color.withAlpha(120), size: 80),
                Container(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Container(
                      child: _myDetailsContainer(group),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _myDetailsContainer(Group group) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 8),
          child: Container(
            child: Text(group.name,
                style: TextStyle(
                  fontSize: 24,
                  color: group.color,
                  fontWeight: FontWeight.bold,
                )),
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          group.direction,
          style: TextStyle(fontSize: 20),
        ),
        Text('Asistencia ${group.members[0]}'),
        stars(group.members[0] / 8 * 5, 15),
        Text(group.day)
      ],
    );
  }

  Future<void> _goToLocation(GeoPoint point) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(point.latitude, point.longitude),
        zoom: 15,
        tilt: 50,
        bearing: 45)));
    controller
        .showMarkerInfoWindow(MarkerId('${point.latitude}${point.longitude}'));
  }
}

Row stars(double prom, double size) {
  List<Widget> stars = [];
  for (var i = 0; i < 5; i++) {
    if (prom - i >= 1) {
      stars.add(Icon(
        Icons.star,
        color: Colors.amber,
        size: size,
      ));
    } else if (prom - i > 0.4) {
      stars.add(Icon(
        Icons.star_half,
        color: Colors.amber,
        size: size,
      ));
    } else {
      stars.add(Icon(
        Icons.star_border,
        color: Colors.amber,
        size: size,
      ));
    }
  }
  return Row(mainAxisAlignment: MainAxisAlignment.center, children: stars);
}

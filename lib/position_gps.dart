import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

// Affiche une alerte si le gps n'est pas activé
Future<void> afficheDialogAlert(context, String description) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Attention'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(description)
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Ok'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

// Affiche la position de l'utilisateur
Future<Position> affichePosition(context) async {
  bool serviceEnabled;
  LocationPermission permission;

  // Check si le gps est actif
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {

    afficheDialogAlert(context, "Service gps désactivé.");
    return Future.error('Location services are disabled.');
  }

  // Vérifie les permissions de l'utilisateur
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {

    // Demande à l'utilisateur l'autorisation d'utiliser le gps
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {

      afficheDialogAlert(context, "Permissions refusées.");
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {

    afficheDialogAlert(context, "Permissions définitivement refusées.");
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}

class PositionGps extends StatefulWidget {
  const PositionGps({Key? key}) : super(key: key);

  @override
  _PositionGpsState createState() => _PositionGpsState();
}

class _PositionGpsState extends State<PositionGps> {
  ButtonStyle style =
  ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));
  late LocationPermission permission;
  String longitude = "";
  String latitude = "";

  void changePositions(String longitudeParam, String latitudeParam)
  {
    setState(() {
      longitude = longitudeParam;
      latitude = latitudeParam;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'Latitude : ' + latitude,
        ),
        Text(
          'Longitude : ' + longitude,
        ),
        const Text(
          'GPS : ',
        ),
        ElevatedButton(
          onPressed: () async {

            Position positionActuelle = await affichePosition(context);
            changePositions(positionActuelle.longitude.toString(), positionActuelle.latitude.toString());
          },
          child: const Text('GO'),
          style: style,
        )
      ],
    );
  }
}

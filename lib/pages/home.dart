import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.latitudeInit,
    required this.longitudeInit,
    required this.title,
  });

  final String title;
  final double latitudeInit;
  final double longitudeInit;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  late double _latitude;
  late double _longitude;
  late MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    _latitude = widget.latitudeInit;
    _longitude = widget.longitudeInit;
    _checkPermissionsAndGetLocation();
  }

  Future<void> _checkPermissionsAndGetLocation() async {
    // Verificar permissões
    var status = await Permission.locationWhenInUse.status;
    if (!status.isGranted) {
      // Solicitar permissões
      await Permission.locationWhenInUse.request();
    }

    // Obter localização se a permissão foi concedida
    if (await Permission.locationWhenInUse.isGranted) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        mapController.move(LatLng(_latitude, _longitude),
            17.0); // Move the map to the new location
      });
    }
  }

  Future<void> _updateLocation() async {
    // Obter localização quando o botão é pressionado
    if (await Permission.locationWhenInUse.isGranted) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        mapController.move(LatLng(_latitude, _longitude),
            17.0); // Move the map to the new location
        print("${_latitude.toString()}; ${_longitude.toString()}");
      });
    } else {
      // Solicitar permissões se não concedidas
      await Permission.locationWhenInUse.request();
    }
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        toolbarHeight: 0.0,
      ),
      body: Center(
        child: Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialZoom: 17.0,
                maxZoom: 18.4,
                minZoom: 3.0,
                crs: const Epsg3857(),
                onTap: (tapPosition, latlng) {
                  // Handle map tap if needed
                },
                initialRotation: 0.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'http://{s}.google.com/vt?lyrs=s,h&x={x}&y={y}&z={z}',
                  subdomains: ['mt0', 'mt1', 'mt2', 'mt3'],
                ),
                MarkerLayer(markers: [
                  Marker(
                    width: 80.0,
                    height: 80.0,
                    point: LatLng(_latitude, _longitude),
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ]),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _updateLocation,
        tooltip: 'Atualizar Localização',
        child: const Icon(Icons.share_location),
      ),
    );
  }
}

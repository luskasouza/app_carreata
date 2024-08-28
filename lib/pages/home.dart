import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

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
  late double _latitude;
  late double _longitude;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _latitude = widget.latitudeInit;
    _longitude = widget.longitudeInit;
    _checkPermissionsAndGetLocation();
  }

  Future<void> _checkPermissionsAndGetLocation() async {
    final status = await Permission.locationWhenInUse.status;

    if (status.isGranted) {
      _getCurrentLocation();
    } else if (status.isDenied || status.isRestricted) {
      await Permission.locationWhenInUse.request();
      if (await Permission.locationWhenInUse.isGranted) {
        _getCurrentLocation();
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 0,
    );
    final position = await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    );
    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
      _mapController.move(LatLng(_latitude, _longitude), 17.0);
    });
  }

 Future<void> _updateLocation() async {
  try {
    // Verificar a conectividade
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // Mostrar um alerta se não houver conexão com a Internet
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sem conexão com a Internet. O mapa não pode ser carregado.'),
        ),
      );
      return;
    }

    // Se a permissão estiver concedida, atualize a localização
    if (await Permission.locationWhenInUse.isGranted) {
      await _getCurrentLocation();
    } else {
      await Permission.locationWhenInUse.request();
      // Verifique novamente se a permissão foi concedida
      if (await Permission.locationWhenInUse.isGranted) {
        await _getCurrentLocation();
      } else {
        // Mostrar uma mensagem se a permissão não for concedida
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permissão de localização não concedida.'),
          ),
        );
      }
    }
  } catch (e) {
    // Mostrar uma mensagem de erro genérica
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erro ao atualizar localização: $e'),
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0, 
        toolbarHeight: 0.0,
        //flexibleSpace: Text('${_latitude.toString()}; ${_longitude.toString()}'),
      ),
      body: Center(
        child: Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(_latitude, _longitude),
                initialZoom: 17.0,
                maxZoom: 18.4,
                minZoom: 3.0,
                crs: const Epsg3857(),
              ),
              children: [
                TileLayer(
                    urlTemplate: 'https://{s}.google.com/vt?lyrs=s,h&x={x}&y={y}&z={z}',
                    subdomains: const ['mt0', 'mt1', 'mt2', 'mt3'],
                    //urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    //subdomains: const ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
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
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:  _updateLocation,
        tooltip: 'Atualizar Localização',
        child: const Icon(Icons.share_location),
      ),
    );
  }
}

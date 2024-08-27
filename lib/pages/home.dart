import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              'Latitude: $_latitude',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'Longitude: $_longitude',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20), // Espaço entre os textos e o botão
            ElevatedButton(
              onPressed: _updateLocation,
              child: const Text('Atualizar Localização'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

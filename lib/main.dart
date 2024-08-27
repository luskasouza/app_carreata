import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'pages/home.dart'; // Certifique-se de que o caminho está correto

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carreata',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const PermissionSplashScreen(),
    );
  }
}

class PermissionSplashScreen extends StatefulWidget {
  const PermissionSplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PermissionSplashScreenState createState() => _PermissionSplashScreenState();
}

class _PermissionSplashScreenState extends State<PermissionSplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkPermissionsAndNavigate();
  }

  Future<void> _checkPermissionsAndNavigate() async {
    // Verificar permissões
    var status = await Permission.locationWhenInUse.status;
    if (!status.isGranted) { 
      await Permission.locationWhenInUse.request();
    }
    if (await Permission.locationWhenInUse.isGranted) {
      // Obter a localização
      Position position = await Geolocator.getCurrentPosition(
          // ignore: deprecated_member_use
          desiredAccuracy: LocationAccuracy.high);
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MyHomePage(
            title: 'Carreata',
            latitudeInit: position.latitude,
            longitudeInit: position.longitude,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Indicador de carregamento
      ),
    );
  }
}

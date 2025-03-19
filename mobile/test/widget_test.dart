import 'package:flutter/material.dart';
import 'package:proximity_sensor/proximity_sensor.dart';
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:convert';

late List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(SecurityApp());
}

class SecurityApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Modo de Segurança',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SecurityScreen(),
    );
  }
}

class SecurityScreen extends StatefulWidget {
  @override
  _SecurityScreenState createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool isSecurityActive = false;
  Socket? socket;
  CameraController? _cameraController;
  StreamSubscription<dynamic>? _proximitySubscription;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _initializeSocket();
    _initializeSensor();
    _initializeCamera();
  }

  Future<void> _requestPermissions() async {
    await [Permission.camera, Permission.storage].request();
  }

  void _initializeSocket() async {
    try {
      socket = await Socket.connect('192.168.18.103', 5000);
      print('Conectado ao servidor TCP');
    } catch (e) {
      print('Erro ao conectar: $e');
    }
  }

  void _initializeSensor() {
    _proximitySubscription = ProximitySensor.events.listen((int event) {
      bool isNear = event == 1;
      if (isSecurityActive && isNear) {
        _sendAlert();
      }
    });
  }

  void _initializeCamera() {
    _cameraController = CameraController(cameras.first, ResolutionPreset.medium);
    _cameraController!.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  void _sendAlert() {
    if (socket != null) {
      socket!.write(jsonEncode({'type': 'alert', 'message': 'Intrusão detectada'}) + '\n');
      _captureAndSendImage();
    }
  }

  Future<void> _captureAndSendImage() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        XFile image = await _cameraController!.takePicture();
        String imagePath = image.path;
        print("Imagem capturada e salva em: $imagePath");
      } catch (e) {
        print("Erro ao capturar imagem: $e");
      }
    } else {
      print("Câmera não inicializada!");
    }
  }

  @override
  void dispose() {
    _proximitySubscription?.cancel();
    _cameraController?.dispose();
    socket?.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Modo de Segurança')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Modo de Segurança: ${isSecurityActive ? "Ativado" : "Desativado"}'),
            Switch(
              value: isSecurityActive,
              onChanged: (value) {
                setState(() {
                  isSecurityActive = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

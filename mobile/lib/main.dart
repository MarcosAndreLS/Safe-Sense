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
      debugShowCheckedModeBanner: false,
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
  StreamSubscription<dynamic>? _proximitySubscription;
  CameraController? _cameraController;
  bool isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeSocket();
    _initializeSensor();
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
    _proximitySubscription = ProximitySensor.events.listen((int event) async {
      bool isNear = event == 1;
      if (isSecurityActive && isNear) {
        await _sendAlertAndCapture();
      }
    });
  }

  Future<void> _initializeCamera() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      return;
    }

    var status = await Permission.camera.request();
    if (!status.isGranted) {
      print("Permissão da câmera negada!");
      return;
    }

    try {
      CameraDescription frontCamera = cameras.firstWhere(
              (camera) => camera.lensDirection == CameraLensDirection.front);

      _cameraController = CameraController(frontCamera, ResolutionPreset.medium);

      await _cameraController!.initialize();
      setState(() {
        isCameraInitialized = true;
      });

      print("Câmera inicializada.");
    } catch (e) {
      print("Erro ao inicializar a câmera: $e");
    }
  }

  Future<void> _disposeCamera() async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
      _cameraController = null;
      setState(() {
        isCameraInitialized = false;
      });
      print("Câmera desligada.");
    }
  }

  Future<void> _sendAlertAndCapture() async {
    if (socket != null) {
      await _captureAndSendImage();
      socket!.write(jsonEncode({'type': 'alert', 'message': 'Intrusão detectada'}) + '\n');
    }
  }

  Future<void> _captureAndSendImage() async {
    await _initializeCamera();

    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      print("Câmera não inicializada corretamente!");
      return;
    }

    try {
      XFile image = await _cameraController!.takePicture();
      print("Imagem capturada: ${image.path}");

      File file = File(image.path);
      List<int> imageBytes = await file.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      if (socket != null) {
        socket!.write(jsonEncode({'type': 'image', 'image_data': base64Image}) + '\n');
        await _disposeCamera();
      }
    } catch (e) {
      print("Erro ao capturar imagem: $e");
    }
  }

  @override
  void dispose() {
    _proximitySubscription?.cancel();
    socket?.destroy();
    _disposeCamera();
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
              onChanged: (value) async {
                setState(() {
                  isSecurityActive = value;
                });

                /*if (isSecurityActive) {
                  await _initializeCamera();
                } else {
                  await _disposeCamera();
                }*/
              },
            ),
            isCameraInitialized
                ? Text("Câmera pronta para capturas.")
                : Text("Câmera não inicializada."),
          ],
        ),
      ),
    );
  }
}

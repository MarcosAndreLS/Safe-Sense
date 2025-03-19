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
  runApp(AppSeguranca());
}

class AppSeguranca extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Modo de Segurança',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TelaSeguranca(),
    );
  }
}

class TelaSeguranca extends StatefulWidget {
  @override
  _EstadoTelaSeguranca createState() => _EstadoTelaSeguranca();
}

class _EstadoTelaSeguranca extends State<TelaSeguranca> {
  bool modoSegurancaAtivo = false;
  Socket? soquete;
  StreamSubscription<dynamic>? _assinaturaSensorProximidade;
  CameraController? _controladorCamera;
  bool cameraInicializada = false;

  @override
  void initState() {
    super.initState();
    _inicializarSoquete();
    _inicializarSensor();
  }

  void _inicializarSoquete() async {
    try {
      soquete = await Socket.connect('192.168.18.103', 5000);
      print('Conectado ao servidor TCP');
    } catch (e) {
      print('Erro ao conectar: $e');
    }
  }

  void _inicializarSensor() {
    _assinaturaSensorProximidade = ProximitySensor.events.listen((int evento) async {
      bool estaPerto = evento == 1;
      if (modoSegurancaAtivo && estaPerto) {
        await _enviarAlertaECapturar();
      }
    });
  }

  Future<void> _inicializarCamera() async {
    if (_controladorCamera != null && _controladorCamera!.value.isInitialized) {
      return;
    }

    var status = await Permission.camera.request();
    if (!status.isGranted) {
      print("Permissão da câmera negada!");
      return;
    }

    try {
      CameraDescription cameraFrontal = cameras.firstWhere(
              (camera) => camera.lensDirection == CameraLensDirection.front);

      _controladorCamera = CameraController(cameraFrontal, ResolutionPreset.medium);

      await _controladorCamera!.initialize();
      setState(() {
        cameraInicializada = true;
      });

      print("Câmera inicializada.");
    } catch (e) {
      print("Erro ao inicializar a câmera: $e");
    }
  }

  Future<void> _desligarCamera() async {
    if (_controladorCamera != null) {
      await _controladorCamera!.dispose();
      _controladorCamera = null;
      setState(() {
        cameraInicializada = false;
      });
      print("Câmera desligada.");
    }
  }

  Future<void> _enviarAlertaECapturar() async {
    if (soquete != null) {
      await _capturarEEnviarImagem();
      soquete!.write(jsonEncode({'tipo': 'alerta', 'mensagem': 'Intrusão detectada'}) + '\n');
    }
  }

  Future<void> _capturarEEnviarImagem() async {
    await _inicializarCamera();

    if (_controladorCamera == null || !_controladorCamera!.value.isInitialized) {
      print("Câmera não inicializada corretamente!");
      return;
    }

    try {
      XFile imagem = await _controladorCamera!.takePicture();
      print("Imagem capturada: ${imagem.path}");

      File arquivo = File(imagem.path);
      List<int> bytesImagem = await arquivo.readAsBytes();
      String imagemBase64 = base64Encode(bytesImagem);

      if (soquete != null) {
        soquete!.write(jsonEncode({'tipo': 'imagem', 'dados_imagem': imagemBase64}) + '\n');
        await _desligarCamera();
      }
    } catch (e) {
      print("Erro ao capturar imagem: $e");
    }
  }

  @override
  void dispose() {
    _assinaturaSensorProximidade?.cancel();
    soquete?.destroy();
    _desligarCamera();
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
            Text('Modo de Segurança: ${modoSegurancaAtivo ? "Ativado" : "Desativado"}'),
            Switch(
              value: modoSegurancaAtivo,
              onChanged: (valor) async {
                setState(() {
                  modoSegurancaAtivo = valor;
                });

                /*if (modoSegurancaAtivo) {
                  await _inicializarCamera();
                } else {
                  await _desligarCamera();
                }*/
              },
            ),
            cameraInicializada
                ? Text("Câmera pronta para capturas.")
                : Text("Câmera não inicializada."),
          ],
        ),
      ),
    );
  }
}

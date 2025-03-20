# Safe Sense

Safe Sense é um sensor de proximidade para monitoramento remoto desenvolvido na disciplina de Sistemas Distribuídos.

## 🎯 Objetivo

Desenvolver um aplicativo Android que utilize o sensor de proximidade para ativar um modo de segurança. Quando o sensor detectar movimento, um sinal de alerta será enviado a um servidor Python rodando em um notebook, acionando um alarme sonoro ininterrupto. Além disso, o aplicativo capturará uma foto do intruso e enviará ao servidor, que armazenará a imagem para consulta posterior.

## 📋 Requisitos Funcionais

✔ O aplicativo deve permitir ativar e desativar o modo de segurança.

✔ Ao detectar movimento no sensor de proximidade, o aplicativo deve:
- Enviar um sinal de alerta ao servidor.
- Capturar uma foto do intruso e transmiti-la ao servidor.
- Acionar um alarme sonoro ininterrupto ao receber o alerta.
- Armazenar a imagem capturada em uma pasta local.
- Disponibilizar um botão para desativar o alarme.

## Pré-requisitos

Antes de começar, certifique-se de que você tenha o seguinte instalado:

- Flutter SDK: [Guia de Instalação](https://flutter.dev/docs/get-started/install)
- Dart SDK: [Guia de Instalação](https://dart.dev/get-dart)
- Um editor de código (VS Code, Android Studio, etc.)

## Como Executar o Projeto

Siga estas etapas para executar o projeto em sua máquina local:

1. **Clone o repositório**
    ```bash
    git clone https://github.com/MarcosAndreLS/Safe-Sense.git
    ```

2. **Navegue para dentro da pasta**
    ```bash
    cd Safe-Sense
    ```

3. **Instale as dependências**
    ```bash
    flutter pub get
    ```

4. **Execute o aplicativo**
    ```bash
    flutter run
    ```

## Estrutura do Projeto

```bash
Safe-Sense/
    |--- mobile/
    |       |--- android/
    |       |--- lib/
    |       |   |--- main.dart
    |       |
    |       |--- test/
    |       |--- .gitignore
    |       |--- .metadata
    |       |--- analysis_options.yaml
    |       |--- pubseck.lock
    |       |--- pubseck.yaml
    |       |--- README.md
    |--- servidor/
    |       |--- Alerta.mp3
    |       |--- Fuscao.mp3
    |       |--- main.py
    |       |--- Ze.mp3
    |--- README.md
```

## Capturas de tela do aplicativo, do servidor e das imagens capturadas


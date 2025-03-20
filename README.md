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

4. **Navegue para a pasta do servidor**
    ```bash
    cd ..
    cd servidor
    ```

5. **Execute o arquivo do servidor**
    ```bash
    python main.py
    ```
6. **Navegue novamente para a pasta mobile**
    ```bash
    cd ..
    cd mobile
    ```
7. **Execute o aplicativo**
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

1. **Tela do Aplicativo Mobile**

   O aplicativo mobile conta com um botão central que permite ativar e desativar o modo de segurança. Ao ativar esse modo, o aplicativo solicita permissão para o uso da câmera do smartphone. Uma vez ativado, caso o sensor de movimento detecte atividade, o aplicativo captura uma foto e a envia automaticamente para o servidor ao qual está conectado.

<p align="center">
    <img src="https://github.com/user-attachments/assets/e13be3b5-ca39-400e-a2d6-5799ade78a2d" alt="Imagem da Tela Inicial do Aplicativo Mobile" width="350"/>
</p>

<p align="center">
    <img src="https://github.com/user-attachments/assets/3eac78ee-711c-47f9-8dfa-5112b8436b85" alt="Imagem da Tela Inicial 2 do Aplicativo Mobile" width="350"/>
</p>

2. **Tela do Servidor**

   O servidor permanece em espera enquanto o smartphone não detecta movimento pelo sensor de proximidade. Quando um movimento é identificado, o smartphone envia um sinal ao servidor, que imediatamente aciona um alarme sonoro como medida de segurança. O alarme pode ser desativado manualmente através de um botão na interface do servidor. Além disso, o smartphone captura uma imagem do evento e a envia ao servidor, onde é automaticamente armazenada em uma pasta chamada "intrusos".
    
<p align="center">
    <img src="https://github.com/user-attachments/assets/22876cce-c87c-4c9c-bbbb-f4b1fd01910c" alt="Imagem da Tela do Servidor" width="350"/>
</p>

3. **Algumas Imagens Capturadas**

    Quando o servidor recebe uma imagem do aplicativo Android, ele mostra imediatamente na interface do servidor com data e horário real. Além disso, a imagem é salva automaticamente em uma pasta.
<p align="center">
    <img src="https://github.com/user-attachments/assets/fbb4168c-20f6-47c7-b3b5-27cb5526cd30" alt="Imagem do Intruso 1" width="350"/>
</p>

<p align="center">
    <img src="https://github.com/user-attachments/assets/a8bebc35-22d8-4f3b-adaf-7b4922e27a59" alt="Imagem do Intruso 2" width="350"/>
</p>
<p align="center">
    <img src="https://github.com/user-attachments/assets/d45f84a7-6654-4244-8f55-520a6ca39566" alt="Imagem do Intruso 3" width="350"/>
</p>
<p align="center">
    <img src="https://github.com/user-attachments/assets/a2a4c1b2-9415-469f-bcce-93a502a6873d" alt="Imagem do Intruso 4" width="350"/>
</p>

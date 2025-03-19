import socket
import threading
import tkinter as tk
import os
import json
import base64
import pygame  # Biblioteca para reprodução de áudioc
from datetime import datetime


# Configuração do servidor
HOST = '0.0.0.0'
PORT = 5000
ALARME_ATIVADO = False
DIRETORIO_IMAGEM = 'servidor/intrusos'
SOM_ALARME = "servidor/Ze.mp3"


if not os.path.exists(DIRETORIO_IMAGEM):
    os.makedirs(DIRETORIO_IMAGEM)

# Inicializa o mixer do pygame
pygame.mixer.init()


def tocar_alarme():
    pygame.mixer.music.load(SOM_ALARME)
    pygame.mixer.music.play(-1)  # Reproduz em loop infinito


def parar_alarme():
    pygame.mixer.music.stop()


def tratar_conexao_cliente(conn, addr):
    global ALARME_ATIVADO
    print(f'Conexão recebida de {addr}')
    with conn:
        buffer = ""
        while True:
            data = conn.recv(4096).decode('utf-8')
            if not data:
                break
            print("Recebido:", data)
            buffer += data

            while '\n' in buffer:
                msg, buffer = buffer.split('\n', 1)
                try:
                    msg_json = json.loads(msg)
                    if msg_json.get('type') == 'alert':
                        print('Alerta recebido! Ativando alarme...')
                        ALARME_ATIVADO = True
                        status_alarme()
                    elif msg_json.get('type') == 'image':
                        salvar_imagem(msg_json['image_data'])
                except json.JSONDecodeError:
                    print("Erro ao decodificar JSON")


def salvar_imagem(base64_string):
    timestamp = datetime.now().strftime('%Y-%m-%d_%H-%M-%S')
    image_path = os.path.join(DIRETORIO_IMAGEM, f'intruso_{timestamp}.jpg')
    image_data = base64.b64decode(base64_string)
    with open(image_path, 'wb') as f:
        f.write(image_data)
    print(f'Imagem salva em {image_path}')


def status_alarme():
    if ALARME_ATIVADO:
        alarm_label.config(text='ALARME ATIVO', fg='red')
        tocar_alarme()
    else:
        alarm_label.config(text='ALARME DESATIVADO', fg='green')
        parar_alarme()


def desativar_alarme():
    global ALARME_ATIVADO
    ALARME_ATIVADO = False
    status_alarme()
    print('Alarme desativado')


def ligar_servidor():
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.bind((HOST, PORT))
    server.listen(5)
    print(f'Servidor escutando em {HOST}:{PORT}')
    while True:
        conn, addr = server.accept()
        threading.Thread(target=tratar_conexao_cliente, args=(conn, addr)).start()


# Interface gráfica
root = tk.Tk()
root.title('Servidor de Segurança')

alarm_label = tk.Label(root, text='ALARME DESATIVADO', font=('Arial', 16), fg='green')
alarm_label.pack(pady=20)

disable_button = tk.Button(root, text='Desativar Alarme', command=desativar_alarme, bg='red', fg='white')
disable_button.pack()

# Iniciar servidor em uma thread separada
threading.Thread(target=ligar_servidor, daemon=True).start()

root.mainloop()

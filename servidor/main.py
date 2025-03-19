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
ALARM_ACTIVE = False
IMAGES_DIR = 'servidor/intrusos'
ALARM_SOUND = "servidor/Ze.mp3"


if not os.path.exists(IMAGES_DIR):
    os.makedirs(IMAGES_DIR)

# Inicializa o mixer do pygame
pygame.mixer.init()


def tocar_alarme():
    pygame.mixer.music.load(ALARM_SOUND)
    pygame.mixer.music.play(-1)  # Reproduz em loop infinito


def parar_alarme():
    pygame.mixer.music.stop()


def tratar_conexao_cliente(conn, addr):
    global ALARM_ACTIVE
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
                        ALARM_ACTIVE = True
                        status_alarme()
                    elif msg_json.get('type') == 'image':
                        salvar_imagem(msg_json['image_data'])
                except json.JSONDecodeError:
                    print("Erro ao decodificar JSON")


def salvar_imagem(base64_string):
    timestamp = datetime.now().strftime('%Y-%m-%d_%H-%M-%S')
    image_path = os.path.join(IMAGES_DIR, f'intruso_{timestamp}.jpg')
    image_data = base64.b64decode(base64_string)
    with open(image_path, 'wb') as f:
        f.write(image_data)
    print(f'Imagem salva em {image_path}')


def status_alarme():
    if ALARM_ACTIVE:
        alarm_label.config(text='ALARME ATIVO', fg='red')
        tocar_alarme()
    else:
        alarm_label.config(text='ALARME DESATIVADO', fg='green')
        parar_alarme()


def desativar_alarme():
    global ALARM_ACTIVE
    ALARM_ACTIVE = False
    status_alarme()
    print('Alarme desativado')


def start_server():
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
threading.Thread(target=start_server, daemon=True).start()

root.mainloop()

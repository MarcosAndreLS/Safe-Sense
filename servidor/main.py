import socket
import threading
import tkinter as tk
from tkinter import ttk
from PIL import Image, ImageTk
import os
import json
import base64
import pygame
from datetime import datetime

# Configuração do servidor
HOST = '0.0.0.0'
PORT = 5000
ALARM_ACTIVE = False
IMAGES_DIR = 'intrusos'
ALARM_SOUND = "Ze.mp3"

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
    exibir_imagem(image_path, timestamp)

def exibir_imagem(image_path, timestamp):
    img = Image.open(image_path)
    img = img.resize((200, 200), Image.LANCZOS)
    img_tk = ImageTk.PhotoImage(img)
    image_label.config(image=img_tk)
    image_label.image = img_tk
    timestamp_label.config(text=f'Detectado em: {timestamp}')

def status_alarme():
    if ALARM_ACTIVE:
        alarm_label.config(text='🔴 ALARME ATIVO', foreground='red')
        tocar_alarme()
    else:
        alarm_label.config(text='🟢 ALARME DESATIVADO', foreground='green')
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
root.geometry('400x400')
root.resizable(False, False)
root.configure(bg='#222831')

# Estilo visual
style = ttk.Style()
style.configure('TButton', font=('Arial', 12), padding=5)
style.configure('Alarm.TLabel', font=('Arial', 18, 'bold'), background='#222831')
style.configure('TFrame', background='#222831')

# Frame principal
frame = ttk.Frame(root)
frame.pack(pady=20)

# Status do alarme
alarm_label = ttk.Label(frame, text='🟢 ALARME DESATIVADO', style='Alarm.TLabel', foreground='green')
alarm_label.pack(pady=10)

# Botão para desativar o alarme
disable_button = ttk.Button(frame, text='Desativar Alarme', command=desativar_alarme, style='TButton')
disable_button.pack(pady=10)

# Label para exibir a imagem capturada
image_label = tk.Label(frame, bg='#222831')
image_label.pack(pady=10)

# Label para exibir o timestamp da imagem
timestamp_label = ttk.Label(frame, text='', font=('Arial', 10), background='#222831', foreground='white')
timestamp_label.pack()

# Iniciar servidor em uma thread separada
threading.Thread(target=start_server, daemon=True).start()

root.mainloop()

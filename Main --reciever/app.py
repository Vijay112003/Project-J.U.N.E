# import paho.mqtt.client as mqtt
# import ssl
# import json
# from controllers import *

# # MQTT Broker Configuration
# BROKER = "117b05b4f6e74fc18152fad7ddcc76a9.s1.eu.hivemq.cloud"
# PORT = 8883
# TOPIC_SUBSCRIBE = "SENDER"
# TOPIC_PUBLISH = "RECIEVER"
# TOPIC_STATUS = "STATUS"
# USERNAME = "hsundar2004"
# PASSWORD = "Lonely@2004"

# def on_connect(client, userdata, flags, rc):
#     if rc == 0:
#         print("Connected to HiveMQ Broker successfully")
#         client.subscribe(TOPIC_SUBSCRIBE)
#     else:
#         print(f"Connection failed with code {rc}")

# def on_disconnect(client, userdata, rc):
#     print("Client disconnected from broker")
#     disconnect_message = json.dumps({"status": "disconnected"})
#     client.publish(TOPIC_STATUS, disconnect_message)
#     print(f"Broadcasted disconnect message: {disconnect_message}")

# def on_message(client, userdata, msg):
#     payload = msg.payload.decode("utf-8")
#     print(f"Received message: {payload}")
    
#     if payload.lower() == "status":
#         status_info = get_current_status()
#         status_message = json.dumps({"status" : status_info})
#         client.publish(TOPIC_STATUS, status_message)
#         print(f"Broadcasted status: {status_message}")
#     else:
#         response = process_action(payload)
#         response_json = json.dumps(response)
#         client.publish(TOPIC_PUBLISH, response_json)
#         print(f"Replied with: {response_json}")

# # Initialize MQTT Client
# client = mqtt.Client()
# client.username_pw_set(USERNAME, PASSWORD)
# client.tls_set(tls_version=ssl.PROTOCOL_TLS)

# # Set callbacks
# client.on_connect = on_connect
# client.on_disconnect = on_disconnect
# client.on_message = on_message

# # Connect to MQTT Broker
# client.connect(BROKER, PORT, 60)

# # Start MQTT loop
# print(f"Subscribed to {TOPIC_SUBSCRIBE}")
# client.loop_forever()

import websocket
import json
import threading
from controllers import get_current_status, process_action
from auth.login import LoginInterface
from ui.log_display import LogDisplay
import tkinter as tk
import sys
import signal
import base64
import time
import mss
import cv2
import numpy as np

# Settings
WS_URL = "wss://june-backend-fckl.onrender.com"
ROLE = "pc"
USER_TOKEN = None
ws_app = None
ws_thread = None

def on_message(ws, message):
    print(f"Received: {message}")
    data = message.strip().lower()
    result = process_action(data)
    response = json.dumps(result)
    ws.send(response)
    print(f"Sent response: {response}")

def on_open(ws):
    print("WebSocket connection opened")
    register_msg = json.dumps({
        "type": "register",
        "token": USER_TOKEN,
        "role": ROLE
    })
    ws.send(register_msg)
    print(f"Sent register message: {register_msg}")
    # threading.Thread(target=stream_screen, args=(ws,), daemon=True).start()

def stream_screen(ws):
    with mss.mss() as sct:
        monitor = sct.monitors[1]
        while True:
            img = np.array(sct.grab(monitor))
            frame = cv2.cvtColor(img, cv2.COLOR_BGRA2BGR)
            _, jpeg = cv2.imencode('.jpg', frame, [int(cv2.IMWRITE_JPEG_QUALITY), 50])
            b64_image = base64.b64encode(jpeg).decode('utf-8')
            ws.send(json.dumps({
                "type": "screen_frame",
                "data": b64_image
            }))
            time.sleep(0.1)  # ~10 FPS

def on_close(ws, close_status_code, close_msg):
    print("WebSocket connection closed")

def on_error(ws, error):
    print(f"WebSocket error: {error}")

def run_ws():
    global ws_app
    ws_app = websocket.WebSocketApp(
        WS_URL,
        on_open=on_open,
        on_message=on_message,
        on_error=on_error,
        on_close=on_close
    )
    ws_app.run_forever()

def start_application(token):
    print("Login successful! Starting application...")
    global USER_TOKEN, ws_thread
    log_window = LogDisplay()
    USER_TOKEN = token
    ws_thread = threading.Thread(target=run_ws)
    ws_thread.daemon = True
    ws_thread.start()
    log_window.mainloop()


def signal_handler(sig, frame):
    global ws_app, ws_thread
    print("\nShutting down gracefully...")
    if ws_app:
        ws_app.close()
    if ws_thread and ws_thread.is_alive():
        ws_thread.join(timeout=1)
    sys.exit(0)

def main():
    signal.signal(signal.SIGINT, signal_handler)
    
    root = tk.Tk()
    root.withdraw()  # Hide the root window but keep it as parent
    
    try:
        login = LoginInterface(parent=root, on_login_success=start_application)
        if not login.check_existing_token():  # Only run if no valid token
            login.run()
    except SystemExit:
        if root and root.winfo_exists():
            root.destroy()
        signal_handler(signal.SIGINT, None)

if __name__ == "__main__":
    main()
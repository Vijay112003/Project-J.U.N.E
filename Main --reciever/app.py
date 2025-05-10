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

# Settings
WS_URL = "wss://june-backend-fckl.onrender.com"  # Use your actual relay server URL

USER_TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4MTcyYTY5OGE3Yzg3ZTY2NjIxNjAzZCIsImVtYWlsIjoidGhlamVzaGJoYWdhdmFudGhAZ21haWwuY29tIiwiaWF0IjoxNzQ2MzQ5MjgyLCJleHAiOjE3NDY5NTQwODJ9.bAxsJ3krmvqXBh5UdpGhM4LzKLHMa7npukfNfHR6kpI"  # Same token used on mobile
ROLE = "pc"  # This client acts as the PC

def on_message(ws, message):
    print(f"Received: {message}")
    data = message.strip().lower()

    if data == "status":
        status_info = get_current_status()
        status_message = json.dumps({ "type": "status", "status": status_info })
        ws.send(status_message)
        print(f"Sent status: {status_message}")
    else:
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

def on_close(ws, close_status_code, close_msg):
    print("WebSocket connection closed")

def on_error(ws, error):
    print(f"WebSocket error: {error}")

# Create and run the WebSocket connection
def run_ws():
    ws = websocket.WebSocketApp(
        WS_URL,
        on_open=on_open,
        on_message=on_message,
        on_error=on_error,
        on_close=on_close
    )
    ws.run_forever()

# Run in a thread so it doesn't block
threading.Thread(target=run_ws).start()

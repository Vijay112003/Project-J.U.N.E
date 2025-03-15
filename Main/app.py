import paho.mqtt.client as mqtt
import ssl
import json
from controllers import *

# MQTT Broker Configuration
BROKER = "117b05b4f6e74fc18152fad7ddcc76a9.s1.eu.hivemq.cloud"
PORT = 8883
TOPIC_SUBSCRIBE = "SENDER"
TOPIC_PUBLISH = "RECIEVER"
TOPIC_STATUS = "STATUS"
USERNAME = "admin@gmail.com"
PASSWORD = "Admin@123"

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print("Connected to HiveMQ Broker successfully")
        client.subscribe(TOPIC_SUBSCRIBE)
    else:
        print(f"Connection failed with code {rc}")

def on_disconnect(client, userdata, rc):
    print("Client disconnected from broker")
    disconnect_message = json.dumps({"status": "disconnected"})
    client.publish(TOPIC_STATUS, disconnect_message)
    print(f"Broadcasted disconnect message: {disconnect_message}")

def on_message(client, userdata, msg):
    payload = msg.payload.decode("utf-8")
    print(f"Received message: {payload}")
    
    if payload.lower() == "status":
        status_info = get_current_status()
        status_message = json.dumps(status_info)
        client.publish(TOPIC_STATUS, status_message)
        print(f"Broadcasted status: {status_message}")
    else:
        response = process_action(payload)
        response_json = json.dumps(response)
        client.publish(TOPIC_PUBLISH, response_json)
        print(f"Replied with: {response_json}")

# Initialize MQTT Client
client = mqtt.Client()
client.username_pw_set(USERNAME, PASSWORD)
client.tls_set(tls_version=ssl.PROTOCOL_TLS)

# Set callbacks
client.on_connect = on_connect
client.on_disconnect = on_disconnect
client.on_message = on_message

# Connect to MQTT Broker
client.connect(BROKER, PORT, 60)

# Start MQTT loop
print(f"Subscribed to {TOPIC_SUBSCRIBE}")
client.loop_forever()

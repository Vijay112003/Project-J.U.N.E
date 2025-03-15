import paho.mqtt.client as mqtt
import ssl
import ctypes
import os
import time
from datetime import datetime as DateTime


def lock_computer():
    ctypes.windll.user32.LockWorkStation()

def sleep_computer():
    os.system("rundll32.exe powrprof.dll,SetSuspendState Sleep")

def process_message(message):
    # Example: Echo the received message
    if message == "how are you":
        return "I am Fine"
    elif message == "tell me your name":
        return "My name is HiveMQ"
    elif message == "what is the time":
        return "The time is"+ DateTime.now().strftime("%H:%M:%S")
    elif message == "what is the date":
        return "The date is"+ DateTime.now().strftime("%d/%m/%Y")
    elif message.lower() == "lock computer":
        lock_computer()
        return "Computer locked"
    elif message.lower() == "sleep computer":
        sleep_computer()
        return "Computer going to sleep"
    else:
        return "sorry I can't understand"

def connection():
    # Callback when the client receives a CONNACK response from the server
    def on_connect(client, userdata, flags, rc):
        print(f"Connected with result code {rc}")
        # Subscribe to topic(s)
        client.subscribe("SENDER")

    # Callback when a message is received from the server
    def on_message(client, userdata, msg):
        print(f"Topic: {msg.topic}")
        received_message = msg.payload.decode()
        print(f"Message: {received_message}")
        
        # Process and publish reply
        reply = process_message(received_message)
        client.publish("RECIEVER", reply)
        print(f"Replied with: {reply}")

    # Create MQTT client instance
    client = mqtt.Client()

    # Set callbacks
    client.on_connect = on_connect
    client.on_message = on_message

    # Configure TLS/SSL
    client.tls_set(tls_version=ssl.PROTOCOL_TLS)

    # Set credentials
    client.username_pw_set("admin@gmail.com", "Admin@123")

    # Connect to Hive MQTT broker
    client.connect("117b05b4f6e74fc18152fad7ddcc76a9.s1.eu.hivemq.cloud", 8883, 60)

    # Start the loop to process network traffic
    client.loop_forever()

if __name__ == "__main__":
    connection()
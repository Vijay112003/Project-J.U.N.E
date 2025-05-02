import cmd
import os
import subprocess
import sys
import ssl
import json
import threading
import time
import paho.mqtt.client as mqtt

# MQTT Configuration
BROKER = "117b05b4f6e74fc18152fad7ddcc76a9.s1.eu.hivemq.cloud"
PORT = 8883
TOPIC_SUBSCRIBE = "SENDER"
TOPIC_PUBLISH = "RECIEVER"
USERNAME = "hsundar2004"
PASSWORD = "Lonely@2004"

# Shared MQTT client for both send and receive
mqtt_client = mqtt.Client()
mqtt_client.username_pw_set(USERNAME, PASSWORD)
mqtt_client.tls_set(tls_version=ssl.PROTOCOL_TLS)

def get_current_status():
    return "Device is online."

def process_action(command):
    try:
        result = subprocess.run(command, shell=True, capture_output=True, text=True)
        return {"output": result.stdout.strip() or result.stderr.strip()}
    except Exception as e:
        return {"error": str(e)}

# MQTT Callbacks
def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print("Connected to HiveMQ")
        client.subscribe(TOPIC_SUBSCRIBE)
    else:
        print(f"Connection failed: {rc}")

def on_disconnect(client, userdata, rc):
    print("Disconnected from broker")
    client.publish("STATUS", json.dumps({"status": "disconnected"}))

def on_message(client, userdata, msg):
    payload = msg.payload.decode("utf-8")
    print(f"\n[Incoming MQTT Command]: {payload}")
    if payload.lower() == "status":
        status_info = get_current_status()
        client.publish(TOPIC_PUBLISH, json.dumps({"status": status_info}))
    else:
        response = process_action(payload)
        client.publish(TOPIC_PUBLISH, json.dumps(response))

mqtt_client.on_connect = on_connect
mqtt_client.on_disconnect = on_disconnect
mqtt_client.on_message = on_message

# Thread to run MQTT loop
def run_mqtt():
    mqtt_client.connect(BROKER, PORT, 60)
    mqtt_client.loop_forever()

# Virtual Command Prompt using cmd.Cmd
class VirtualCMD(cmd.Cmd):
    intro = "VirtualCMD started. Type commands to send. Type 'exit' to quit."
    prompt = "(virtual-cmd) "

    def __init__(self):
        super().__init__()
        self.current_dir = os.getcwd()
        self._update_prompt()

    def _update_prompt(self):
        self.prompt = f"({os.path.basename(self.current_dir)})> "

    def default(self, line: str):
        mqtt_client.publish(TOPIC_SUBSCRIBE, line)
        print(f"[Command Sent]: {line}")

    def do_cd(self, arg: str):
        try:
            new_dir = os.path.expanduser(arg or "~")
            if os.path.isdir(new_dir):
                self.current_dir = new_dir
                self._update_prompt()
            else:
                print(f"No such directory: {new_dir}")
        except Exception as e:
            print(f"Error: {e}")

    def do_exit(self, _):
        print("Exiting VirtualCMD...")
        return True

# Receiver for result from MQTT broker
def listen_for_output():
    def on_result(client, userdata, msg):
        payload = msg.payload.decode("utf-8")
        print(f"\n[MQTT Response]: {payload}")

    mqtt_response_client = mqtt.Client()
    mqtt_response_client.username_pw_set(USERNAME, PASSWORD)
    mqtt_response_client.tls_set(tls_version=ssl.PROTOCOL_TLS)
    mqtt_response_client.on_message = on_result
    mqtt_response_client.connect(BROKER, PORT, 60)
    mqtt_response_client.subscribe(TOPIC_PUBLISH)
    mqtt_response_client.loop_forever()

# MAIN
if __name__ == "__main__":
    # Start MQTT message processor
    threading.Thread(target=run_mqtt, daemon=True).start()
    # Start result receiver
    threading.Thread(target=listen_for_output, daemon=True).start()

    try:
        VirtualCMD().cmdloop()
    except KeyboardInterrupt:
        print("\n[Interrupted] Exiting...")
        sys.exit(0)

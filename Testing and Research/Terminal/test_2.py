import subprocess

def execute_command(command):
    result = subprocess.run(command, capture_output=True, text=True, shell=True)
    return result.stdout

while True:
    command = input("Enter a command: ")
    if command == "exit":
        break
    print(execute_command(command))
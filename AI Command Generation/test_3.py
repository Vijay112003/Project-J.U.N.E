import pathlib
import textwrap
import ollama
import os
import re
import subprocess

model_name = "deepseek-r1:1.5b"

def extract_commands(text):
    command_pattern = re.compile(r'```batch\\n(.*?)\\n```', re.DOTALL)
    commands = command_pattern.findall(text)
    return commands

def decide_best_command(commands):
    priority = {
        "type nul": 1,
        "echo.": 2,
        "copy nul": 3,
        "fsutil file createnew": 4,
        "powershell New-Item": 5
    }
    best_command = min(commands, key=lambda cmd: min((priority[key] for key in priority if cmd.startswith(key)), default=float('inf')))
    return best_command

while True:
    query = input("Ask Anything (or type 'exit' to quit): ")
    if query.lower() == 'exit':
        break
    
    modified_query = "Generate a Windows batch script that will " + query
    response = ollama.chat(model=model_name, messages=[{"role": "user", "content": modified_query}])
    
    txt = response['message']['content']
    commands = extract_commands(txt)
    
    if not commands:
        print("No valid batch script found.")
        continue
    
    best_command = decide_best_command(commands)
    
    batch_script_path = "extracted_script.bat"
    with open(batch_script_path, "w") as file:
        file.write("@echo off\n")  # Prevents unnecessary output
        file.write(best_command + "\n")
        file.write("exit\n")  # Ensures the script exits cleanly
    
    print("Extracted Commands:")
    for cmd in commands:
        print(cmd)
    
    print("\nBest Command to Use:")
    print(best_command)
    
    subprocess.run(["cmd.exe", "/c", batch_script_path], shell=True)

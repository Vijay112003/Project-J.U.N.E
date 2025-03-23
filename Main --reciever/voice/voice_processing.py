import os
import re

import subprocess
import google.generativeai as genai

class BatchScriptGenerator:
    def __init__(self, api_key):
        self.api_key = api_key
        os.environ["GEMINI_API_KEY"] = self.api_key
        genai.configure(api_key=self.api_key)
        self.model = genai.GenerativeModel("gemini-1.5-pro-latest")
    
    def extract_commands(self, text):
        command_pattern = re.compile(r'```batch\n(.*?)\n```', re.DOTALL)
        return command_pattern.findall(text)
    
    def decide_best_command(self, commands):
        priority = {
            "type nul": 1,
            "echo.": 2,
            "copy nul": 3,
            "fsutil file createnew": 4,
            "powershell New-Item": 5
        }
        return min(commands, key=lambda cmd: min((priority[key] for key in priority if cmd.startswith(key)), default=float('inf')))
    
    def process(self, query):
        modified_query = "Generate a windows batch script that will " + query
        response = self.model.generate_content(modified_query)
        
        commands = self.extract_commands(response.text)
        if not commands:
            print("No batch script found in the response.")
            return
        
        best_command = self.decide_best_command(commands)
        
        batch_script_path = "extracted_script.bat"
        with open(batch_script_path, "w") as file:
            file.write(best_command)
        
        print("Extracted Commands:")
        for cmd in commands:
            print(cmd)
        print("\nBest Command to Use:")
        print(best_command)
        
        subprocess.run(["cmd.exe", "/c", batch_script_path], shell=True)
        os.remove(batch_script_path)
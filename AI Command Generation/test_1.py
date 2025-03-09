import pathlib
import textwrap
import google.generativeai as genai
import os
import re
import subprocess

def to_markdown(text):
    text = text.replace("\u2022", "  *")
    return Markdown(textwrap.indent(text, "> ", predicate=lambda _: True))

os.environ["GEMINI_API_KEY"] = "AIzaSyCPwuJF0lbcGGLPTwwcp02Hg_plqPJGHQc"
GOOGLE_API_KEY = os.getenv("GEMINI_API_KEY")

genai.configure(api_key=GOOGLE_API_KEY)

# for m in genai.list_models():
#     if "generateContent" in m.supported_generation_methods:
#         print(m.name)

model = genai.GenerativeModel("gemini-1.5-pro-latest")

query = input("Ask Anything: ")
response = model.generate_content(query)

def extract_commands(text):
    command_pattern = re.compile(r'^(?:```)?\s*(.+?)\s*(?:```)?$', re.MULTILINE)
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

txt = response.text
commands = extract_commands(txt)

for cmd in commands:
    print(cmd)

best_command = decide_best_command(commands)

print("Extracted Commands:")
for cmd in commands:
    print(cmd)

print("\nBest Command to Use:")
print(best_command)

#todo execute command
subprocess.run(best_command, shell=True)
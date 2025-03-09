import re
import subprocess

def extract_command(text):
    # Define a regex pattern to match shell commands
    command_pattern = re.compile(r'```bash\n(.*?)\n```', re.DOTALL)
    
    # Extract all commands
    commands = command_pattern.findall(text)
    
    # Return the first extracted command (assuming the main one is first)
    return commands[0] if commands else None

def execute_command(command):
    if command:
        print(f"Executing: {command}")
        try:
            result = subprocess.run(command, shell=True, check=True, text=True, capture_output=True)
            print("Output:", result.stdout)
        except subprocess.CalledProcessError as e:
            print("Error:", e.stderr)
    else:
        print("No valid command found.")

# Provided text
txt = """
```bash
$ notepad3 <C:\\Users\\spide\\test.txt -p
```
"""

# Extract and execute command
cmd = extract_command(txt)
execute_command(cmd)

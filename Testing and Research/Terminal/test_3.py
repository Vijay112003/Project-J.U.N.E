import subprocess
import os

def interactive_shell():
    current_dir = os.getcwd()  # Start from the current working directory

    while True:
        command = input(f"IN: {current_dir}> ")  # Display prompt with the current directory

        if command.lower() in ["exit", "quit"]:  # Exit condition
            break

        if command.lower().startswith("cd "):  # Handle 'cd' separately
            try:
                new_path = command[3:].strip('"')  # Extract directory path
                os.chdir(new_path)  # Change directory
                current_dir = os.getcwd()  # Update current directory
            except FileNotFoundError:
                print("The system cannot find the path specified.")
            except Exception as e:
                print(f"Error: {e}")
            continue

        # Run other commands in the current directory
        process = subprocess.Popen(command, shell=True, cwd=current_dir, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        output, error = process.communicate()

        if output:
            print("OUT:",output)
        if error:
            print(error)

if __name__ == "__main__":
    interactive_shell()

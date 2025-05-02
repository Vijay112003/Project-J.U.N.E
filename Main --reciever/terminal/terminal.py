import subprocess
import time
import os

class Terminal:
    """Handles one-time terminal command execution."""

    def __init__(self):
        print("[DEBUG] Terminal initialized for one-time commands.")

    def execute_command(self, command, timeout=10):
        """
        Execute a single command in a fresh terminal session and return its output.

        Args:
            command (str): The command to run
            timeout (int): Seconds before timing out

        Returns:
            str: Command output or error message
        """
        print(f"[DEBUG] Executing command: {command}")
        try:
            # Add echo off to suppress command echo
            full_command = f'@echo off & {command}'

            # Start the subprocess
            process = subprocess.Popen(
                ["cmd.exe", "/c", full_command],
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True
            )

            try:
                output, _ = process.communicate(timeout=timeout)
                output = output.strip()
                print("[DEBUG] Command output received.")
                return output if output else "Command executed successfully with no output"
            except subprocess.TimeoutExpired:
                process.kill()
                return "Error: Command timed out"

        except Exception as e:
            return f"Error executing command: {str(e)}"

    def close(self):
        """Dummy close for compatibility."""
        print("[DEBUG] No persistent terminal to close.")

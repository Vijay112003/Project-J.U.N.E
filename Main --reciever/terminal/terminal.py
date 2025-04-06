import subprocess
import threading
import time
import os
import sys
import select

class Terminal:
    """Handles persistent terminal sessions with reliable synchronous command execution."""

    def __init__(self):
        """Initialize a persistent cmd.exe session."""
        print("[DEBUG] Initializing Terminal session...")
        self.process = subprocess.Popen(
            ["cmd.exe"],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            bufsize=1
        )
        self.lock = threading.Lock()
        time.sleep(0.5)  # Allow time for initialization
        self._clear_buffer()
        print("[DEBUG] Terminal session initialized.")

    def _clear_buffer(self, timeout=1.0):
        """Clears any pending output in the terminal buffer with a timeout."""
        print("[DEBUG] Clearing terminal buffer...")
        start_time = time.time()
        while time.time() - start_time < timeout:
            rlist, _, _ = select.select([self.process.stdout], [], [], 0.1)
            if rlist:
                line = self.process.stdout.readline().strip()
                if not line:
                    break
        print("[DEBUG] Buffer cleared.")

    def execute_command(self, command):
        """Execute a command synchronously and return the output."""
        print(f"[DEBUG] Executing command: {command}")
        with self.lock:
            try:
                self._clear_buffer()

                # Unique marker to detect end of the command
                marker = f"__END__{os.getpid()}__"
                full_command = f"{command} & echo {marker}\n"
                
                # Write command to stdin
                print("[DEBUG] Sending command to stdin...")
                self.process.stdin.write(full_command)
                self.process.stdin.flush()
                print("[DEBUG] Command sent.")

                output = []
                while True:
                    rlist, _, _ = select.select([self.process.stdout], [], [], 2.0)
                    if rlist:
                        line = self.process.stdout.readline().strip()
                        print(f"[DEBUG] Read line: {line}")
                        if marker in line:
                            print("[DEBUG] Marker detected. Ending command output collection.")
                            break
                        if line:
                            output.append(line)
                    else:
                        print("[DEBUG] No output received within timeout.")
                        break

                result = "\n".join(output) if output else "Command executed with no output"
                print(f"[DEBUG] Command execution result:\n{result}")
                return result
            
            except Exception as e:
                print(f"[ERROR] {str(e)}")
                return f"Error: {str(e)}"

    def close(self):
        """Terminate the terminal session safely."""
        print("[DEBUG] Closing terminal session...")
        with self.lock:
            try:
                self.process.stdin.write("exit\n")
                self.process.stdin.flush()
                time.sleep(0.2)
            finally:
                self.process.terminate()
                self.process.wait()
        print("[DEBUG] Terminal session closed.")

# Example usage
if __name__ == "__main__":
    terminal = Terminal()

    print("Running 'dir':")
    print(terminal.execute_command("dir"))

    print("\nRunning 'ipconfig':")
    print(terminal.execute_command("ipconfig"))

    terminal.close()

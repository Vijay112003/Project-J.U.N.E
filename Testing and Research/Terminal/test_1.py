import subprocess
import threading
import os
import queue
import time

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
        self.output_queue = queue.Queue()
        self.reader_thread = threading.Thread(target=self._read_output, daemon=True)
        self.reader_thread.start()
        time.sleep(0.5)  # Allow time for initialization
        print("[DEBUG] Terminal session initialized.")

    def _read_output(self):
        """Continuously reads output from process and stores in queue."""
        for line in self.process.stdout:
            self.output_queue.put(line.strip())

    def execute_command(self, command):
        """Execute a command synchronously and return the output."""
        with self.lock:
            try:
                print(f"[DEBUG] Executing command: {command}")
                
                # Clear previous output queue
                while not self.output_queue.empty():
                    self.output_queue.get()
                
                # Unique marker to detect end of the command
                marker = f"__END__{os.getpid()}__"
                full_command = f"{command} & echo {marker}\n"

                # Write command to stdin
                self.process.stdin.write(full_command)
                self.process.stdin.flush()
                print("[DEBUG] Command sent.")

                output = []
                while True:
                    line = self.output_queue.get()
                    if marker in line:
                        break
                    if line:
                        output.append(line)

                return "\n".join(output) if output else "Command executed with no output"
            
            except Exception as e:
                return f"Error: {str(e)}"

    def close(self):
        """Terminate the terminal session safely."""
        with self.lock:
            try:
                print("[DEBUG] Closing terminal session...")
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

    while True:
        cmd = input("Enter command: ")
        if cmd.lower() == "exit":
            break
        print(terminal.execute_command(cmd))

    terminal.close()

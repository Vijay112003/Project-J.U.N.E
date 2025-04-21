import subprocess
import threading
import time
import os
import sys
import queue

class Terminal:
    """Handles persistent terminal sessions with reliable synchronous command execution."""

    def __init__(self):
        print("[DEBUG] Initializing Terminal session...")
        self.process = subprocess.Popen(
            ["cmd.exe"],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            bufsize=1
        )
        self.lock = threading.Lock()
        self.output_queue = queue.Queue()
        self.stdout_thread = threading.Thread(target=self._enqueue_output, daemon=True)
        self.stdout_thread.start()
        time.sleep(0.5)
        self._clear_buffer()
        print("[DEBUG] Terminal session initialized.")

    def _enqueue_output(self):
        """Thread target: read lines and put them into a queue."""
        for line in self.process.stdout:
            self.output_queue.put(line.strip())

    def _clear_buffer(self):
        """Clear any remaining output in the queue."""
        print("[DEBUG] Clearing terminal buffer...")
        while not self.output_queue.empty():
            discarded = self.output_queue.get_nowait()
        print("[DEBUG] Buffer cleared.")

    def execute_command(self, command):
        print(f"[DEBUG] Executing command: {command}")
        with self.lock:
            try:
                self._clear_buffer()
                marker = f"__END__{os.getpid()}__"
                full_command = f"{command} & echo {marker}\n"

                print("[DEBUG] Sending command to stdin...")
                self.process.stdin.write(full_command)
                self.process.stdin.flush()
                print("[DEBUG] Command sent.")

                output = []
                while True:
                    try:
                        line = self.output_queue.get(timeout=2.0)
                        print(f"[DEBUG] Read line: {line}")
                        if marker in line:
                            print("[DEBUG] Marker detected. Ending command output collection.")
                            break
                        output.append(line)
                    except queue.Empty:
                        print("[DEBUG] No output received within timeout.")
                        break

                result = "\n".join(output) if output else "Command executed with no output"
                print(f"[DEBUG] Command execution result:\n{result}")
                return result

            except Exception as e:
                print(f"[ERROR] {str(e)}")
                return f"Error: {str(e)}"

    def close(self):
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

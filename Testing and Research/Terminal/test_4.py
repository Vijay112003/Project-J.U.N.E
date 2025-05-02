import cmd
import os
import subprocess
import sys
from typing import List

class VirtualCMD(cmd.Cmd):
    """A continuous virtual command prompt with real-time output."""
    
    intro = "Welcome to the Virtual Command Prompt. Type 'help' for commands or 'exit' to quit."
    prompt = "(virtual-cmd) "
    
    def __init__(self):
        super().__init__()
        self.history: List[str] = []
        self.current_dir = os.getcwd()
    
    def _update_prompt(self):
        """Update prompt to show current directory."""
        self.prompt = f"({os.path.basename(self.current_dir)})> "
    
    def emptyline(self):
        """Do nothing when empty line is entered."""
        pass
    
    def default(self, line: str):
        """Handle unknown commands with real-time output."""
        try:
            process = subprocess.Popen(
                line,
                shell=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                cwd=self.current_dir,
                text=True,
                bufsize=1,  # Line buffered
                universal_newlines=True
            )
            
            # Read output line by line as it comes
            while True:
                output = process.stdout.readline()
                if output == '' and process.poll() is not None:
                    break
                if output:
                    print(output.strip())
            
            # Get return code
            return_code = process.poll()
            if return_code:
                print(f"Command failed with return code {return_code}")
                
        except Exception as e:
            print(f"Error: {str(e)}")
    
    def do_cd(self, arg: str):
        """Change directory: cd <directory>"""
        try:
            if not arg:
                new_dir = os.path.expanduser("~")
            else:
                new_dir = os.path.abspath(os.path.join(self.current_dir, arg))
            
            if os.path.isdir(new_dir):
                self.current_dir = new_dir
                self._update_prompt()
            else:
                print(f"Directory not found: {new_dir}")
        except Exception as e:
            print(f"Error changing directory: {str(e)}")
    
    # ... (keep all other methods the same as in the original implementation)

if __name__ == "__main__":
    try:
        VirtualCMD().cmdloop()
    except KeyboardInterrupt:
        print("\nExiting due to keyboard interrupt...")
        sys.exit(0)
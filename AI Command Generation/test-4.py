import ollama
import re
import subprocess

def query_mistral(prompt):
    response = ollama.chat(model="deepseek-r1:1.5b", messages=[{"role": "user", "content": prompt}])
    return response["message"]["content"]

def extract_batch_script(text):
    match = re.search(r"```batch\n(.*?)\n```", text, re.DOTALL)
    return match.group(1) if match else None

def run_batch_script(script):
    batch_script_path = "generated_script.bat"
    with open(batch_script_path, "w") as file:
        file.write(script)
    
    subprocess.run(["cmd.exe", "/c", batch_script_path], shell=True)

if __name__ == "__main__":
    query = input("Enter a batch script request: ")
    modified_query = f"Generate a Windows batch script to {query}"
    
    response_text = query_mistral(modified_query)
    batch_script = extract_batch_script(response_text)

    if batch_script:
        print("\nExtracted Batch Script:\n", batch_script)
        run_batch_script(batch_script)
    else:
        print("No batch script found in the response.")

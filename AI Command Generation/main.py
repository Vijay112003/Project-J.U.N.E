import subprocess
from transformers import AutoModelForCausalLM, AutoTokenizer
import torch

# Initialize model and tokenizer
tokenizer = AutoTokenizer.from_pretrained("deepseek-ai/deepseek-coder-1.3b-base")
model = AutoModelForCausalLM.from_pretrained("deepseek-ai/deepseek-coder-1.3b-base")

def generate_command(prompt):
    # Prepare the prompt for the model
    input_text = f"""Task: Generate a single-line Windows command for: {prompt}
    Requirements:
    - Output ONLY the command itself
    - No explanations or additional text
    - Must be a valid Windows command
    
    Examples:
    User: open chrome
    Command: start chrome
    
    User: open notepad
    Command: notepad
    
    User: {prompt}
    Command:"""
    
    inputs = tokenizer(input_text, return_tensors="pt")
    
    # Generate response
    with torch.no_grad():
        outputs = model.generate(
            inputs["input_ids"],
            max_length=100,
            num_return_sequences=1,
            temperature=0.3,
            top_p=0.95,
            do_sample=True,
            pad_token_id=tokenizer.eos_token_id
        )
    
    # Decode and clean the response
    generated_text = tokenizer.decode(outputs[0], skip_special_tokens=True)
    
    # Extract command using more robust parsing
    try:
        # Try to find the command after the last "Command:" if it exists
        if "Command:" in generated_text:
            command = generated_text.split("Command:")[-1].strip()
        else:
            # If no "Command:" found, take the last non-empty line
            command = [line.strip() for line in generated_text.split('\n') if line.strip()][-1]
        
        # Remove any common artifacts
        command = command.replace('`', '').replace('"', '').replace("'", "")
        
        # Basic validation
        if len(command.split()) > 10:  # Command too long, likely invalid
            return "echo Invalid command generated"
            
        return command
    except Exception:
        return "echo Error processing command"
    # Extract just the command part
    generated_text = generated_text.split('\n')[-1].strip()
    return generated_text

def execute_command(command):
    try:
        subprocess.run(command, shell=True)
    except Exception as e:
        print(f"Error executing command: {e}")

# Main loop
while True:
    user_prompt = input("Enter your command: ")
    command = generate_command(user_prompt)
    print(f"Executing: {command}")
    execute_command(command)
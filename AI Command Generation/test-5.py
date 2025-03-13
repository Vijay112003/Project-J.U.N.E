import ollama
import threading
import itertools
import time

def animate_thinking(event):
    """ Displays an animated 'thinking...' effect until event is set. """
    for frame in itertools.cycle(["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]):
        if event.is_set():
            break
        print(f"\rBot is thinking {frame}", end="", flush=True)
        time.sleep(0.1)
    print("\r", end="")  # Clear the line after finishing

def chat_with_mistral():
    print("Ollama Chatbot (type 'exit' to quit)\n")

    chat_history = []
    while True:
        user_input = input("You: ")
        if user_input.lower() == "exit":
            print("Goodbye!")
            break

        chat_history.append({"role": "user", "content": user_input})

        # Start animation in a separate thread
        stop_event = threading.Event()
        animation_thread = threading.Thread(target=animate_thinking, args=(stop_event,))
        animation_thread.start()

        response = ollama.chat(model="mistral:7b", messages=chat_history)

        # Stop animation
        stop_event.set()
        animation_thread.join()

        bot_reply = response["message"]["content"]
        print("\nBot:", bot_reply)

        chat_history.append({"role": "assistant", "content": bot_reply})

if __name__ == "__main__":
    chat_with_mistral()

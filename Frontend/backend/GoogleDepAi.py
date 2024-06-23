from flask import Flask, request, jsonify
from vertexai.generative_models import GenerativeModel, HarmCategory, HarmBlockThreshold

app = Flask(__name__)

class ChatSession:
    def __init__(self):
        self.model = None
        self.chat = None

    def start_session(self):
        self.model = GenerativeModel(
            "gemini-1.0-pro-002",
            system_instruction=self.load_system_instruction(),
            safety_settings=self.load_safety_settings()
        )
        self.chat = self.model.start_chat()

    def load_system_instruction(self):
        try:
            with open('data.txt', 'r', encoding='utf-8') as file:
                return file.read()
        except FileNotFoundError:
            print("Error: Could not find the file 'data.txt'")
            return ""
        except UnicodeDecodeError:
            print("Error: Unable to decode the file with UTF-8 encoding")
            return ""
        
    def load_safety_settings(self):
        return {
            HarmCategory.HARM_CATEGORY_HATE_SPEECH: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
            HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
            HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT: HarmBlockThreshold.BLOCK_ONLY_HIGH,
            HarmCategory.HARM_CATEGORY_HARASSMENT: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE
        }    

    def send_message(self, user_input):
        response = self.chat.send_message(user_input)
        return response

chat_session = ChatSession()

@app.route('/start_session', methods=['POST'])
def start_session():
    chat_session.start_session()
    return jsonify({'message': 'Session started'})

@app.route('/send_message', methods=['POST'])
def send_message():
    user_input = request.json.get('user_input')
    if not chat_session.model or not chat_session.chat:
        return jsonify({'error': 'Session not started. Please start a session first.'}), 400
    response = chat_session.send_message([user_input])
    system_response = response.candidates[0].content.parts[0].text
    return jsonify({'system_response': system_response})

if __name__ == '__main__':
    app.run(debug=True)

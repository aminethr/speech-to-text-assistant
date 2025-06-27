# 🗣️ Voice AI Assistant App (Flutter + Django + OpenAI)

This is a voice-based AI assistant app built using **Flutter** for the frontend and **Django REST Framework** for the backend. It connects to **OpenAI's GPT model** to process voice queries and provide intelligent spoken responses. Users can sign up, log in, ask general or special requests (e.g., summaries), and access their conversation history.

---

## 🚀 Features

- 🎙️ **Voice Recognition**: Speak to the app instead of typing your request.
- 🤖 **GPT Integration**: Uses OpenAI's GPT (via Django backend) to generate responses.
- 🔐 **Authentication System**: Includes sign-up and login via Django REST framework with token-based authentication.
- 📚 **History Tracking**: View and delete past requests and AI responses.
- 📄 **Special Summarization**: Request summaries of books, articles, or long text passages.
- 🔊 **Text-to-Speech Output**: GPT's responses are read aloud using text-to-speech on the device.

---

## 🧱 Tech Stack

| Layer       | Technology         |
|------------|--------------------|
| Frontend   | Flutter (Dart)     |
| Backend    | Django + DRF       |
| AI Model   | OpenAI GPT-3.5     |
| Auth       | Django Token Auth  |
| Speech     | `speech_recognition`, Flutter TTS/STT plugins |

---

## 🧩 API Endpoints (Django)

### 🔐 Auth

- `POST /api/create_user/` — Create a new user account  
- `POST /api/login/` — Authenticate and receive a token

### 🗣️ NLP

- `POST /api/nlp_answer/` — Submit a voice query, get AI answer  
- `POST /api/summary_answer/` — Submit text to get a summary response  

### 📜 History

- `GET /api/history/` — Retrieve past user queries and responses  
- `DELETE /api/history/?id=<entry_id>` — Delete a specific entry  

### 🔑 Account

- `POST /api/change_password/` — Change user password securely  

---

## 📦 Backend Highlights

- Uses `speech_recognition` to handle user-transcribed voice input.
- Each voice query is saved to the database (`SpeechData`) along with the GPT-generated response (`NlpData`).
- Secure endpoints protected by `IsAuthenticated` permissions and token validation.
- Summarization logic prepends "give me the summary of this text" to support special requests.
- Password changes automatically update the session token to prevent logout.

---

## 🧠 Model Interaction

This project uses OpenAI’s `gpt-3.5-turbo` model to handle both direct Q&A and summarization tasks.

```python
response = client.chat.completions.create(
    model="gpt-3.5-turbo",
    messages=[{"role": "user", "content": aud_text}]
)

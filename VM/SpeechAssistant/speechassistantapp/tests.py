import pyaudio
from pocketsphinx import LiveSpeech

# Initialize PyAudio
pa = pyaudio.PyAudio()

# Define PocketSphinx configuration for live speech recognition
config = {
    'hmm': 'C:/Users/M-Tech/Desktop/Fai Project App/VM/speechassistantvm/Lib/site-packages/pocketsphinx/model/en-us/en-us',
    'lm': 'C:/Users/M-Tech/Desktop/Fai Project App/VM/speechassistantvm/Lib/site-packages/pocketsphinx/model/en-us/en-us.lm.bin',
    'dict': 'C:/Users/M-Tech/Desktop/Fai Project App/VM/speechassistantvm/Lib/site-packages/pocketsphinx/model/en-us/cmudict-en-us.dict'
}

# Create LiveSpeech object with PocketSphinx configuration
speech = LiveSpeech(**config)

# Function to capture and process live audio input
def recognize_speech():
    print("Listening...")

    # Open microphone stream
    stream = pa.open(format=pyaudio.paInt16, channels=1, rate=16000, input=True, frames_per_buffer=1024)

    # Process live audio stream
    for phrase in speech:
        print(phrase)

    # Close the microphone stream
    stream.stop_stream()
    stream.close()
    pa.terminate()

# Start recognizing live speech
recognize_speech()

from flask import Flask, Response
import cv2
import numpy as np
import mss

app = Flask(__name__)

def generate_frames():
    with mss.mss() as sct:
        monitor = sct.monitors[1]  # Full screen
        while True:
            img = np.array(sct.grab(monitor))
            frame = cv2.cvtColor(img, cv2.COLOR_BGRA2BGR)
            ret, buffer = cv2.imencode('.jpg', frame)
            frame_bytes = buffer.tobytes()
            yield (b'--frame\r\n'
                   b'Content-Type: image/jpeg\r\n\r\n' + frame_bytes + b'\r\n')

@app.route('/video')
def video():
    return Response(generate_frames(),
                    mimetype='multipart/x-mixed-replace; boundary=frame')

@app.route('/')
def index():
    return 'Video stream available at <a href="/video">/video</a>'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)

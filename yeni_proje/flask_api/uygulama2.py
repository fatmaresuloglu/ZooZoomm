import numpy as np
from flask import Flask, request, jsonify
import cv2
from ultralytics import YOLO

app = Flask(__name__)


model = YOLO('yolov8n.pt')

@app.route('/process_image', methods=['POST'])
def detect():
    try:
        if 'image' not in request.files:
            return jsonify({'error': 'No image provided'}), 400
        
        file = request.files['image']
        img = cv2.imdecode(np.frombuffer(file.read(), np.uint8), cv2.IMREAD_COLOR)
        
        # YOLO ile nesne tespiti yap
        results = model(img)
        
        detected_animals = []
        for box in results[0].boxes:
            cls = int(box.cls[0])
            label = model.names[cls]
            if label in ['cat', 'dog']:
                x1, y1, x2, y2 = map(int, box.xyxy[0])
                conf = float(box.conf[0])
                detected_animals.append({'label': label, 'confidence': conf, 'bbox': [x1, y1, x2, y2]})
        
        return jsonify({'detected_animals': detected_animals})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

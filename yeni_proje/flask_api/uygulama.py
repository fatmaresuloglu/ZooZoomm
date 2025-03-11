import numpy as np
from flask import Flask, jsonify, request
import cv2
from ultralytics import YOLO

app = Flask(__name__)

# YOLOv8 modelini yükle
model = YOLO('yolov8n.pt')

@app.route('/process_image', methods=['POST'])
def process_image():
    try:
        if 'image' not in request.files:
            return jsonify({'error': 'No image part in the request'}), 400
        
        file = request.files['image']
        print(f"File received: {file.filename}")

        # Resmi oku
        img = cv2.imdecode(np.frombuffer(file.read(), np.uint8), cv2.IMREAD_COLOR)

        # YOLO ile tahmin yap
        results = model(img)

        # Görüntüyü işaretle
        annotated_img = results[0].plot()

        # Tanınan hayvanları ve sayısını al
        boxes = results[0].boxes.data.cpu().numpy()
        animal_count = len(boxes)
        print(f'Tanımlanan hayvan sayısı: {animal_count}')

        _, img_encoded = cv2.imencode('.png', annotated_img)
        return img_encoded.tobytes(), 200, {'Content-Type': 'image/png'}
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)

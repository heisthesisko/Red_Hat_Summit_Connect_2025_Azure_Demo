import os
import json
import joblib
import numpy as np
from flask import Flask, request, jsonify

MODEL_PATH = os.environ.get("MODEL_PATH", "model.pkl")
PORT = int(os.environ.get("PORT", "8080"))

app = Flask(__name__)
model = joblib.load(MODEL_PATH)

@app.route("/healthz")
def healthz():
    return "ok"

@app.route("/predict", methods=["POST"])
def predict():
    try:
        data = request.get_json(force=True)
        features = np.array(data["features"], dtype=float).reshape(1, -1)
        pred = model.predict(features)[0]
        return jsonify({"prediction": str(pred)})
    except Exception as e:
        return jsonify({"error": str(e)}), 400

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=PORT)

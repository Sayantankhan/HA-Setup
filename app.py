# app.py
from flask import Flask
import uuid
import os

app = Flask(__name__)

@app.route("/")
def get_uuid():
    app_id = os.environ.get("APP_ID", "unknown")
    return {
        "uuid": str(uuid.uuid4())
    }

app.run(host="0.0.0.0", port=5000)

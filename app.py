# app.py
from flask import Flask
import uuid

app = Flask(__name__)

@app.route("/")
def get_uuid():
    return {"uuid": str(uuid.uuid4())}

app.run(host="0.0.0.0", port=5000)

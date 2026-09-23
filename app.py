import os
from flask import Flask, jsonify

app = Flask(__name__)


@app.route("/")
def home():
    return "<h1>Welcome to the DevOps CI/CD Pipeline! Version 2</h1>\n"


@app.route("/health")
def health_check():
    return jsonify({"status": "healthy", "application": "running"}), 200


if __name__ == "__main__":
    port = int(os.environ.get("FLASK_PORT", 5001))
    # 0.0.0.0 lets the app accept traffic from outside the container
    app.run(host="0.0.0.0", port=port)  # nosec B104

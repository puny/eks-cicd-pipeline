import random

from flask import Flask, jsonify

app = Flask(__name__)


@app.get("/health")
def health():
    return jsonify(status="ok")


@app.get("/api/lotto")
def lotto():
    return jsonify(numbers=sorted(random.sample(range(1, 46), 6)))


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)

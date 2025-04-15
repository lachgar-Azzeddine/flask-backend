from flask import Flask, render_template, jsonify

app = Flask(__name__)

# Home page (web)
@app.route("/")
def home():
    return render_template("index.html")

# API endpoint
@app.route("/api/message")
def api_message():
    return jsonify({"message": "Hello Azzeddine! This is your API response."})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

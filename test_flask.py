from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello():
    return "Hello World! Flask is working."

@app.route('/test')
def test():
    return {"status": "ok", "message": "Flask API is working"}

if __name__ == '__main__':
    print("Starting Flask test server on http://localhost:5000")
    app.run(host='0.0.0.0', port=5000, debug=True)

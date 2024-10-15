from flask import Flask
import os

app = Flask(__name__)

@app.route('/')
def index():
    return '''
        <html>
            <head><title>python-be-app02 website</title></head>
            <body>
                <h1>backend to python-be-app02</h1>
                <p>http status code 200 ok</p>
            </body>
        </html>
    '''

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5002)

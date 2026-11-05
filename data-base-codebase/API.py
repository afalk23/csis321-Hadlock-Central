import os
from bson import ObjectId
from flask_cors import CORS
from flask import *
from flask_pymongo import PyMongo
import json

app = Flask('Hadlock Central')

## set up the CORS and app for running and testing
CORS(app, resources=
    {
        r"/login":
        {
            "origins": ["http://localhost:58173"]
        }
    })

app.config["MONGO_URI"] = os.environ["MONGO_URI"]

mongo = PyMongo(app)

## A route for the login feature in the app
@app.route('/login', methods=['POST'])
def login():
    if mongo.db.Users.find_one({'email': request.json['email'], 'password': request.json['password']}):
        user = mongo.db.Users.find_one({'email': request.json['email'], 'password': request.json['password']})
        return {'message': 'Login Successful', 'success': True, 'user': user}
    else:
        return {'message': 'Login failed. Incorrect email or password.', 'success': False}

## A route for the register feature in the app
@app.route('/register', methods=['POST'])
def register():
    if mongo.db.Users.find_one({'email': request.json['email']}):
        return {'message' : 'That email is already in use.', 'success': False}
    else:
        mongo.db.Users.insert_one(request.json)
        return {'message': 'Success! You are being redirected to the login page.', 'success': True}


app.run(host='0.0.0.0',
        debug=True)
import os
from bson import ObjectId
from flask_cors import CORS
from flask import *
from flask_pymongo import PyMongo
import json

app = Flask('Hadlock Central')

# set up the CORS and app for running and testing
CORS(app, resources=
    {
        r"/login":
        {
            "origins": ["http://localhost:58173"]
        }
    })

app.config["MONGO_URI"] = os.environ["MONGO_URI"]

mongo = PyMongo(app)

@app.route('/login', methods=['POST'])
def login():
    '''
    A route for the login feature in the app
    :return: Message success or failure as well as user information
    '''
    message = {}
    
    if mongo.db.Users.find_one({'email': request.json['email'], 'password': request.json['password']}):
        user = mongo.db.Users.find_one({'email': request.json['email'], 'password': request.json['password']})
        # Return only profile fields needed by the app; never return a password.
        profile = {
            'id': str(user['_id']),
            'email': user.get('email', ''),
            'firstName': user.get('firstName', ''),
            'lastName': user.get('lastName', ''),
        }
        message = {'message': 'Login Successful', 'success': True, 'user': profile}
    else:
        message = {'message': 'Login failed. Incorrect email or password.', 'success': False}

    return message

@app.route('/register', methods=['POST'])
def register():
    '''
    A route for the register feature in the app
    :return: Success or failure
    '''

    message = {}

    if mongo.db.Users.find_one({'email': request.json['email']}):
        message = {'message' : 'That email is already in use.', 'success': False}
    else:
        mongo.db.Users.insert_one(request.json)
        message = {'message': 'Success! You are being redirected to the login page.', 'success': True}

    return message


app.run(host='0.0.0.0',
        debug=True)

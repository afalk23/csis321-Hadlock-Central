import os
from bson import ObjectId
from flask_cors import CORS
from flask import *
from flask_pymongo import PyMongo
import json

app = Flask('Hadlock Central')

CORS(app, resources=
    {
        r"/login":
        {
            "origins": ["http://localhost:58173"]
        }
    })

app.config["MONGO_URI"] = os.environ["MONGO_URI"]

##app.config['MONGO_URI'] = ('mongodb+srv://hadlockcentral_db_user:'
##                           '<Hadlock_Central>@hadlockcentral.mlnhddf.'
##                           'mongodb.net/HadlockCentralDB?retryWrites=true&w=majority')

mongo = PyMongo(app)

##try:
##    with app.app_context():
##        mongo.db.command("ping")
##        print("MongoDB connected successfully!")

##except Exception as e:
##    print("MongoDB connection failed:", type(e).__name__)

@app.route('/login', methods=['POST'])
def login():
    if mongo.db.Users.find_one({'email': request.json['email'], 'password': request.json['password']}):
        user = mongo.db.Users.find_one({'email': request.json['email'], 'password': request.json['password']})
        return {'message': 'Login Successful', 'success': True, 'user': user}
    else:
        return {'message': 'Login failed. Incorrect email or password.', 'success': False}

@app.route('/register', methods=['POST'])
def register():
    if mongo.db.Users.find_one({'email': request.json['email']}):
        return {'message' : 'That email is already in use.', 'success': False}
    else:
        mongo.db.Users.insert_one(request.json)
        return {'message': 'Success! You are being redirected to the login page.', 'success': True}


app.run(host='0.0.0.0',
        debug=True)
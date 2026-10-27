from bson import ObjectId
from flask import *
from flask_pymongo import PyMongo
import json

app = Flask('Hadlock Central')
app.config['MONGO_URI'] = ('mongodb+srv://hadlockcentral_db_user:'
                           '<db_password>@hadlockcentral.mlnhddf.'
                           'mongodb.net/HadlockCentralDB?retryWrites=true&w=majority')

mongo = PyMongo(app)

@app.route('/login', methods=['POST'])
def login():
    if mongo.db.Users.find_one({'email': request.json['email'], 'password': request.json['password']}):
        user = mongo.db.Users.find_one({'email': request.json['email'], 'password': request.json['password']})
        return {'message': 'Login Successful', 'success': True, 'user': user}
    else:
        return {'message': 'Login failed. Incorrect email or password.', 'success': False}
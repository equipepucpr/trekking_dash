from flask import Flask
from flask_cors import CORS, cross_origin
import time
import math
import random

start = time.time()
app = Flask(__name__)
cors = CORS(app)
app.config['CORS_HEADERS'] = 'Content-Type'

@app.route('/coordinates')
@cross_origin()
def coordinates():
    return {'Trekking':{'x': 15+10*math.cos((time.time() - start)*(2*math.pi)/10), 'y': 15+10*math.sin((time.time() - start)*(2*math.pi)/10)},
    'Cone 1': {'x':40,'y':20},
    'Cone 2': {'x':30,'y':2},
    'Cone 3': {'x':6,'y':18}}

@app.route('/ram_usage')
@cross_origin()
def ram_usage():
    used_ram = random.random()*0.2
    return {'used': used_ram, 'free': 2-used_ram}

@app.route('/pi_temp')
@cross_origin()
def pi_temp():
    return {'temperature': 40 + random.random()*20}


app.run()
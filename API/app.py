from flask import Flask, jsonify, request
import requests
from twilio.rest import Client

app = Flask(__name__)
@app.route('/', methods = ['GET'])

def return_hospitals():
    URL = "https://discover.search.hereapi.com/v1/discover"
    latitude = request.args.get('lat')
    # latitude = 31.7814767
    longitude = request.args.get('long')
    # longitude = 76.9987996
    api_key = '9OrtzZvYx8Ar9EwDYL1RHnUwjILi8ELPagPS6u3b3n0'
    query = 'hospital'
    limit = 5
    PARAMS = {
                'apikey':api_key,
                'q':query,
                'limit': limit,
                'at':'{},{}'.format(latitude,longitude)
            }

    r = requests.get(url = URL, params = PARAMS) 
    data = r.json()
    d_final = {}
    for i in range (0, 5):
        # d_temp = {'name': data['items'][i]['title'], 'address': data['items'][i]['address']['label'], 
        # 'distance': data['items'][i]['contacts']}
        # d_final[i] = d_temp
        try:
            d_temp = {'name': data['items'][i]['title'], 'address': data['items'][i]['address']['label'], 
            'distance': data['items'][i]['distance'], 'contact': data['items'][i]['contacts']}
            
            d_final[i] = d_temp
        except:
            d_temp = {'name': data['items'][i]['title'], 'address': data['items'][i]['address']['label'], 
            'distance': data['items'][i]['distance']}
            d_final[i] = d_temp

            
            
    # hospitalOne = data['items'][0]['title']
    # hospitalOne_address =  data['items'][0]['address']['label']
    # hospitalOne_latitude = data['items'][1]['position']['lat']

    #call function
    account_sid = 'AC03eebd5c1113aff00ef55f3963c1a9ba'
    auth_token = '33a00d2a29fe0ff62836112c99f76873'
    client = Client(account_sid, auth_token)
              # message: 'This is an attempt to send an alert from MEDICA,Our system has predicted a possibility of you being in an emergency situation at location: Latitude: $userLat, longitude: $userLong List of Nearest Hospitals: \n ${data['0']['name']} \n ${data['1']['name']} \n ${data['2']['name']} \n ${data['3']['name']} \n ${data['4']['name']}',

    string_1 = '<Response><Say language="en-IN" >This is an emergency alert from MEDICA. Our system has predicted a possibility of user being in an emergency situation at location with longitude' +str(longitude)+' degrees, and latitude '+str(latitude)+ ' degrees.</Say></Response>'

    call = client.calls.create(
                            twiml=string_1,
                            to=+917742127497,
                            from_=+15076075985
                        )



    return d_final

    
if __name__ == '__main__':
	app.run(debug = False)

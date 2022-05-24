from flask import Flask,render_template, jsonify
import requests






# hospitalTwo = data['items'][1]['title']
# hospitalTwo_address =  data['items'][1]['address']['label']
# hospitalTwo_latitude = data['items'][1]['position']['lat']
# hospitalTwo_longitude = data['items'][1]['position']['lng']

# hospitalThree = data['items'][2]['title']
# hospitalThree_address =  data['items'][2]['address']['label']
# hospitalThree_latitude = data['items'][2]['position']['lat']
# hospitalThree_longitude = data['items'][2]['position']['lng']


# hospitalFour = data['items'][3]['title']
# hospitalFour_address =  data['items'][3]['address']['label']
# hospitalFour_latitude = data['items'][3]['position']['lat']
# hospitalFour_longitude = data['items'][3]['position']['lng']

# hospitalFive = data['items'][4]['title']
# hospitalFive_address =  data['items'][4]['address']['label']
# hospitalFive_latitude = data['items'][4]['position']['lat']
# hospitalFive_longitude = data['items'][4]['position']['lng']

app = Flask(__name__)
@app.route('/')

def return_hospitals():
    URL = "https://discover.search.hereapi.com/v1/discover"
    latitude = 31.7814767
    longitude = 76.9987996
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

    hospitalOne = data['items'][0]['title']
    hospitalOne_address =  data['items'][0]['address']['label']
    hospitalOne_latitude = data['items'][0]['position']['lat']
    hospitalOne_longitude = data['items'][0]['position']['lng']

    return hospitalOne
    
if __name__ == '__main__':
	app.run(debug = False)

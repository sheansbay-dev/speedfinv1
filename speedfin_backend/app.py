# /speedfin_backend/app.py

from flask import Flask, request, jsonify
from flask_cors import CORS
import os
from dotenv import load_dotenv

# .env ගොනුවේ ඇති විචල්‍යයන් load කරන්න
load_dotenv() 

app = Flask(__name__)
# Flutter App එකෙන් API ඇමතීමට CORS අවශ්‍යයි
CORS(app) 

# Google Maps API Key එක Environment Variables වලින් ලබා ගන්න
# සැබෑ ලෝකයේදී ඔබ මෙම යතුර .env ගොනුවේ තබයි
GOOGLE_MAPS_API_KEY = os.getenv("GOOGLE_MAPS_API_KEY") 

# =================================================================
# 1. වේග සීමාව ලබා ගැනීමේ API (Roads API Mock)
# =================================================================
# සැබෑ ලෝකයේදී, මෙම ශ්‍රිතය සැබෑ Google Maps Roads API වෙත ඇමතීම සිදු කරයි
def get_speed_limit_from_api(lat, lon):
    """
    Given latitude and longitude, returns the speed limit (Mock).
    """
    # සැබෑ API ඇමතුම් තර්කනය මෙහිදී සිදුවිය යුතුය.
    # ఉదా:
    # url = f"https://roads.googleapis.com/v1/speedLimits?latlngs={lat},{lon}&key={GOOGLE_MAPS_API_KEY}"
    # response = requests.get(url).json()
    # return response['speedLimits'][0]['speedLimit'] # හෝ සමාන අගයක්

    # Mock Implementation: Flutter App එකේ තිබූ තර්කනයම මෙහි භාවිත කරමු
    if 45 < lat < 55:
        # මධ්‍යම යුරෝපයේ අධිවේගී මාර්ග අනුකරණය
        return 130
    elif 58 < lat < 65:
        # උතුරු යුරෝපය අනුකරණය
        return 100
    else:
        # නාගරික කලාප අනුකරණය
        return 50

@app.route('/api/speedlimit', methods=['GET'])
def speed_limit():
    lat = request.args.get('lat', type=float)
    lon = request.args.get('lon', type=float)

    if lat is None or lon is None:
        return jsonify({"error": "Missing latitude or longitude"}), 400

    limit = get_speed_limit_from_api(lat, lon)
    
    return jsonify({"limit": limit, "unit": "KPH"}), 200

# =================================================================
# 2. දඩපත් සටහන් කිරීමේ API (Fine Logging)
# =================================================================
@app.route('/api/logfine', methods=['POST'])
def log_fine():
    data = request.get_json()
    
    # 1. දත්ත වලංගු කිරීම
    required_fields = ['actualSpeed', 'speedLimit', 'latitude', 'longitude']
    if not all(field in data for field in required_fields):
        return jsonify({"error": "Missing required fine data"}), 400

    # 2. දත්ත ගබඩාවේ සටහන් කිරීම (මෙම කොටස පසුව එකතු කරමු)
    # save_fine_to_database(data) 

    print(f"Fine Logged: {data['actualSpeed']} in {data['speedLimit']} zone at {data['latitude']}, {data['longitude']}")
    
    # 3. සාර්ථක ප්‍රතිචාරය
    return jsonify({"message": "Fine logged successfully", "fineId": "MOCK-12345"}), 201


if __name__ == '__main__':
    # .env ගොනුවක් සාදා එහි GOOGLE_MAPS_API_KEY=YOUR_KEY ලෙස ඇතුළත් කරන්න
    if not GOOGLE_MAPS_API_KEY:
        print("WARNING: GOOGLE_MAPS_API_KEY is not set in environment variables.")

    # 5000 Port එකේදී Backend එක ධාවනය කරන්න
    app.run(debug=True, port=5000)
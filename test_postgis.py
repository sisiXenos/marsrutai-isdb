#!/usr/bin/env python3
"""
Test script for PostGIS spatial functions
Run this after starting the backend to verify PostGIS features work correctly
"""

import requests
import json

BASE_URL = "http://localhost:5000"

def print_section(title):
    print("\n" + "="*60)
    print(f"  {title}")
    print("="*60)

def test_distance_calculation():
    print_section("TEST 1: Calculate Distance Between Stops")
    
    # Test with stops 1 and 2
    response = requests.get(f"{BASE_URL}/api/stoteles/distance", params={
        'stop1_id': 1,
        'stop2_id': 2
    })
    
    print(f"Status Code: {response.status_code}")
    data = response.json()
    print(json.dumps(data, indent=2, ensure_ascii=False))
    
    if data.get('success'):
        print(f"\n✓ Successfully calculated distance!")
        print(f"  {data['stotele_1']['pavadinimas']} → {data['stotele_2']['pavadinimas']}")
        print(f"  Distance: {data['distance_meters']} meters ({data['distance_km']} km)")
    else:
        print(f"✗ Error: {data.get('error')}")

def test_nearby_stops():
    print_section("TEST 2: Find Nearby Stops")
    
    # Find stops within 5000m of stop 1
    response = requests.get(f"{BASE_URL}/api/stoteles/nearby/1", params={
        'radius': 5000
    })
    
    print(f"Status Code: {response.status_code}")
    data = response.json()
    print(json.dumps(data, indent=2, ensure_ascii=False))
    
    if data.get('success'):
        print(f"\n✓ Successfully found nearby stops!")
        print(f"  Reference: {data['reference_stop']['pavadinimas']}")
        print(f"  Radius: {data['radius_km']} km")
        print(f"  Found: {data['count']} stops")
        
        if data['nearby_stops']:
            print("\n  Nearby stops:")
            for stop in data['nearby_stops'][:5]:  # Show first 5
                print(f"    - {stop['pavadinimas']}: {stop['distance_meters']} m")
    else:
        print(f"✗ Error: {data.get('error')}")

def test_all_stops():
    print_section("INFO: Available Stops in Database")
    
    response = requests.get(f"{BASE_URL}/api/stoteles")
    data = response.json()
    
    if data.get('success'):
        stops = data['data']
        print(f"Total stops: {len(stops)}\n")
        for stop in stops[:10]:  # Show first 10
            print(f"  ID {stop['stotele_id']}: {stop['pavadinimas']} ({stop['lon']}, {stop['lat']})")
        if len(stops) > 10:
            print(f"  ... and {len(stops) - 10} more stops")
    else:
        print(f"✗ Error: {data.get('error')}")

def test_api_endpoints():
    print_section("INFO: API Endpoints")
    
    response = requests.get(f"{BASE_URL}/")
    data = response.json()
    print(json.dumps(data, indent=2, ensure_ascii=False))

def main():
    print("\n" + "🗺️ " * 20)
    print("  PostGIS Spatial Functions Test Suite")
    print("🗺️ " * 20)
    
    try:
        # Test API is running
        test_api_endpoints()
        
        # Show available stops
        test_all_stops()
        
        # Test distance calculation
        test_distance_calculation()
        
        # Test nearby stops
        test_nearby_stops()
        
        print_section("✓ All Tests Complete!")
        print("\nYou can now:")
        print("  1. Open http://localhost:8088 in your browser")
        print("  2. Try the PostGIS features in the UI")
        print("  3. Calculate distances between any stops")
        print("  4. Find nearby stops with custom radius")
        
    except requests.exceptions.ConnectionError:
        print("\n✗ ERROR: Cannot connect to backend at http://localhost:5000")
        print("  Make sure the Flask backend is running!")
        print("  Run: docker-compose up")
    except Exception as e:
        print(f"\n✗ ERROR: {type(e).__name__}: {e}")

if __name__ == "__main__":
    main()

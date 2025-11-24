# Simple Command List - Database Fragmentation Demo

## 1. Start Docker

```bash
./start.sh
```

## 2. Create Route (Maršrutinis → DB11/DB21)

```bash
curl -X POST http://localhost:5000/api/marsrutai \
  -H "Content-Type: application/json" \
  -d '{
    "marsrutas_id": 10,
    "kelias": "LINESTRING(25.50 54.80, 25.55 54.85)",
    "atstumas_km": 8.5,
    "trukme_min": 22,
    "aktyvus": true,
    "pavadinimas": "Test Route 10",
    "marsruto_tipas_id": 1,
    "aptarnavimas_id": 1
  }'
```

## 3. Create Route (Tarpmiestinis → DB12/DB22)

```bash
curl -X POST http://localhost:5000/api/marsrutai \
  -H "Content-Type: application/json" \
  -d '{
    "marsrutas_id": 11,
    "kelias": "LINESTRING(25.60 54.90, 25.65 54.95)",
    "atstumas_km": 35.0,
    "trukme_min": 65,
    "aktyvus": true,
    "pavadinimas": "Test Route 11",
    "marsruto_tipas_id": 2,
    "aptarnavimas_id": 2
  }'
```

## 4. Read All Routes

```bash
curl http://localhost:5000/api/marsrutai | jq
```

## 5. Read Specific Route (gets spatial + business data)

```bash
curl http://localhost:5000/api/marsrutai?id=1 | jq
```

## 6. Read Route 5 (exists in BOTH DB pairs)

```bash
curl http://localhost:5000/api/marsrutai?id=5 | jq
```

## 7. Update Route

```bash
curl -X PUT http://localhost:5000/api/marsrutai/1 \
  -H "Content-Type: application/json" \
  -d '{"pavadinimas": "Updated Route", "atstumas_km": 15.0}'
```

## 8. Delete Route

```bash
curl -X DELETE http://localhost:5000/api/marsrutai/10
```

## 9. Verify in Database

```bash
# Check Maršrutinis routes (DB11/DB21)
docker exec -it db11 psql -U postgres -d spatial -c "SELECT * FROM marsrutai_spatial;"
docker exec -it db21 psql -U postgres -d business -c "SELECT * FROM marsrutai_business;"

# Check Tarpmiestinis routes (DB12/DB22)
docker exec -it db12 psql -U postgres -d spatial -c "SELECT * FROM marsrutai_spatial;"
docker exec -it db22 psql -U postgres -d business -c "SELECT * FROM marsrutai_business;"
```

## What This Demonstrates

- **Vertical Fragmentation**: Spatial data (DB11/DB12) separate from business data (DB21/DB22)
- **Horizontal Fragmentation**: Routes split by type (Maršrutinis vs Tarpmiestinis)
- **CRUD Operations**: Create, Read, Update, Delete across all databases
- **Synchronization**: Changes reflected in both spatial and business databases

## PostGIS Spatial Functions

### Calculate Distance Between Two Stops

```bash
# Calculate distance between stop 1 and stop 2
curl "http://localhost:5000/api/stoteles/distance?stop1_id=1&stop2_id=2" | jq
```

**Response:**
```json
{
  "success": true,
  "stotele_1": {
    "id": 1,
    "pavadinimas": "Stotis"
  },
  "stotele_2": {
    "id": 2,
    "pavadinimas": "Centras"
  },
  "distance_meters": 5678.45,
  "distance_km": 5.68
}
```

### Find Nearby Stops

```bash
# Find all stops within 2000 meters of stop 1
curl "http://localhost:5000/api/stoteles/nearby/1?radius=2000" | jq

# Find stops within 5 kilometers
curl "http://localhost:5000/api/stoteles/nearby/1?radius=5000" | jq
```

**Response:**
```json
{
  "success": true,
  "reference_stop": {
    "id": 1,
    "pavadinimas": "Stotis",
    "lon": 25.3,
    "lat": 54.7
  },
  "radius_meters": 2000,
  "radius_km": 2.0,
  "nearby_stops": [
    {
      "stotele_id": 2,
      "pavadinimas": "Centras",
      "distance_meters": 1234.56,
      "distance_km": 1.23
    }
  ],
  "count": 1
}
```

### Test PostGIS Features

```bash
# Run the test script
python test_postgis.py
```

### PostGIS Functions Used

- **ST_Distance**: Calculates accurate distance between two geographic points in meters
- **ST_DWithin**: Efficiently finds all points within a radius (uses spatial index)
- **ST_Transform**: Converts coordinates to Web Mercator (EPSG:3857) for accurate measurements

See `POSTGIS_FEATURES.md` for detailed documentation.

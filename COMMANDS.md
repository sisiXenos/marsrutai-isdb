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

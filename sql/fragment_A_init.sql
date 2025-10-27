-- DB11: Spatial Fragment
CREATE EXTENSION IF NOT EXISTS postgis;

-- Needed reference tables (for FKs)
CREATE TABLE marsruto_tipas (
    marsruto_tipas_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

INSERT INTO marsruto_tipas (name) VALUES
('Maršrutinis'),
('Tarpmiestinis');


CREATE TABLE aptarnavimas (
    aptarnavimas_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

INSERT INTO aptarnavimas (name) VALUES
('Darbo diena'),
('Savaitgalis');

CREATE TABLE paviljono_tipas (
    paviljono_tipas_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

INSERT INTO paviljono_tipas (name) VALUES
('Atvira'),
('Uždara'),
('Be paviljono');

-- Fragmented marsrutai: only spatial attributes
CREATE TABLE marsrutai_spatial (
    marsrutas_id INT PRIMARY KEY,
    kelias GEOMETRY(LINESTRING, 4326),
    atstumas_km DOUBLE PRECISION,
    trukme_min DOUBLE PRECISION,
    aktyvus BOOLEAN
);

-- Stops
CREATE TABLE stoteles (
    stotele_id SERIAL PRIMARY KEY,
    pavadinimas VARCHAR(255),
    stoteles_erdvine_vieta GEOMETRY(POINT, 4326),
    paviljono_tipas_id INT REFERENCES paviljono_tipas(paviljono_tipas_id)
);

-- Route stops
CREATE TABLE marsruto_stoteles (
    marsruto_stotele_id SERIAL PRIMARY KEY,
    eiles_nr_marsrute INT,
    atstumas_nuo_pradzios DOUBLE PRECISION,
    stotele_id INT NOT NULL REFERENCES stoteles(stotele_id),
    marsrutas_id INT NOT NULL REFERENCES marsrutai_spatial(marsrutas_id)
);

-- Journey times
CREATE TABLE reisu_laikai (
    laikas_id SERIAL PRIMARY KEY,
    nuvaziuotas_atstumas DOUBLE PRECISION,
    faktinis_atvykimo_laikas TIMESTAMP,
    faktinis_isvykimo_laikas TIMESTAMP,
    planuojamas_atvykimo_laikas TIMESTAMP,
    planuojamas_isvykimo_laikas TIMESTAMP,
    marsruto_stotele_id INT NOT NULL REFERENCES marsruto_stoteles(marsruto_stotele_id)
);

-- DB11 DATA

-- Routes 1–5 spatial half
INSERT INTO marsrutai_spatial VALUES
(1, ST_GeomFromText('LINESTRING(25.30 54.70,25.35 54.72)',4326), 12.1, 30, TRUE),
(2, ST_GeomFromText('LINESTRING(25.31 54.71,25.36 54.73)',4326), 15.2, 40, TRUE),
(3, ST_GeomFromText('LINESTRING(25.32 54.72,25.37 54.74)',4326), 10.0, 25, TRUE),
(4, ST_GeomFromText('LINESTRING(25.33 54.73,25.38 54.75)',4326), 20.5, 50, FALSE),
(5, ST_GeomFromText('LINESTRING(25.34 54.74,25.39 54.76)',4326), 18.0, 45, TRUE);

-- Stops for each route
INSERT INTO stoteles (pavadinimas,stoteles_erdvine_vieta,paviljono_tipas_id) VALUES
('Stotis',ST_SetSRID(ST_Point(25.30,54.70),4326),1),
('Centras',ST_SetSRID(ST_Point(25.31,54.71),4326),2),
('Universitetas',ST_SetSRID(ST_Point(25.32,54.72),4326),3),
('Klinikos',ST_SetSRID(ST_Point(25.33,54.73),4326),1),
('Parkas',ST_SetSRID(ST_Point(25.34,54.74),4326),2),
('Stadionas',ST_SetSRID(ST_Point(25.35,54.75),4326),3),
('Teatras',ST_SetSRID(ST_Point(25.36,54.76),4326),1),
('Poliklinika',ST_SetSRID(ST_Point(25.37,54.77),4326),2),
('Biblioteka',ST_SetSRID(ST_Point(25.38,54.78),4326),3),
('Oro uostas',ST_SetSRID(ST_Point(25.39,54.79),4326),1);

-- Route stops (attach subset of stops to routes)
INSERT INTO marsruto_stoteles (eiles_nr_marsrute,atstumas_nuo_pradzios,stotele_id,marsrutas_id) VALUES
(1,0,1,1),(2,3.0,2,1),
(1,0,3,2),(2,4.0,4,2),
(1,0,5,3),(2,2.0,6,3),
(1,0,7,4),(2,5.5,8,4),
(1,0,9,5),(2,6.0,10,5);

-- Journey times (referencing marsruto_stoteles)
INSERT INTO reisu_laikai (nuvaziuotas_atstumas,faktinis_atvykimo_laikas,faktinis_isvykimo_laikas,
planuojamas_atvykimo_laikas,planuojamas_isvykimo_laikas,marsruto_stotele_id) VALUES
(0,'2024-06-01 08:00','2024-06-01 08:05','2024-06-01 08:00','2024-06-01 08:05',1),
(3,'2024-06-01 08:20','2024-06-01 08:21','2024-06-01 08:18','2024-06-01 08:19',2),
(0,'2024-06-01 09:00','2024-06-01 09:02','2024-06-01 09:00','2024-06-01 09:02',3),
(4,'2024-06-01 09:20','2024-06-01 09:21','2024-06-01 09:18','2024-06-01 09:19',4),
(0,'2024-06-01 10:00','2024-06-01 10:02','2024-06-01 10:00','2024-06-01 10:02',5);
-- DB12 DATA

INSERT INTO marsrutai_spatial VALUES
(6, ST_GeomFromText('LINESTRING(25.40 54.70,25.45 54.72)',4326), 13.0, 32, TRUE),
(7, ST_GeomFromText('LINESTRING(25.41 54.71,25.46 54.73)',4326), 16.0, 42, TRUE),
(8, ST_GeomFromText('LINESTRING(25.42 54.72,25.47 54.74)',4326), 11.0, 26, FALSE),
(9, ST_GeomFromText('LINESTRING(25.43 54.73,25.48 54.75)',4326), 22.0, 55, TRUE),
(10, ST_GeomFromText('LINESTRING(25.44 54.74,25.49 54.76)',4326), 19.0, 48, TRUE);

-- Stops
INSERT INTO stoteles (pavadinimas,stoteles_erdvine_vieta,paviljono_tipas_id) VALUES
('Akropolis',ST_SetSRID(ST_Point(25.40,54.70),4326),1),
('Zoo Park',ST_SetSRID(ST_Point(25.41,54.71),4326),2),
('Technikos Muziejus',ST_SetSRID(ST_Point(25.42,54.72),4326),3),
('Jūra',ST_SetSRID(ST_Point(25.43,54.73),4326),1),
('Tiltas',ST_SetSRID(ST_Point(25.44,54.74),4326),2);

-- Route stops
INSERT INTO marsruto_stoteles (eiles_nr_marsrute,atstumas_nuo_pradzios,stotele_id,marsrutas_id) VALUES
(1,0,1,6),(2,3.5,2,6),
(1,0,3,7),(2,2.5,4,7),
(1,0,5,8);

-- Times
INSERT INTO reisu_laikai (nuvaziuotas_atstumas,faktinis_atvykimo_laikas,faktinis_isvykimo_laikas,
planuojamas_atvykimo_laikas,planuojamas_isvykimo_laikas,marsruto_stotele_id) VALUES
(0,'2024-06-02 08:00','2024-06-02 08:03','2024-06-02 08:00','2024-06-02 08:03',1),
(3.5,'2024-06-02 08:20','2024-06-02 08:21','2024-06-02 08:18','2024-06-02 08:19',2);

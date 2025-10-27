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
    stotele_id INT PRIMARY KEY, -- Pakeista į INT, kad atitiktų GTFS stop_id
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

INSERT INTO marsrutai_spatial VALUES
(1, ST_GeomFromText('LINESTRING(23.88 54.89, 23.90 54.90, 23.92 54.91, 23.94 54.92, 23.95 54.93)',4326), 10, 30, TRUE),
(2, ST_GeomFromText('LINESTRING(23.88 54.88, 23.89 54.89, 23.91 54.90, 23.93 54.91, 23.94 54.92)',4326), 12, 35, TRUE),
(3, ST_GeomFromText('LINESTRING(23.89 54.88, 23.90 54.89, 23.91 54.90, 23.92 54.91, 23.93 54.92)',4326), 11, 33, TRUE),
(4, ST_GeomFromText('LINESTRING(23.87 54.88, 23.88 54.89, 23.89 54.90, 23.90 54.91, 23.91 54.92)',4326), 9, 28, TRUE),
(5, ST_GeomFromText('LINESTRING(23.86 54.87, 23.87 54.88, 23.88 54.89, 23.89 54.90, 23.90 54.91)',4326), 10, 30, TRUE);

-- 25 Stotelės (5 per route)
INSERT INTO stoteles (stotele_id, pavadinimas, stoteles_erdvine_vieta, paviljono_tipas_id) VALUES
(1,'Stotis',ST_SetSRID(ST_Point(23.88,54.89),4326),1),
(2,'Centras',ST_SetSRID(ST_Point(23.90,54.90),4326),2),
(3,'Universitetas',ST_SetSRID(ST_Point(23.92,54.91),4326),3),
(4,'Klinikos',ST_SetSRID(ST_Point(23.94,54.92),4326),1),
(5,'Parkas',ST_SetSRID(ST_Point(23.95,54.93),4326),2),

(6,'Akropolis',ST_SetSRID(ST_Point(23.88,54.88),4326),1),
(7,'Zoo Park',ST_SetSRID(ST_Point(23.89,54.89),4326),2),
(8,'Technikos Muziejus',ST_SetSRID(ST_Point(23.91,54.90),4326),3),
(9,'Tiltas',ST_SetSRID(ST_Point(23.93,54.91),4326),1),
(10,'Oro Uostas',ST_SetSRID(ST_Point(23.94,54.92),4326),2),

(11,'Stadionas',ST_SetSRID(ST_Point(23.89,54.88),4326),1),
(12,'Teatras',ST_SetSRID(ST_Point(23.90,54.89),4326),2),
(13,'Poliklinika',ST_SetSRID(ST_Point(23.91,54.90),4326),3),
(14,'Biblioteka',ST_SetSRID(ST_Point(23.92,54.91),4326),1),
(15,'Kauno Arena',ST_SetSRID(ST_Point(23.93,54.92),4326),2),

(16,'Muziejus',ST_SetSRID(ST_Point(23.87,54.88),4326),1),
(17,'Bažnyčia',ST_SetSRID(ST_Point(23.88,54.89),4326),2),
(18,'Senamiestis',ST_SetSRID(ST_Point(23.89,54.90),4326),3),
(19,'Nemunas',ST_SetSRID(ST_Point(23.90,54.91),4326),1),
(20,'Ąžuolynas',ST_SetSRID(ST_Point(23.91,54.92),4326),2),

(21,'Pilaitė',ST_SetSRID(ST_Point(23.86,54.87),4326),1),
(22,'Vingis',ST_SetSRID(ST_Point(23.87,54.88),4326),2),
(23,'Ąžuolas',ST_SetSRID(ST_Point(23.88,54.89),4326),3),
(24,'Laisvės al.',ST_SetSRID(ST_Point(23.89,54.90),4326),1),
(25,'Karaliaus Mindaugo pr.',ST_SetSRID(ST_Point(23.90,54.91),4326),2);

-- Maršruto stotelės (5 per route)
INSERT INTO marsruto_stoteles (eiles_nr_marsrute,atstumas_nuo_pradzios,stotele_id,marsrutas_id) VALUES
(1,0,1,1),(2,2,2,1),(3,4,3,1),(4,6,4,1),(5,8,5,1),
(1,0,6,2),(2,2,7,2),(3,4,8,2),(4,6,9,2),(5,8,10,2),
(1,0,11,3),(2,2,12,3),(3,4,13,3),(4,6,14,3),(5,8,15,3),
(1,0,16,4),(2,2,17,4),(3,4,18,4),(4,6,19,4),(5,8,20,4),
(1,0,21,5),(2,2,22,5),(3,4,23,5),(4,6,24,5),(5,8,25,5);

-- Reisu laikai (Kauno maršrutai, po 5 stoteles kiekvienam)
INSERT INTO reisu_laikai (nuvaziuotas_atstumas, faktinis_atvykimo_laikas, faktinis_isvykimo_laikas,
                          planuojamas_atvykimo_laikas, planuojamas_isvykimo_laikas, marsruto_stotele_id)
VALUES
-- Maršrutas 1
(0, '2025-10-27 08:00', '2025-10-27 08:02', '2025-10-27 08:00', '2025-10-27 08:02', 1),
(2, '2025-10-27 08:05', '2025-10-27 08:06', '2025-10-27 08:04', '2025-10-27 08:05', 2),
(4, '2025-10-27 08:10', '2025-10-27 08:11', '2025-10-27 08:09', '2025-10-27 08:10', 3),
(6, '2025-10-27 08:15', '2025-10-27 08:16', '2025-10-27 08:14', '2025-10-27 08:15', 4),
(8, '2025-10-27 08:20', '2025-10-27 08:21', '2025-10-27 08:19', '2025-10-27 08:20', 5),

-- Maršrutas 2
(0, '2025-10-27 09:00', '2025-10-27 09:02', '2025-10-27 09:00', '2025-10-27 09:02', 6),
(2, '2025-10-27 09:05', '2025-10-27 09:06', '2025-10-27 09:04', '2025-10-27 09:05', 7),
(4, '2025-10-27 09:10', '2025-10-27 09:11', '2025-10-27 09:09', '2025-10-27 09:10', 8),
(6, '2025-10-27 09:15', '2025-10-27 09:16', '2025-10-27 09:14', '2025-10-27 09:15', 9),
(8, '2025-10-27 09:20', '2025-10-27 09:21', '2025-10-27 09:19', '2025-10-27 09:20', 10),

-- Maršrutas 3
(0, '2025-10-27 10:00', '2025-10-27 10:02', '2025-10-27 10:00', '2025-10-27 10:02', 11),
(2, '2025-10-27 10:05', '2025-10-27 10:06', '2025-10-27 10:04', '2025-10-27 10:05', 12),
(4, '2025-10-27 10:10', '2025-10-27 10:11', '2025-10-27 10:09', '2025-10-27 10:10', 13),
(6, '2025-10-27 10:15', '2025-10-27 10:16', '2025-10-27 10:14', '2025-10-27 10:15', 14),
(8, '2025-10-27 10:20', '2025-10-27 10:21', '2025-10-27 10:19', '2025-10-27 10:20', 15),

-- Maršrutas 4
(0, '2025-10-27 11:00', '2025-10-27 11:02', '2025-10-27 11:00', '2025-10-27 11:02', 16),
(2, '2025-10-27 11:05', '2025-10-27 11:06', '2025-10-27 11:04', '2025-10-27 11:05', 17),
(4, '2025-10-27 11:10', '2025-10-27 11:11', '2025-10-27 11:09', '2025-10-27 11:10', 18),
(6, '2025-10-27 11:15', '2025-10-27 11:16', '2025-10-27 11:14', '2025-10-27 11:15', 19),
(8, '2025-10-27 11:20', '2025-10-27 11:21', '2025-10-27 11:19', '2025-10-27 11:20', 20),

-- Maršrutas 5
(0, '2025-10-27 12:00', '2025-10-27 12:02', '2025-10-27 12:00', '2025-10-27 12:02', 21),
(2, '2025-10-27 12:05', '2025-10-27 12:06', '2025-10-27 12:04', '2025-10-27 12:05', 22),
(4, '2025-10-27 12:10', '2025-10-27 12:11', '2025-10-27 12:09', '2025-10-27 12:10', 23),
(6, '2025-10-27 12:15', '2025-10-27 12:16', '2025-10-27 12:14', '2025-10-27 12:15', 24),
(8, '2025-10-27 12:20', '2025-10-27 12:21', '2025-10-27 12:19', '2025-10-27 12:20', 25);



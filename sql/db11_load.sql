-- DB11 DATA (Maršrutinis routes - marsruto_tipas_id = 1)

-- Routes 1-3: Maršrutinis type - spatial half
-- Route 5 also exists here (different route than the one in DB12)
INSERT INTO marsrutai_spatial VALUES
(1, ST_GeomFromText('LINESTRING(25.30 54.70,25.35 54.72)',4326), 12.1, 30, TRUE),
(2, ST_GeomFromText('LINESTRING(25.31 54.71,25.36 54.73)',4326), 15.2, 40, TRUE),
(3, ST_GeomFromText('LINESTRING(25.32 54.72,25.37 54.74)',4326), 10.0, 25, TRUE),
(5, ST_GeomFromText('LINESTRING(25.35 54.75,25.40 54.78)',4326), 9.5, 28, TRUE);

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

-- Route stops (attach subset of stops to routes 1-3 and 5)
INSERT INTO marsruto_stoteles (eiles_nr_marsrute,atstumas_nuo_pradzios,stotele_id,marsrutas_id) VALUES
(1,0,1,1),(2,3.0,2,1),
(1,0,3,2),(2,4.0,4,2),
(1,0,5,3),(2,2.0,6,3),
(1,0,7,5),(2,2.5,8,5);

-- Journey times (referencing marsruto_stoteles)
INSERT INTO reisu_laikai (nuvaziuotas_atstumas,faktinis_atvykimo_laikas,faktinis_isvykimo_laikas,
planuojamas_atvykimo_laikas,planuojamas_isvykimo_laikas,marsruto_stotele_id) VALUES
(0,'2024-06-01 08:00','2024-06-01 08:05','2024-06-01 08:00','2024-06-01 08:05',1),
(3,'2024-06-01 08:20','2024-06-01 08:21','2024-06-01 08:18','2024-06-01 08:19',2),
(0,'2024-06-01 09:00','2024-06-01 09:02','2024-06-01 09:00','2024-06-01 09:02',3),
(4,'2024-06-01 09:20','2024-06-01 09:21','2024-06-01 09:18','2024-06-01 09:19',4),
(0,'2024-06-01 10:00','2024-06-01 10:02','2024-06-01 10:00','2024-06-01 10:02',5);

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

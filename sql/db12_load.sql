-- DB12 DATA (Tarpmiestinis routes - marsruto_tipas_id = 2)

-- Routes 4-5: Tarpmiestinis type - spatial half
-- Route 5 exists in both DB11 and DB12 as DIFFERENT routes
INSERT INTO marsrutai_spatial VALUES
(4, ST_GeomFromText('LINESTRING(25.33 54.73,25.38 54.75)',4326), 20.5, 50, FALSE),
(5, ST_GeomFromText('LINESTRING(25.34 54.74,25.39 54.76)',4326), 18.0, 45, TRUE);

-- Stops
INSERT INTO stoteles (pavadinimas,stoteles_erdvine_vieta,paviljono_tipas_id) VALUES
('Klinikos',ST_SetSRID(ST_Point(25.33,54.73),4326),1),
('Parkas',ST_SetSRID(ST_Point(25.34,54.74),4326),2),
('Stadionas',ST_SetSRID(ST_Point(25.35,54.75),4326),3),
('Teatras',ST_SetSRID(ST_Point(25.36,54.76),4326),1),
('Poliklinika',ST_SetSRID(ST_Point(25.37,54.77),4326),2);

-- Route stops (for routes 4-5)
INSERT INTO marsruto_stoteles (eiles_nr_marsrute,atstumas_nuo_pradzios,stotele_id,marsrutas_id) VALUES
(1,0,1,4),(2,5.5,2,4),
(1,0,3,5),(2,6.0,4,5);

-- Times
INSERT INTO reisu_laikai (nuvaziuotas_atstumas,faktinis_atvykimo_laikas,faktinis_isvykimo_laikas,
planuojamas_atvykimo_laikas,planuojamas_isvykimo_laikas,marsruto_stotele_id) VALUES
(0,'2024-06-02 08:00','2024-06-02 08:03','2024-06-02 08:00','2024-06-02 08:03',1),
(3.5,'2024-06-02 08:20','2024-06-02 08:21','2024-06-02 08:18','2024-06-02 08:19',2);

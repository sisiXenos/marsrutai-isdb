-- DB21 DATA (Maršrutinis routes - marsruto_tipas_id = 1)

-- Routes 1-3: Maršrutinis type - business attributes
-- Route 5 also stored here (completely different from route 5 in DB22)
INSERT INTO marsrutai_business VALUES
(1,'1G Oro uostas - Centras',1,1),
(2,'2G Centras - Stotis',1,2),
(3,'3G Klinikos - Parkas',1,1),
(5,'5A City Route',1,1);

-- Tickets and zones
INSERT INTO bilietu_zonos (pavadinimas,kaina,galiojimo_laikas_pradzia,galiojimo_laikas_pabaiga,zonos_ribos,bilieto_tipas_id) VALUES
('A',1.0,'2024-01-01','2024-12-31',ST_GeomFromText('POLYGON((25.30 54.70,25.31 54.70,25.31 54.71,25.30 54.71,25.30 54.70))',4326),1),
('B',1.5,'2024-01-01','2024-12-31',ST_GeomFromText('POLYGON((25.32 54.72,25.33 54.72,25.33 54.73,25.32 54.73,25.32 54.72))',4326),2);

-- Drivers
INSERT INTO vairuotojai (vardas,pavarde,gimimo_data,pazymejimo_nr,darbo_pradzios_data,atlyginimas) VALUES
('Jonas','Jonaitis','1980-01-01','VR100','2010-01-01',1500.00),
('Petras','Petraitis','1985-05-05','VR101','2012-02-02',1600.00),
('Ona','Onaitė','1990-09-09','VR102','2015-05-05',1700.00),
('Ieva','Ivanauskaitė','1992-07-07','VR103','2018-01-01',1400.00),
('Kazys','Kazlauskas','1975-08-08','VR104','2005-01-01',2000.00);

-- Vehicles
INSERT INTO transporto_priemones (kodas,vietu_sk,pagaminimo_metai,registracijos_nr,paskutine_apziura_data,tipas_id,degalu_tipas_id) VALUES
('T001',40,2015,'AAA001','2024-01-01',1,1),
('T002',30,2017,'AAA002','2023-06-15',2,2),
('T003',20,2018,'AAA003','2022-04-10',3,3),
('T004',50,2012,'AAA004','2022-10-11',1,4),
('T005',45,2016,'AAA005','2023-01-05',1,2);

-- Trips (only for Maršrutinis routes 1-3 and 5)
INSERT INTO reisai (keleiviu_sk,priemone_id,vairuotojas_id,marsrutas_id) VALUES
(30,1,1,1),(45,2,2,2),(22,3,3,3),(28,4,4,5);

-- Stops business attrs
INSERT INTO adresas (miestas,salis,gatve,gatves_pradzia,gatves_pabaiga) VALUES
('Vilnius','LT','Geležinkelio g.','1','50'),
('Vilnius','LT','Ozo g.','1','40');

INSERT INTO stoteles_business (stotele_id,zona_id,adresas_id) VALUES
(1,1,1),(2,2,2);

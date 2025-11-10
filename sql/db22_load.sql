-- DB22 DATA (Tarpmiestinis routes - marsruto_tipas_id = 2)

-- Routes 4-5: Tarpmiestinis type - business attributes
-- Route 5 stored here too (DIFFERENT route than the one in DB21)
INSERT INTO marsrutai_business VALUES
(4,'4 Ekspress',2,1),
(5,'5B Intercity Route',2,2);

-- Zones
INSERT INTO bilietu_zonos (pavadinimas,kaina,galiojimo_laikas_pradzia,galiojimo_laikas_pabaiga,zonos_ribos,bilieto_tipas_id) VALUES
('C',2.0,'2024-01-01','2024-12-31',ST_GeomFromText('POLYGON((25.40 54.70,25.41 54.70,25.41 54.71,25.40 54.71,25.40 54.70))',4326),3),
('D',2.5,'2024-01-01','2024-12-31',ST_GeomFromText('POLYGON((25.42 54.72,25.43 54.72,25.43 54.73,25.42 54.73,25.42 54.72))',4326),2);

-- Drivers
INSERT INTO vairuotojai (vardas,pavarde,gimimo_data,pazymejimo_nr,darbo_pradzios_data,atlyginimas) VALUES
('Aldona','Aldonienė','1979-02-02','VR200','2000-01-01',1800.00),
('Mindaugas','Mindaugaitis','1984-03-03','VR201','2008-03-05',1550.00),
('Virginija','Virgaitė','1993-06-06','VR202','2014-07-08',1450.00),
('Tomas','Tomaitis','1987-11-11','VR203','2011-04-04',1600.00),
('Dalia','Dalyte','1991-05-05','VR204','2017-01-01',1380.00);

-- Vehicles
INSERT INTO transporto_priemones (kodas,vietu_sk,pagaminimo_metai,registracijos_nr,paskutine_apziura_data,tipas_id,degalu_tipas_id) VALUES
('T006',25,2019,'AAA006','2023-05-05',3,3),
('T007',35,2016,'AAA007','2023-09-09',2,2),
('T008',60,2014,'AAA008','2022-11-11',1,1),
('T009',40,2018,'AAA009','2023-04-04',1,4),
('T010',50,2020,'AAA010','2024-01-01',2,2);

-- Trips (only for Tarpmiestinis routes 4-5)
INSERT INTO reisai (keleiviu_sk,priemone_id,vairuotojas_id,marsrutas_id) VALUES
(38,1,1,4),(40,2,2,5);

-- Stops business attrs
INSERT INTO adresas (miestas,salis,gatve,gatves_pradzia,gatves_pabaiga) VALUES
('Kaunas','LT','Laisvės al.','1','60'),
('Klaipėda','LT','Taikos pr.','1','30');

INSERT INTO stoteles_business (stotele_id,zona_id,adresas_id) VALUES
(6,1,1),(7,2,2);

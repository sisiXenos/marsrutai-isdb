-- DB21: Business Fragment
CREATE EXTENSION IF NOT EXISTS postgis;

-- Reference tables (business classifiers)
CREATE TABLE bilieto_tipas (
    bilieto_tipas_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

INSERT INTO bilieto_tipas (name) VALUES
('Su 50% nuolaida'),
('Pilnas'),
('Su 80% nuolaida');

CREATE TABLE degalu_tipas (
    degalu_tipas_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

INSERT INTO degalu_tipas (name) VALUES
('Benzinas'),
('Dyzelinas'),
('Elektra'),
('Hibridas');

CREATE TABLE priemones_tipas (
    priemones_tipas_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

INSERT INTO priemones_tipas (name) VALUES
('Autobusas'),
('Troleibusas'),
('Mikroautobusas');

CREATE TABLE adresas (
    adresas_id SERIAL PRIMARY KEY,
    miestas VARCHAR(100),
    salis VARCHAR(100),
    gatve VARCHAR(100),
    gatves_pradzia VARCHAR(100),
    gatves_pabaiga VARCHAR(100)
);

-- Fragmented marsrutai: business attributes
CREATE TABLE marsrutai_business (
    marsrutas_id INT PRIMARY KEY,
    pavadinimas VARCHAR(255),
    marsruto_tipas_id INT,
    aptarnavimas_id INT
);

-- Zones
CREATE TABLE bilietu_zonos (
    zona_id SERIAL PRIMARY KEY,
    pavadinimas VARCHAR(255),
    kaina NUMERIC(10,2),
    galiojimo_laikas_pradzia DATE,
    galiojimo_laikas_pabaiga DATE,
    zonos_ribos GEOMETRY(POLYGON, 4326),
    bilieto_tipas_id INT REFERENCES bilieto_tipas(bilieto_tipas_id)
);

-- Drivers
CREATE TABLE vairuotojai (
    vairuotojas_id SERIAL PRIMARY KEY,
    vardas VARCHAR(100),
    pavarde VARCHAR(100),
    gimimo_data DATE,
    pazymejimo_nr VARCHAR(50),
    darbo_pradzios_data DATE,
    atlyginimas NUMERIC(10,2)
);

-- Transport
CREATE TABLE transporto_priemones (
    priemone_id SERIAL PRIMARY KEY,
    kodas VARCHAR(50),
    vietu_sk INT,
    pagaminimo_metai INT,
    registracijos_nr VARCHAR(20),
    paskutine_apziura_data DATE,
    tipas_id INT REFERENCES priemones_tipas(priemones_tipas_id),
    degalu_tipas_id INT REFERENCES degalu_tipas(degalu_tipas_id)
);

CREATE TABLE reisai (
    reisas_id SERIAL PRIMARY KEY,
    keleiviu_sk INT,
    priemone_id INT NOT NULL REFERENCES transporto_priemones(priemone_id),
    vairuotojas_id INT NOT NULL REFERENCES vairuotojai(vairuotojas_id),
    marsrutas_id INT NOT NULL
);

CREATE TABLE stoteles_business (
    stotele_id INT PRIMARY KEY,
    zona_id INT NOT NULL REFERENCES bilietu_zonos(zona_id),
    adresas_id INT NOT NULL UNIQUE REFERENCES adresas(adresas_id)
);
-- DB21 DATA

INSERT INTO marsrutai_business VALUES
(1,'1G Oro uostas - Centras',1,1),
(2,'2G Centras - Stotis',1,2),
(3,'3G Klinikos - Parkas',1,1),
(4,'4 Ekspress',2,1),
(5,'5 Priemiestinis',2,2);

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

-- Trips
INSERT INTO reisai (keleiviu_sk,priemone_id,vairuotojas_id,marsrutas_id) VALUES
(30,1,1,1),(45,2,2,2),(22,3,3,3),(38,4,4,4),(40,5,5,5);

-- Stops business attrs
INSERT INTO adresas (miestas,salis,gatve,gatves_pradzia,gatves_pabaiga) VALUES
('Vilnius','LT','Geležinkelio g.','1','50'),
('Vilnius','LT','Ozo g.','1','40');

INSERT INTO stoteles_business (stotele_id,zona_id,adresas_id) VALUES
(1,1,1),(2,2,2);
-- DB22 DATA

INSERT INTO marsrutai_business VALUES
(6,'6 Universitetas - Klinikos',1,1),
(7,'7 Priemiestinis',2,1),
(8,'8 Ekspress',2,2),
(9,'9 Naktinis',1,1),
(10,'10 Eksperimentinis',2,2);

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

-- Trips
INSERT INTO reisai (keleiviu_sk,priemone_id,vairuotojas_id,marsrutas_id) VALUES
(25,1,1,6),(30,2,2,7),(50,3,3,8),(20,4,4,9),(28,5,5,10);

-- Stops business attrs
INSERT INTO adresas (miestas,salis,gatve,gatves_pradzia,gatves_pabaiga) VALUES
('Kaunas','LT','Laisvės al.','1','60'),
('Klaipėda','LT','Taikos pr.','1','30');

INSERT INTO stoteles_business (stotele_id,zona_id,adresas_id) VALUES
(6,1,1),(7,2,2);

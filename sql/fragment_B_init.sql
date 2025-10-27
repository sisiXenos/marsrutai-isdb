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
    marsruto_tipas_id INT, -- Nuoroda į marsruto_tipas (iš fragment1.sql)
    aptarnavimas_id INT    -- Nuoroda į aptarnavimas (iš fragment1.sql)
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

-- Routes schedule
CREATE TABLE marsruto_tvarkarastis (
    tvarkarastis_id SERIAL PRIMARY KEY,
    pradzia DATE,
    pabaiga DATE,
    marsrutas_id INT NOT NULL REFERENCES marsrutai_business(marsrutas_id),
    aptarnavimas_id INT NOT NULL -- Nuoroda į aptarnavimas (iš fragment1.sql)
);

-- Driver-transport assignment
CREATE TABLE vairuotojo_transporto_priskirtis (
    priskirtis_id SERIAL PRIMARY KEY,
    priskirtis_pradzia DATE,
    priskirtis_pabaiga DATE,
    vairuotojas_id INT NOT NULL REFERENCES vairuotojai(vairuotojas_id),
    priemone_id INT NOT NULL REFERENCES transporto_priemones(priemone_id)
);

-- DB21 DATA (5 Maršrutai - Verslo Duomenys)

-- Marsrutai (business fragment)
INSERT INTO marsrutai_business (marsrutas_id, pavadinimas, marsruto_tipas_id, aptarnavimas_id) VALUES
(1, 'Maršrutas 1 Kaunas', 1, 1),
(2, 'Maršrutas 2 Kaunas', 2, 1),
(3, 'Maršrutas 3 Kaunas', 1, 2),
(4, 'Maršrutas 4 Kaunas', 2, 2),
(5, 'Maršrutas 5 Kaunas', 1, 1);

-- Bilietų zonos (priklauso stotelėms)
INSERT INTO bilietu_zonos (pavadinimas, kaina, galiojimo_laikas_pradzia, galiojimo_laikas_pabaiga, zonos_ribos, bilieto_tipas_id) VALUES
('Centras', 1.50, '2025-01-01', '2025-12-31', ST_GeomFromText('POLYGON((23.88 54.88,23.88 54.94,23.95 54.94,23.95 54.88,23.88 54.88))',4326), 2),
('Senamiestis', 2.00, '2025-01-01', '2025-12-31', ST_GeomFromText('POLYGON((23.86 54.86,23.86 54.92,23.92 54.92,23.92 54.86,23.86 54.86))',4326), 2);

-- Vairuotojai
INSERT INTO vairuotojai (vardas, pavarde, gimimo_data, pazymejimo_nr, darbo_pradzios_data, atlyginimas) VALUES
('Jonas','Jonaitis','1980-05-01','V001','2010-01-01',1200.00),
('Petras','Petraitis','1985-07-10','V002','2012-02-01',1300.00),
('Antanas','Antanaitis','1990-03-15','V003','2015-05-01',1100.00),
('Rasa','Rasaite','1988-09-20','V004','2013-03-01',1250.00),
('Laura','Laurynaite','1992-12-05','V005','2016-07-01',1150.00);

-- Transporto priemonės
INSERT INTO transporto_priemones (kodas, vietu_sk, pagaminimo_metai, registracijos_nr, paskutine_apziura_data, tipas_id, degalu_tipas_id) VALUES
('T001',50,2015,'KA001','2025-01-01',1,1),
('T002',45,2016,'KA002','2025-02-01',2,2),
('T003',30,2018,'KA003','2025-03-01',1,3),
('T004',60,2014,'KA004','2025-04-01',1,4),
('T005',40,2017,'KA005','2025-05-01',2,1);

-- Marsruto tvarkaraščiai
INSERT INTO marsruto_tvarkarastis (pradzia, pabaiga, marsrutas_id, aptarnavimas_id) VALUES
('2025-10-01','2025-12-31',1,1),
('2025-10-01','2025-12-31',2,1),
('2025-10-01','2025-12-31',3,2),
('2025-10-01','2025-12-31',4,2),
('2025-10-01','2025-12-31',5,1);

-- Vairuotojo-transporto priskyrimai
INSERT INTO vairuotojo_transporto_priskirtis (priskirtis_pradzia, priskirtis_pabaiga, vairuotojas_id, priemone_id) VALUES
('2025-10-01','2025-12-31',1,1),
('2025-10-01','2025-12-31',2,2),
('2025-10-01','2025-12-31',3,3),
('2025-10-01','2025-12-31',4,4),
('2025-10-01','2025-12-31',5,5);

-- Adresai (stotelėms)
INSERT INTO adresas (miestas, salis, gatve, gatves_pradzia, gatves_pabaiga) VALUES
('Kaunas','Lithuania','Laisvės al.','1','20'),
('Kaunas','Lithuania','Karaliaus Mindaugo pr.','1','25'),
('Kaunas','Lithuania','Savanorių pr.','1','30'),
('Kaunas','Lithuania','Pramonės pr.','1','15'),
('Kaunas','Lithuania','Islandijos pl.','1','10');

-- Stoteles business (tiekiame zona ir adresą)
INSERT INTO stoteles_business (stotele_id, zona_id, adresas_id) VALUES
(1,1,1),
(2,1,2),
(3,2,3),
(4,2,4),
(5,1,5);

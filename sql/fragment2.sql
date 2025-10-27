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

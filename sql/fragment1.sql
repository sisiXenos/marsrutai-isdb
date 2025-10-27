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


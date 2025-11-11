-- ===========================
-- DB12: Marsrutai su 3 stotelėmis ant linijų
-- ===========================

-- 1️⃣ Marsrutai
INSERT INTO marsrutai_spatial VALUES
(6, ST_GeomFromText('LINESTRING(25.40 54.70,25.45 54.72)',4326), 13.0, 32, TRUE),
(7, ST_GeomFromText('LINESTRING(25.41 54.71,25.46 54.73)',4326), 16.0, 42, TRUE),
(8, ST_GeomFromText('LINESTRING(25.42 54.72,25.47 54.74)',4326), 11.0, 26, FALSE),
(9, ST_GeomFromText('LINESTRING(25.43 54.73,25.48 54.75)',4326), 22.0, 55, TRUE),
(10, ST_GeomFromText('LINESTRING(25.44 54.74,25.49 54.76)',4326), 19.0, 48, TRUE);

-- 2️⃣ Stotelės
INSERT INTO stoteles (pavadinimas, stoteles_erdvine_vieta, paviljono_tipas_id) VALUES
('Akropolis', ST_SetSRID(ST_MakePoint(0,0),4326), 1),
('Zoo Park', ST_SetSRID(ST_MakePoint(0,0),4326), 2),
('Technikos Muziejus', ST_SetSRID(ST_MakePoint(0,0),4326), 3),
('Jūra', ST_SetSRID(ST_MakePoint(0,0),4326), 1),
('Tiltas', ST_SetSRID(ST_MakePoint(0,0),4326), 2),
('Arena', ST_SetSRID(ST_MakePoint(0,0),4326), 1),
('Biblioteka', ST_SetSRID(ST_MakePoint(0,0),4326), 2),
('Stadionas', ST_SetSRID(ST_MakePoint(0,0),4326), 3),
('Poliklinika', ST_SetSRID(ST_MakePoint(0,0),4326), 1),
('Centras', ST_SetSRID(ST_MakePoint(0,0),4326), 2),
('Teatras', ST_SetSRID(ST_MakePoint(0,0),4326), 1),
('Oro uostas', ST_SetSRID(ST_MakePoint(0,0),4326), 2),
('Universitetas', ST_SetSRID(ST_MakePoint(0,0),4326), 3),
('Parkas', ST_SetSRID(ST_MakePoint(0,0),4326), 1),
('Klinikos', ST_SetSRID(ST_MakePoint(0,0),4326), 2);

-- 3️⃣ Marsruto stotelės (startas, vidurys, pabaiga)
INSERT INTO marsruto_stoteles (eiles_nr_marsrute, atstumas_nuo_pradzios, stotele_id, marsrutas_id) VALUES
-- Maršrutas 6
(1, 0, 1, 6),      -- Akropolis, startas
(2, 6.5, 2, 6),    -- Zoo Park, vidurys (~50%)
(3, 13.0, 3, 6),   -- Technikos Muziejus, galinė
-- Maršrutas 7
(1, 0, 4, 7),
(2, 8.0, 5, 7),
(3, 16.0, 6, 7),
-- Maršrutas 8
(1, 0, 7, 8),
(2, 5.5, 8, 8),
(3, 11.0, 9, 8),
-- Maršrutas 9
(1, 0, 10, 9),
(2, 11.0, 11, 9),
(3, 22.0, 12, 9),
-- Maršrutas 10
(1, 0, 13, 10),
(2, 9.5, 14, 10),
(3, 19.0, 15, 10);

-- 4️⃣ Atnaujiname stotelių koordinates, kad būtų ant linijų
UPDATE stoteles s
SET stoteles_erdvine_vieta = ST_LineInterpolatePoint(
    (SELECT kelias FROM marsrutai_spatial WHERE marsrutas_id = ms.marsrutas_id),
    ms.atstumas_nuo_pradzios / (SELECT atstumas_km FROM marsrutai_spatial WHERE marsrutas_id = ms.marsrutas_id)
)
FROM marsruto_stoteles ms
WHERE s.stotele_id = ms.stotele_id;

-- 5️⃣ Reisu laikai (pavyzdys)
INSERT INTO reisu_laikai (nuvaziuotas_atstumas,faktinis_atvykimo_laikas,faktinis_isvykimo_laikas,
planuojamas_atvykimo_laikas,planuojamas_isvykimo_laikas,marsruto_stotele_id) VALUES
-- Maršrutas 6
(0,'2024-06-02 08:00','2024-06-02 08:03','2024-06-02 08:00','2024-06-02 08:03',1),
(6.5,'2024-06-02 08:20','2024-06-02 08:21','2024-06-02 08:18','2024-06-02 08:19',2),
(13.0,'2024-06-02 08:40','2024-06-02 08:42','2024-06-02 08:38','2024-06-02 08:40',3),
-- Maršrutas 7
(0,'2024-06-02 09:00','2024-06-02 09:02','2024-06-02 09:00','2024-06-02 09:02',4),
(8.0,'2024-06-02 09:30','2024-06-02 09:32','2024-06-02 09:28','2024-06-02 09:30',5),
(16.0,'2024-06-02 10:00','2024-06-02 10:02','2024-06-02 09:58','2024-06-02 10:00',6),
-- Maršrutas 8
(0,'2024-06-02 10:00','2024-06-02 10:03','2024-06-02 10:00','2024-06-02 10:03',7),
(5.5,'2024-06-02 10:25','2024-06-02 10:27','2024-06-02 10:22','2024-06-02 10:25',8),
(11.0,'2024-06-02 10:50','2024-06-02 10:53','2024-06-02 10:48','2024-06-02 10:50',9),
-- Maršrutas 9
(0,'2024-06-02 11:00','2024-06-02 11:03','2024-06-02 11:00','2024-06-02 11:03',10),
(11.0,'2024-06-02 11:45','2024-06-02 11:47','2024-06-02 11:40','2024-06-02 11:43',11),
(22.0,'2024-06-02 12:30','2024-06-02 12:32','2024-06-02 12:25','2024-06-02 12:28',12),
-- Maršrutas 10
(0,'2024-06-02 12:00','2024-06-02 12:03','2024-06-02 12:00','2024-06-02 12:03',13),
(9.5,'2024-06-02 12:40','2024-06-02 12:42','2024-06-02 12:35','2024-06-02 12:37',14),
(19.0,'2024-06-02 13:20','2024-06-02 13:23','2024-06-02 13:15','2024-06-02 13:18',15);

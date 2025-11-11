-- ===========================
-- DB11: Marsrutai su 3 stotelėmis ant linijų
-- ===========================

-- 1️⃣ Marsrutai
INSERT INTO marsrutai_spatial VALUES
(1, ST_GeomFromText('LINESTRING(25.30 54.70,25.35 54.72)',4326), 12.1, 30, TRUE),
(2, ST_GeomFromText('LINESTRING(25.31 54.71,25.36 54.73)',4326), 15.2, 40, TRUE),
(3, ST_GeomFromText('LINESTRING(25.32 54.72,25.37 54.74)',4326), 10.0, 25, TRUE),
(4, ST_GeomFromText('LINESTRING(25.33 54.73,25.38 54.75)',4326), 20.5, 50, FALSE),
(5, ST_GeomFromText('LINESTRING(25.34 54.74,25.39 54.76)',4326), 18.0, 45, TRUE);

-- 2️⃣ Stotelės (pradžiai tik dummy koordinatės, atnaujinsime ant linijos)
INSERT INTO stoteles (pavadinimas, stoteles_erdvine_vieta, paviljono_tipas_id) VALUES
('Stotis', ST_SetSRID(ST_MakePoint(0,0),4326), 1),
('Centras', ST_SetSRID(ST_MakePoint(0,0),4326), 2),
('Universitetas', ST_SetSRID(ST_MakePoint(0,0),4326), 3),
('Klinikos', ST_SetSRID(ST_MakePoint(0,0),4326), 1),
('Parkas', ST_SetSRID(ST_MakePoint(0,0),4326), 2),
('Stadionas', ST_SetSRID(ST_MakePoint(0,0),4326), 3),
('Teatras', ST_SetSRID(ST_MakePoint(0,0),4326), 1),
('Poliklinika', ST_SetSRID(ST_MakePoint(0,0),4326), 2),
('Biblioteka', ST_SetSRID(ST_MakePoint(0,0),4326), 3),
('Oro uostas', ST_SetSRID(ST_MakePoint(0,0),4326), 1),
('Arena', ST_SetSRID(ST_MakePoint(0,0),4326), 2),
('Jūros parkas', ST_SetSRID(ST_MakePoint(0,0),4326), 3),
('Akropolis', ST_SetSRID(ST_MakePoint(0,0),4326), 1),
('Zoo Park', ST_SetSRID(ST_MakePoint(0,0),4326), 2),
('Technikos Muziejus', ST_SetSRID(ST_MakePoint(0,0),4326), 3);

-- 3️⃣ Marsruto stotelės (startas, vidurys, pabaiga)
INSERT INTO marsruto_stoteles (eiles_nr_marsrute, atstumas_nuo_pradzios, stotele_id, marsrutas_id) VALUES
-- Maršrutas 1
(1,0,1,1),
(2,6.05,2,1),   -- vidurys 12.1 / 2
(3,12.1,3,1),
-- Maršrutas 2
(1,0,4,2),
(2,7.6,5,2),    -- 15.2 / 2
(3,15.2,6,2),
-- Maršrutas 3
(1,0,7,3),
(2,5.0,8,3),    -- 10 / 2
(3,10.0,9,3),
-- Maršrutas 4
(1,0,10,4),
(2,10.25,11,4), -- 20.5 / 2
(3,20.5,12,4),
-- Maršrutas 5
(1,0,13,5),
(2,9.0,14,5),   -- 18 / 2
(3,18.0,15,5);

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
-- Maršrutas 1
(0,'2024-06-01 08:00','2024-06-01 08:05','2024-06-01 08:00','2024-06-01 08:05',1),
(6.05,'2024-06-01 08:20','2024-06-01 08:21','2024-06-01 08:18','2024-06-01 08:19',2),
(12.1,'2024-06-01 08:40','2024-06-01 08:42','2024-06-01 08:38','2024-06-01 08:40',3),
-- Maršrutas 2
(0,'2024-06-01 09:00','2024-06-01 09:02','2024-06-01 09:00','2024-06-01 09:02',4),
(7.6,'2024-06-01 09:30','2024-06-01 09:32','2024-06-01 09:28','2024-06-01 09:30',5),
(15.2,'2024-06-01 10:00','2024-06-01 10:02','2024-06-01 09:58','2024-06-01 10:00',6),
-- Maršrutas 3
(0,'2024-06-01 10:00','2024-06-01 10:03','2024-06-01 10:00','2024-06-01 10:03',7),
(5.0,'2024-06-01 10:25','2024-06-01 10:27','2024-06-01 10:22','2024-06-01 10:25',8),
(10.0,'2024-06-01 10:50','2024-06-01 10:53','2024-06-01 10:48','2024-06-01 10:50',9),
-- Maršrutas 4
(0,'2024-06-01 11:00','2024-06-01 11:03','2024-06-01 11:00','2024-06-01 11:03',10),
(10.25,'2024-06-01 11:45','2024-06-01 11:47','2024-06-01 11:40','2024-06-01 11:43',11),
(20.5,'2024-06-01 12:30','2024-06-01 12:32','2024-06-01 12:25','2024-06-01 12:28',12),
-- Maršrutas 5
(0,'2024-06-01 12:00','2024-06-01 12:03','2024-06-01 12:00','2024-06-01 12:03',13),
(9.0,'2024-06-01 12:40','2024-06-01 12:42','2024-06-01 12:35','2024-06-01 12:37',14),
(18.0,'2024-06-01 13:20','2024-06-01 13:23','2024-06-01 13:15','2024-06-01 13:18',15);

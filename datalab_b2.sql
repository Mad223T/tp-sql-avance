DROP TABLE IF EXISTS lignes_commande, commandes, produits, categories, entrepots,
                     clients, employes, comptes_bancaires CASCADE;

CREATE OR REPLACE FUNCTION year(d DATE) RETURNS INT
    LANGUAGE sql IMMUTABLE AS $$ SELECT EXTRACT(YEAR FROM d)::INT $$;

CREATE TABLE categories (id INT PRIMARY KEY, nom VARCHAR(100) NOT NULL, marge_cible NUMERIC(4,2));
INSERT INTO categories VALUES
(1,'Serveurs & Stockage',0.24),(2,'Réseau & Sécurité',0.30),(3,'Postes de travail',0.18),
(4,'Périphériques Pro',0.35),(5,'Licences & Cloud',0.55),(6,'Accessoires Datacenter',0.42);

CREATE TABLE entrepots (id INT PRIMARY KEY, nom VARCHAR(100) NOT NULL, ville VARCHAR(100), capacite_m3 INT);
INSERT INTO entrepots VALUES
(1,'Lyon-Est','Lyon',4500),(2,'Paris-Nord','Roissy',8200),(3,'Nantes-Ouest','Nantes',3100),(4,'Toulouse-Sud','Toulouse',2900);

CREATE TABLE produits (id INT PRIMARY KEY, nom VARCHAR(150) NOT NULL, categorie_id INT REFERENCES categories(id),
    prix_unitaire NUMERIC(10,2), stock INT, entrepot_id INT REFERENCES entrepots(id));
INSERT INTO produits VALUES
(1,'Rack Serveur Xeon E24',1,2450,18,2),(2,'Baie NAS 12To Redondante',1,1390,26,1),
(3,'SSD NVMe Datacenter 4To',1,580,94,2),(4,'Onduleur Rack 3000VA',1,890,31,3),
(5,'Switch L3 48 Ports PoE+',2,1120,22,2),(6,'Pare-feu UTM Enterprise',2,1650,14,1),
(7,'Point d''accès Wi-Fi 7 Pro',2,340,65,4),(8,'Module SFP+ 10Gb Fibre',2,95,210,2),
(9,'Station Dev Ultra 64Go',3,2180,19,1),(10,'Ultrabook B2 Pro 14',3,1420,47,2),
(11,'Mini-PC Cluster ARM',3,490,58,3),(12,'Workstation GPU Dual',3,3890,8,2),
(13,'Écran 32" 4K Calibré',4,670,41,1),(14,'Station d''accueil Thunderbolt',4,245,84,3),
(15,'Clavier Mécanique Silencieux',4,135,112,4),(16,'Webcam Conférence 4K',4,195,53,1),
(17,'Licence SGBD Cluster 1 An',5,1800,999,2),(18,'Suite Sauvegarde Chiffrée',5,420,999,2),
(19,'Pack Monitoring APM',5,750,999,2),(20,'Certificat TLS Wildcard',5,290,999,2),
(21,'Câble Jarretière OM4 5m',6,28,380,1),(22,'Rail Coulissant Rack 2U',6,85,75,3),
(23,'PDU Connecté 16A',6,310,34,4),(24,'Sonde Température SNMP',6,145,62,1);

CREATE TABLE clients (id INT PRIMARY KEY, nom VARCHAR(100) NOT NULL, email VARCHAR(150),
    ville VARCHAR(100), segment VARCHAR(30), date_inscription DATE);
INSERT INTO clients VALUES
(1,'Camille Laurent','camille.laurent@hexatech.fr','Lyon','Entreprise','2024-01-14'),
(2,'Lucas Moreau','lucas.moreau@novalab.fr','Paris','Grand Compte','2024-02-03'),
(3,'Inès Bernard','ines.bernard@atelier-num.fr','Nantes','PME','2024-02-19'),
(4,'Théo Petit','theo.petit@cloudops.fr','Toulouse','Entreprise','2024-03-11'),
(5,'Manon Roux','manon.roux@dataviz.fr','Lyon','PME','2024-04-02'),
(6,'Hugo Fournier','hugo.fournier@syscore.fr','Paris','Grand Compte','2024-04-27'),
(7,'Chloé Girard','chloe.girard@finops.fr','Bordeaux','Entreprise','2024-05-15'),
(8,'Nathan Bonnet','nathan.bonnet@kapsul.fr','Lille','Startup','2024-06-08'),
(9,'Léa Dupuis','lea.dupuis@meddata.fr','Lyon','Grand Compte','2024-06-22'),
(10,'Enzo Lefèvre','enzo.lefevre@vecteur.fr','Paris','PME','2024-07-09'),
(11,'Sarah Mercier','sarah.mercier@arcadia.fr','Nantes','Entreprise','2024-08-18'),
(12,'Tom Blanc','tom.blanc@aero-si.fr','Toulouse','Grand Compte','2024-09-05'),
(13,'Jade Guérin','jade.guerin@pixelio.fr','Bordeaux','Startup','2024-10-12'),
(14,'Louis Chevalier','louis.chevalier@opale.fr','Lyon','PME','2024-11-01'),
(15,'Emma François','emma.francois@cybershield.fr','Paris','Entreprise','2025-01-10'),
(16,'Gabriel Leroy','gabriel.leroy@logitech-si.fr','Lille','PME','2025-02-14'),
(17,'Zoé Garnier','zoe.garnier@biocloud.fr','Lyon','Grand Compte','2025-03-04'),
(18,'Arthur Faure','arthur.faure@gridcompute.fr','Nantes','Startup','2025-04-19'),
(19,'Lina Andre','lina.andre@indus-it.fr','Toulouse','Entreprise','2025-05-23'),
(20,'Raphaël Perrin','raphael.perrin@quantis.fr','Paris','Grand Compte','2025-06-30'),
(21,'Clara Clement','clara.clement@bzh-data.fr','Rennes','PME','2025-08-12'),
(22,'Jules Morin','jules.morin@nordic-it.fr','Lille','Startup','2025-09-20'),
(23,'Alice Gauthier','alice.gauthier@alpes-tech.fr','Grenoble','Entreprise','2025-11-04'),
(24,'Adam Barbier','adam.barbier@rhone-cloud.fr','Lyon','PME','2026-01-08');

CREATE TABLE commandes (id INT PRIMARY KEY, client_id INT NOT NULL REFERENCES clients(id),
    date_commande DATE NOT NULL, statut VARCHAR(20), canal VARCHAR(20), montant_total NUMERIC(10,2));

CREATE TABLE lignes_commande (id INT PRIMARY KEY, commande_id INT NOT NULL REFERENCES commandes(id),
    produit_id INT NOT NULL REFERENCES produits(id), quantite INT NOT NULL, prix_unitaire_applique NUMERIC(10,2) NOT NULL);

SELECT setseed(0.42);
INSERT INTO commandes (id, client_id, date_commande, statut, canal, montant_total)
SELECT g, 1 + floor(random() * 24)::INT,
       DATE '2024-01-01' + ((g - 1) / 80) * INTERVAL '1 year' + floor(random() * 320)::INT * INTERVAL '1 day',
       (ARRAY['LIVREE','LIVREE','LIVREE','EXPEDIEE','EN_ATTENTE','ANNULEE'])[1 + floor(random() * 6)::INT],
       (ARRAY['WEB','WEB','TELEPHONE','COMMERCIAL'])[1 + floor(random() * 4)::INT], 0
FROM generate_series(1, 240) g;

INSERT INTO lignes_commande (id, commande_id, produit_id, quantite, prix_unitaire_applique)
SELECT row_number() OVER (), c.id, p.id, q.quantite, p.prix_unitaire
FROM commandes c
CROSS JOIN LATERAL generate_series(1, 1 + (c.id % 3)) n
CROSS JOIN LATERAL (SELECT 1 + floor(random() * 24)::INT + n * 0 AS pid) r
JOIN produits p ON p.id = r.pid
CROSS JOIN LATERAL (SELECT 1 + floor(random() * 4)::INT + n * 0 AS quantite) q;

UPDATE commandes c SET montant_total = s.total
FROM (SELECT commande_id, SUM(quantite * prix_unitaire_applique) AS total FROM lignes_commande GROUP BY commande_id) s
WHERE s.commande_id = c.id;

CREATE TABLE employes (id INT PRIMARY KEY, nom VARCHAR(100) NOT NULL, poste VARCHAR(100),
    manager_id INT REFERENCES employes(id), departement VARCHAR(50), salaire INT);
INSERT INTO employes VALUES
(1,'Claire Moreau','Directrice Technique (CTO)',NULL,'Direction',92000),
(2,'Marc Delacroix','VP Architecture Data',1,'Data',76000),
(3,'Sophie Vasseur','VP Infrastructure',1,'Infra',74000),
(4,'Antoine Renaud','Lead DBA PostgreSQL',2,'Data',62000),
(5,'Nadia Benali','Lead Data Engineer',2,'Data',64000),
(6,'Julien Caron','Architecte NoSQL',2,'Data',61000),
(7,'Pauline Lefort','Ingénieure SRE',3,'Infra',56000),
(8,'Romain Fabre','Administrateur Réseau',3,'Infra',51000),
(9,'Émilie Maillard','DBA Junior',4,'Data',42000),
(10,'Bastien Royer','Analyste SQL BI',4,'Data',44000),
(11,'Kévin Giraud','Développeur ETL',5,'Data',45000),
(12,'Océane Simon','Technicienne Datacenter',7,'Infra',38000);

CREATE TABLE comptes_bancaires (id INT PRIMARY KEY, titulaire VARCHAR(100) NOT NULL,
    solde NUMERIC(12,2) NOT NULL, statut VARCHAR(20));
INSERT INTO comptes_bancaires VALUES
(1,'HexaTech SAS',15000,'ACTIF'),(2,'NovaLab SARL',8400,'ACTIF'),
(3,'Atelier Numérique',3200,'ACTIF'),(4,'CloudOps France',22500,'ACTIF');

ANALYZE;

SELECT 'commandes' AS table_, COUNT(*) FROM commandes
UNION ALL SELECT 'lignes_commande', COUNT(*) FROM lignes_commande
UNION ALL SELECT 'clients', COUNT(*) FROM clients
UNION ALL SELECT 'produits', COUNT(*) FROM produits
UNION ALL SELECT 'employes', COUNT(*) FROM employes;
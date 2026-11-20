-- =====================================================================
-- Q2 (2,5 pts) - Index + partitionnement RANGE + requête SARGable
-- =====================================================================

-- 1) L'index filtre par statut et plage de dates ; le tri sur le montant reste nécessaire.
CREATE INDEX IF NOT EXISTS idx_commandes_statut_date
    ON commandes (statut, date_commande);

-- 2) Partitionnement annuel ; la partition par défaut conserve les autres dates.
DROP TABLE IF EXISTS commandes_part CASCADE;

CREATE TABLE commandes_part (
    id            INT           NOT NULL,
    client_id     INT           NOT NULL REFERENCES clients(id),
    date_commande DATE          NOT NULL,
    statut        VARCHAR(20),
    canal         VARCHAR(20),
    montant_total NUMERIC(10,2),
    -- PostgreSQL impose d'inclure la clé de partition dans la clé primaire.
    PRIMARY KEY (id, date_commande)
) PARTITION BY RANGE (date_commande);

CREATE TABLE commandes_2024 PARTITION OF commandes_part
    FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');
CREATE TABLE commandes_2025 PARTITION OF commandes_part
    FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');
CREATE TABLE commandes_2026 PARTITION OF commandes_part
    FOR VALUES FROM ('2026-01-01') TO ('2027-01-01');
CREATE TABLE commandes_autres PARTITION OF commandes_part DEFAULT;

INSERT INTO commandes_part (id, client_id, date_commande, statut, canal, montant_total)
SELECT id, client_id, date_commande, statut, canal, montant_total
FROM commandes;

CREATE INDEX idx_cmd_part_statut_date
    ON commandes_part (statut, date_commande);

ANALYZE commandes;
ANALYZE commandes_part;

-- 3) Les bornes permettent le pruning des partitions et un accès indexable.
-- Le faible volume de données peut toutefois faire préférer un scan séquentiel.
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, client_id, date_commande, montant_total
FROM commandes_part
WHERE statut = 'LIVREE'
  AND date_commande >= DATE '2026-01-01'
  AND date_commande <  DATE '2027-01-01'
ORDER BY montant_total DESC, id
LIMIT 10;

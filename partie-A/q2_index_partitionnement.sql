-- =====================================================================
-- Q2 (2,5 pts) - Index + partitionnement RANGE + requête SARGable
-- =====================================================================

-- 1) Index composite sur commandes (règle du préfixe gauche) :
--    égalité (statut) -> intervalle (date_commande) -> tri (montant_total)
CREATE INDEX IF NOT EXISTS idx_commandes_statut_date_montant
    ON commandes (statut, date_commande, montant_total DESC);

-- 2) Partitionnement RANGE par année
DROP TABLE IF EXISTS commandes_part CASCADE;

CREATE TABLE commandes_part (
    id            INT           NOT NULL,
    client_id     INT           NOT NULL,
    date_commande DATE          NOT NULL,
    statut        VARCHAR(20),
    canal         VARCHAR(20),
    montant_total NUMERIC(10,2),
    PRIMARY KEY (id, date_commande)   -- la clé de partition doit être dans la PK
) PARTITION BY RANGE (date_commande);

CREATE TABLE commandes_2024 PARTITION OF commandes_part
    FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');
CREATE TABLE commandes_2025 PARTITION OF commandes_part
    FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');
CREATE TABLE commandes_2026 PARTITION OF commandes_part
    FOR VALUES FROM ('2026-01-01') TO ('2027-01-01');

INSERT INTO commandes_part (id, client_id, date_commande, statut, canal, montant_total)
SELECT id, client_id, date_commande, statut, canal, montant_total
FROM commandes;

CREATE INDEX idx_cmd_part_statut_date_montant
    ON commandes_part (statut, date_commande, montant_total DESC);

ANALYZE commandes;
ANALYZE commandes_part;

-- 3) Requête réécrite : SARGable (bornes de dates) et sans SELECT *
EXPLAIN ANALYZE
SELECT id, client_id, date_commande, montant_total
FROM commandes_part
WHERE statut = 'LIVREE'
  AND date_commande >= DATE '2026-01-01'
  AND date_commande <  DATE '2027-01-01'
ORDER BY montant_total DESC
LIMIT 10;

-- =====================================================================
-- Q3 (2,5 pts) - Vue matérialisée mv_synthese_segments
-- =====================================================================

-- 1) Inclut aussi les segments sans commande ; leur CA est alors nul.
DROP MATERIALIZED VIEW IF EXISTS mv_synthese_segments;

CREATE MATERIALIZED VIEW mv_synthese_segments AS
SELECT cl.segment,
       COUNT(co.id) AS nb_commandes,
       COALESCE(ROUND(SUM(co.montant_total), 2), 0) AS ca_total
FROM clients cl
LEFT JOIN commandes co ON co.client_id = cl.id
GROUP BY cl.segment;

SELECT segment, nb_commandes, ca_total
FROM mv_synthese_segments
ORDER BY ca_total DESC, segment;

-- 2) La transaction permet de tester le rafraîchissement sans conserver la commande.
BEGIN;

INSERT INTO commandes (id, client_id, date_commande, statut, canal, montant_total)
SELECT COALESCE(MAX(id), 0) + 1, 1, CURRENT_DATE, 'LIVREE', 'WEB', 5000.00
FROM commandes;

-- Avant le rafraîchissement, la vue contient encore les anciennes valeurs.
SELECT segment, nb_commandes, ca_total
FROM mv_synthese_segments
WHERE segment = 'Entreprise';

REFRESH MATERIALIZED VIEW mv_synthese_segments;

-- Après le rafraîchissement, la nouvelle commande est comptabilisée.
SELECT segment, nb_commandes, ca_total
FROM mv_synthese_segments
WHERE segment = 'Entreprise';

ROLLBACK;
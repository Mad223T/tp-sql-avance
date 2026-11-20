-- =====================================================================
-- Q3 (2,5 pts) - Vue matérialisée mv_synthese_segments
-- =====================================================================

-- 1) Création : nombre de commandes et CA total par segment client
DROP MATERIALIZED VIEW IF EXISTS mv_synthese_segments;

CREATE MATERIALIZED VIEW mv_synthese_segments AS
SELECT cl.segment,
       COUNT(co.id)                    AS nb_commandes,
       ROUND(SUM(co.montant_total), 2) AS ca_total
FROM clients cl
JOIN commandes co ON co.client_id = cl.id
GROUP BY cl.segment;

SELECT * FROM mv_synthese_segments ORDER BY ca_total DESC;
-- Résultat :
--   PME          | 76 | 335 949,00
--   Entreprise   | 67 | 297 872,00
--   Grand Compte | 58 | 275 282,00
--   Startup      | 39 | 167 141,00

-- 2) Commande test (client 1 = Camille Laurent, segment Entreprise)
INSERT INTO commandes (id, client_id, date_commande, statut, canal, montant_total)
VALUES (9999, 1, CURRENT_DATE, 'LIVREE', 'WEB', 5000.00);

-- 3) La vue n'a pas bougé : elle est obsolète (stale)
SELECT * FROM mv_synthese_segments WHERE segment = 'Entreprise';
-- Résultat : Entreprise | 67 | 297 872,00  -> identique, la commande test n'apparaît pas

-- 4) Rafraîchissement
REFRESH MATERIALIZED VIEW mv_synthese_segments;

-- 5) Vérification
SELECT * FROM mv_synthese_segments WHERE segment = 'Entreprise';
-- Résultat : Entreprise | 68 | 302 872,00  -> +1 commande et +5000 €

-- Nettoyage de la commande test
DELETE FROM commandes WHERE id = 9999;
REFRESH MATERIALIZED VIEW mv_synthese_segments;

-- =====================================================================
-- Q1 (2 pts) - EXPLAIN ANALYZE : 10 plus grosses commandes LIVREE de 2026
-- =====================================================================

EXPLAIN ANALYZE
SELECT *
FROM commandes
WHERE YEAR(date_commande) = 2026
  AND statut = 'LIVREE'
ORDER BY montant_total DESC
LIMIT 10;


-- =======================================================================
-- Q1 (2 pts) - EXPLAIN ANALYZE : 10 plus grosses commandes LIVREE de 2026
-- =======================================================================

-- Des bornes sur la date permettent l'utilisation d'un index sur date_commande.
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, client_id, date_commande, statut, montant_total
FROM commandes
WHERE date_commande >= DATE '2026-01-01'
  AND date_commande <  DATE '2027-01-01'
  AND statut = 'LIVREE'
ORDER BY montant_total DESC, id
LIMIT 10;
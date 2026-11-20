-- =====================================================================
-- Q7 (2 pts) - Le piège du NOT IN avec des valeurs NULL
-- =====================================================================

-- Requête piégée : censée lister les employés qui ne managent personne
SELECT id, nom
FROM employes
WHERE id NOT IN (SELECT manager_id FROM employes);

-- Correction fiable : NOT EXISTS (insensible aux NULL)
SELECT e.id, e.nom
FROM employes e
WHERE NOT EXISTS (
    SELECT 1
    FROM employes s
    WHERE s.manager_id = e.id
)
ORDER BY e.id;
-- Résultat : 6 employés (Julien Caron, Romain Fabre, Émilie Maillard,
--            Bastien Royer, Kévin Giraud, Océane Simon)

-- Alternative équivalente : LEFT JOIN ... IS NULL
SELECT e.id, e.nom
FROM employes e
LEFT JOIN employes s ON s.manager_id = e.id
WHERE s.id IS NULL
ORDER BY e.id;

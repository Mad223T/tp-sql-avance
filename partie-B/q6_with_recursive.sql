-- =====================================================================
-- Q6 (2 pts) - WITH RECURSIVE : organigramme complet depuis la CTO
-- =====================================================================

WITH RECURSIVE organigramme AS (
    -- Ancre : la CTO (aucun manager)
    SELECT id, nom, poste, manager_id,
           1         AS niveau,
           nom::TEXT AS chemin
    FROM employes
    WHERE manager_id IS NULL

    UNION ALL

    -- Partie récursive : les subordonnés des employés déjà trouvés
    SELECT e.id, e.nom, e.poste, e.manager_id,
           o.niveau + 1,
           o.chemin || ' > ' || e.nom
    FROM employes e
    JOIN organigramme o ON e.manager_id = o.id
    WHERE o.niveau < 20               -- sécurité contre une boucle infinie
)
SELECT id, nom, poste, niveau, chemin
FROM organigramme
ORDER BY chemin;

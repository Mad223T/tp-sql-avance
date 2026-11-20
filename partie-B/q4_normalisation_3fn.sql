-- =====================================================================
-- Q4 (2 pts) - Passage en 3FN de affectations_brutes
-- =====================================================================
-- Table brute :
--   affectations_brutes(employe_id, employe_nom, dept_nom, projets_liste,
--                       chef_projet, chef_projet_tel)
--
-- DÉPENDANCES FONCTIONNELLES
--   employe_id  -> employe_nom, dept_nom
--   projet      -> chef_projet
--   chef_projet -> chef_projet_tel
--
-- 1FN : projets_liste contient plusieurs valeurs dans une case
--       -> une ligne par (employé, projet). Clé : (employe_id, projet).
-- 2FN : employe_nom et dept_nom dépendent seulement de employe_id (partie de la clé)
--       -> table employes_aff. chef_projet dépend seulement de projet -> table projets.
-- 3FN : chef_projet_tel dépend de chef_projet, qui dépend de projet
--       (dépendance transitive) -> table chefs_projet.
--       dept_nom est sorti dans une table departements (pas de redondance du nom).
--
-- Note : la table s'appelle employes_aff pour ne pas écraser la table employes du schéma.

DROP TABLE IF EXISTS affectations, projets, chefs_projet, employes_aff, departements CASCADE;

CREATE TABLE departements (
    id  SERIAL       PRIMARY KEY,
    nom VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE employes_aff (
    id             INT          PRIMARY KEY,               -- ancien employe_id
    nom            VARCHAR(100) NOT NULL,
    departement_id INT          NOT NULL REFERENCES departements(id)
);

CREATE TABLE chefs_projet (
    id        SERIAL       PRIMARY KEY,
    nom       VARCHAR(100) NOT NULL,
    telephone VARCHAR(20)
);

CREATE TABLE projets (
    id             SERIAL       PRIMARY KEY,
    nom            VARCHAR(100) NOT NULL UNIQUE,
    chef_projet_id INT          NOT NULL REFERENCES chefs_projet(id)
);

-- Table d'association N-N entre employés et projets
CREATE TABLE affectations (
    employe_id INT NOT NULL REFERENCES employes_aff(id),
    projet_id  INT NOT NULL REFERENCES projets(id),
    PRIMARY KEY (employe_id, projet_id)
);

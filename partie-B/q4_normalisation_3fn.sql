-- =====================================================================
-- Q4 (2 pts) - Passage en 3FN de affectations_brutes
-- =====================================================================

DROP TABLE IF EXISTS affectations, projets, chefs_projet, employes_aff, departements CASCADE;

CREATE TABLE departements (
    id  SERIAL       PRIMARY KEY,
    nom VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE employes_aff (
    id             INT          PRIMARY KEY,
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

-- Table d'association N-N employés <-> projets
CREATE TABLE affectations (
    employe_id INT NOT NULL REFERENCES employes_aff(id),
    projet_id  INT NOT NULL REFERENCES projets(id),
    PRIMARY KEY (employe_id, projet_id)
);

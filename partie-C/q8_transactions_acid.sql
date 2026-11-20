-- =====================================================================
-- Q8 (2 pts) - Non-Repeatable Read, REPEATABLE READ et rôle du WAL
-- =====================================================================
-- À exécuter dans le simulateur ACID avec DEUX sessions (A et B),
-- en suivant l'ordre des étapes.

-- ---------------------------------------------------------------------
-- PARTIE 1 : Non-Repeatable Read sous READ COMMITTED
-- ---------------------------------------------------------------------

-- [Session A] Étape 1
BEGIN ISOLATION LEVEL READ COMMITTED;
SELECT solde FROM comptes_bancaires WHERE id = 1;     -- 15000.00

-- [Session B] Étape 2 : modifie et valide pendant que A est ouverte
BEGIN;
UPDATE comptes_bancaires SET solde = solde - 1000 WHERE id = 1;
COMMIT;

-- [Session A] Étape 3 : même lecture, dans la même transaction
SELECT solde FROM comptes_bancaires WHERE id = 1;     -- 14000.00  <- résultat différent !
COMMIT;



-- Remise à l'état initial avant la partie 2
UPDATE comptes_bancaires SET solde = 15000.00 WHERE id = 1;

-- ---------------------------------------------------------------------
-- PARTIE 2 : REPEATABLE READ résout le problème
-- ---------------------------------------------------------------------

-- [Session A] Étape 1
BEGIN ISOLATION LEVEL REPEATABLE READ;
SELECT solde FROM comptes_bancaires WHERE id = 1;     -- 15000.00

-- [Session B] Étape 2
BEGIN;
UPDATE comptes_bancaires SET solde = solde - 1000 WHERE id = 1;
COMMIT;

-- [Session A] Étape 3
SELECT solde FROM comptes_bancaires WHERE id = 1;     -- 15000.00  <- même valeur
COMMIT;

-- [Session A] Nouvelle transaction : la modification de B est maintenant visible
SELECT solde FROM comptes_bancaires WHERE id = 1;     -- 14000.00

-- Explication : en REPEATABLE READ, le snapshot est figé au début de la
-- transaction (MVCC). A lit toujours la même version de la ligne jusqu'à
-- son COMMIT, même si B a validé entre-temps.

-- Remise à l'état initial
UPDATE comptes_bancaires SET solde = 15000.00 WHERE id = 1;

-- ---------------------------------------------------------------------
-- PARTIE 3 : rôle du WAL lors d'une coupure serveur en plein virement
-- ---------------------------------------------------------------------
-- Virement de 1000 € de HexaTech (id 1) vers NovaLab (id 2) :
BEGIN;
UPDATE comptes_bancaires SET solde = solde - 1000 WHERE id = 1;   -- débit
-- >>> COUPURE DE COURANT ICI (avant le crédit et avant le COMMIT) <<<
-- UPDATE comptes_bancaires SET solde = solde + 1000 WHERE id = 2;  -- crédit jamais exécuté
-- COMMIT;                                                           -- jamais atteint
ROLLBACK;   -- simule ce que fait PostgreSQL au redémarrage pour une transaction non validée

SELECT id, titulaire, solde FROM comptes_bancaires WHERE id IN (1, 2);

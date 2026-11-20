# Réponses – TP SQL Avancé

Mamadou Collin TOURE

## Partie A

**Q1.** Plan : Seq Scan sur `commandes`, puis Sort, puis Limit (coût 8,82 ; 240 lignes lues, 203 rejetées).
- Défaut 1 : `YEAR(date_commande)` n'est pas SARGable. La fonction appliquée sur la colonne empêche l'utilisation d'un index, donc toute la table est lue.
- Défaut 2 : `SELECT *` ramène des colonnes inutiles. Ça empêche un Index Only Scan et alourdit le tri.

**Q2.** Index `(statut, date_commande, montant_total DESC)`, partitionnement RANGE par année, filtre `date_commande >= '2026-01-01' AND < '2027-01-01'` sans `SELECT *`.
Coût : **8,82 → 3,22**. Seule la partition `commandes_2026` est lue (80 lignes au lieu de 240).
Partition Pruning : grâce aux bornes de dates, le moteur sait à l'avance que 2024 et 2025 ne contiennent rien d'utile et ne les ouvre pas. Avec `YEAR()`, c'est impossible.

**Q3.** Entreprise : 67 commandes / 297 872 €. Après l'insertion d'une commande de 5 000 €, la vue affiche toujours 67 / 297 872 € : elle est obsolète (stale). Après `REFRESH MATERIALIZED VIEW` : 68 / 302 872 €.

## Partie B

**Q4.** Dépendances fonctionnelles : `employe_id → employe_nom, dept_nom` ; `projet → chef_projet` ; `chef_projet → chef_projet_tel`.
- 1FN : `projets_liste` est éclaté (une ligne par employé et par projet).
- 2FN : les infos de l'employé et du projet partent dans leurs propres tables (elles ne dépendaient que d'une partie de la clé).
- 3FN : le téléphone dépend du chef et pas du projet (dépendance transitive), donc table `chefs_projet`.

Tables : `departements(id PK)`, `employes_aff(id PK, departement_id FK)`, `chefs_projet(id PK)`, `projets(id PK, chef_projet_id FK)`, `affectations(employe_id FK, projet_id FK, PK composée)`.

**Q5.** Voir `q5_cte_dense_rank.sql` : 12 lignes, 2 produits par catégorie.

**Q6.** Voir `q6_with_recursive.sql` : 12 employés sur 4 niveaux, de Claire Moreau (CTO) jusqu'au niveau 4.

## Partie C

**Q7.** La sous-requête renvoie le `NULL` de la CTO. `id NOT IN (…, NULL)` contient `id <> NULL`, qui vaut UNKNOWN : la condition n'est jamais vraie, donc la requête renvoie 0 ligne.
Correction : `NOT EXISTS (SELECT 1 FROM employes s WHERE s.manager_id = e.id)`, qui renvoie 6 employés.

**Q8.** En READ COMMITTED, A lit 15 000. B retire 1 000 et valide. A relit 14 000 dans la même transaction : c'est un Non-Repeatable Read. En REPEATABLE READ, A relit 15 000, car son snapshot est figé au début de la transaction.
WAL : chaque modification est écrite dans le journal avant les données. Si le serveur coupe avant le COMMIT, la transaction est annulée au redémarrage, donc pas de débit sans crédit. Si la coupure arrive après le COMMIT, le journal est rejoué et le virement est conservé.

**Q9.**
- GPS (10 000 écritures/s, un petit retard est acceptable) : **Cassandra**, PA/EL. Elle est faite pour l'écriture massive et la scalabilité horizontale. Redis peut garder la position actuelle en mémoire.
- Facturation (zéro erreur tolérée) : **PostgreSQL**, PC/EC. Transactions ACID : on préfère bloquer un paiement plutôt que le compter deux fois.
- Amis à 3 degrés (parcours de relations) : **Neo4j**. Un parcours de graphe au lieu de 3 jointures coûteuses en SQL.

D'après CAP, on ne peut pas tout avoir en cas de panne réseau. On choisit donc la base selon chaque besoin.

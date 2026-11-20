-- =====================================================================
-- Q9 (3 pts) - Architecture polyglotte : application de covoiturage temps réel
-- =====================================================================

CREATE TABLE IF NOT EXISTS factures_trajets (
    id           BIGSERIAL     PRIMARY KEY,
    trajet_id    BIGINT        NOT NULL,
    passager_id  INT           NOT NULL,
    conducteur_id INT          NOT NULL,
    montant      NUMERIC(10,2) NOT NULL CHECK (montant > 0),
    statut       VARCHAR(20)   NOT NULL DEFAULT 'EN_ATTENTE'
                 CHECK (statut IN ('EN_ATTENTE', 'PAYEE', 'REMBOURSEE')),
    date_facture TIMESTAMP     NOT NULL DEFAULT NOW()
);

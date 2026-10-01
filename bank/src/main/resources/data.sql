INSERT INTO type_transaction (libelle)
SELECT 'DEPOT'
WHERE NOT EXISTS (SELECT 1 FROM type_transaction WHERE libelle = 'DEPOT');

INSERT INTO type_transaction (libelle)
SELECT 'RETRAIT'
WHERE NOT EXISTS (SELECT 1 FROM type_transaction WHERE libelle = 'RETRAIT');

INSERT INTO type_transaction (libelle)
SELECT 'PAIEMENT'
WHERE NOT EXISTS (SELECT 1 FROM type_transaction WHERE libelle = 'PAIEMENT');

-- Deux comptes demo avec solde initial 10 000 000 et PIN 1234 haché BCrypt
-- Hash BCrypt valide pour le PIN "1234"
INSERT INTO compte (numero, solde, date_creation, num_piece, prenom, nom, adresse, date_naissance, telephone, pin)
SELECT 'CP-DEMO-1000001', 10000000, CURRENT_DATE, 'CNI-DEMO-1000001', 'Mamadou', 'Ndiaye', 'Dakar', DATE '1992-03-10', '+221771000001', '$2y$10$6YevfOu4BvvmcfwhyFPr/egIFJNo3Pi8c.TVZjLdtq7Pn4mf/oOYe'
WHERE NOT EXISTS (SELECT 1 FROM compte WHERE numero = 'CP-DEMO-1000001');

INSERT INTO compte (numero, solde, date_creation, num_piece, prenom, nom, adresse, date_naissance, telephone, pin)
SELECT 'CP-DEMO-1000002', 10000000, CURRENT_DATE, 'CNI-DEMO-1000002', 'Fatou', 'Sarr', 'Thies', DATE '1988-07-22', '+221771000002', '$2y$10$6YevfOu4BvvmcfwhyFPr/egIFJNo3Pi8c.TVZjLdtq7Pn4mf/oOYe'
WHERE NOT EXISTS (SELECT 1 FROM compte WHERE numero = 'CP-DEMO-1000002');

INSERT INTO transactions (montant, date, type_id, compte_id)
SELECT '10000000', CURRENT_DATE, t.id, c.id
FROM compte c
JOIN type_transaction t ON t.libelle = 'DEPOT'
WHERE c.numero = 'CP-DEMO-1000001'
  AND NOT EXISTS (
    SELECT 1 FROM transactions tr
    WHERE tr.compte_id = c.id AND tr.type_id = t.id AND tr.montant = '10000000'
);

INSERT INTO transactions (montant, date, type_id, compte_id)
SELECT '10000000', CURRENT_DATE, t.id, c.id
FROM compte c
JOIN type_transaction t ON t.libelle = 'DEPOT'
WHERE c.numero = 'CP-DEMO-1000002'
  AND NOT EXISTS (
    SELECT 1 FROM transactions tr
    WHERE tr.compte_id = c.id AND tr.type_id = t.id AND tr.montant = '10000000'
  );

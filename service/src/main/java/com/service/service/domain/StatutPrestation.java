package com.service.service.domain;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Statut d'une prestation de service")
public enum StatutPrestation {
	@Schema(description = "Prestation enregistrée, en attente du règlement bancaire")
	EN_ATTENTE_PAIEMENT,

	@Schema(description = "Prestation validée et payée avec succès")
	PAYEE,

	@Schema(description = "Échec du paiement (solde insuffisant, PIN incorrect, etc.)")
	ECHOUEE,

	@Schema(description = "Prestation annulée")
	ANNULEE
}

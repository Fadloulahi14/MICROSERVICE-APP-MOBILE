package com.service.service.web.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import io.swagger.v3.oas.annotations.media.Schema;
import java.time.LocalDate;

@Schema(name = "TransactionResponse", description = "Réponse du service de paiement en cas de succès (HTTP 200)")
public record TransactionResponse(
		@Schema(example = "CP-123456") String numeroCompte,
		@Schema(example = "RETRAIT") String type,
		@Schema(description = "Montant du retrait", example = "12000") long montant,
		@Schema(description = "Solde après opération", example = "138000") long nouveauSolde,
		@JsonFormat(pattern = "yyyy-MM-dd")
				@Schema(description = "Date de l'opération (ISO date)", example = "2026-05-13")
				LocalDate date) {
}

package com.service.service.web.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import io.swagger.v3.oas.annotations.media.Schema;

@JsonInclude(JsonInclude.Include.NON_NULL)
@Schema(name = "PaymentInitResponse")
public record PaymentInitResponse(
		@Schema(description = "Code HTTP du service de paiement") int statut,
		@Schema(description = "Transaction renvoyée en cas de succès (200)") TransactionResponse transaction,
		@Schema(description = "Corps brut JSON (debug / compat)") String corpsBrut) {
}

package com.service.service.web.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;

@Schema(description = "Demande de paiement d'une prestation avec validation du code PIN")
public record PaiementRequest(
		@NotBlank(message = "Le code PIN est obligatoire pour confirmer le paiement")
		@Schema(description = "Code PIN du wallet client", example = "1234")
		String pin
) {
}

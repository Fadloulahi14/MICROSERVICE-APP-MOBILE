package com.service.service.web.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Set;

@Schema(name = "PrestationRequest")
public record PrestationRequest(
		@NotNull @JsonProperty("datedebut") @Schema(description = "Début de la prestation", example = "2026-06-01T09:00:00")
		LocalDateTime dateDebut,
		@NotNull @JsonProperty("datefin") @Schema(description = "Fin de la prestation", example = "2026-08-31T18:00:00")
		LocalDateTime dateFin,
		@Size(max = 4000) @Schema(description = "Description libre")
		String description,
		@NotNull @PositiveOrZero @Schema(description = "Prix total", example = "12000.00")
		BigDecimal prix,
		@NotBlank @Size(max = 64) @Schema(description = "Téléphone client", example = "+221771234567")
		String telephone,
		@Schema(description = "Code PIN du wallet client pour valider le paiement", example = "1234")
		String pin,
		@NotEmpty @Schema(description = "Identifiants des services catalogue (M:N)", example = "[1, 2]")
		Set<Long> serviceIds) {
}

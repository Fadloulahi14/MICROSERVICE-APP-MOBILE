package com.service.service.web.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;
import com.service.service.domain.StatutPrestation;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Schema(name = "PrestationResponse")
public record PrestationResponse(
		@Schema(description = "Identifiant de la prestation") Long id,
		@JsonProperty("datedebut") @Schema(description = "Début") LocalDateTime dateDebut,
		@JsonProperty("datefin") @Schema(description = "Fin") LocalDateTime dateFin,
		@Schema(description = "Description") String description,
		@Schema(description = "Prix") BigDecimal prix,
		@Schema(description = "Téléphone") String telephone,
		@Schema(description = "Statut de la prestation (EN_ATTENTE_PAIEMENT, PAYEE, ECHOUEE, ANNULEE)") StatutPrestation statut,
		@Schema(description = "Services catalogue liés (M:N)") List<ServiceCatalogResponse> services) {
}

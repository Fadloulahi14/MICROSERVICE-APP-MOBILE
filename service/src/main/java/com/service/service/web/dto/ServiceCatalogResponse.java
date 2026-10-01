package com.service.service.web.dto;

import io.swagger.v3.oas.annotations.media.Schema;

@Schema(name = "ServiceCatalogResponse")
public record ServiceCatalogResponse(
		@Schema(description = "Identifiant") Long id,
		@Schema(description = "Nom du service") String nom) {
}

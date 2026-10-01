package com.service.service.web.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

@Schema(name = "ServiceCatalogRequest")
public record ServiceCatalogRequest(
		@NotBlank @Size(max = 255) @Schema(description = "Nom du service catalogue", example = "Développement sur mesure")
		String nom) {
}

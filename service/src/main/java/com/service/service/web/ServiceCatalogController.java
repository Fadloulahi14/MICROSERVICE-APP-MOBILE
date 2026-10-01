package com.service.service.web;

import com.service.service.helper.ServiceCatalogHelper;
import com.service.service.web.dto.ServiceCatalogRequest;
import com.service.service.web.dto.ServiceCatalogResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/services")
@Tag(name = "Catalogue services", description = "Offres de l'entreprise (id, nom)")
public class ServiceCatalogController {

	private final ServiceCatalogHelper serviceCatalogHelper;

	public ServiceCatalogController(ServiceCatalogHelper serviceCatalogHelper) {
		this.serviceCatalogHelper = serviceCatalogHelper;
	}

	@PostMapping
	@ResponseStatus(HttpStatus.CREATED)
	@Operation(summary = "Créer un service catalogue")
	@ApiResponses({
		@ApiResponse(responseCode = "201", description = "Service créé"),
		@ApiResponse(responseCode = "400", description = "Requête invalide")
	})
	public ServiceCatalogResponse create(@Valid @RequestBody ServiceCatalogRequest request) {
		return serviceCatalogHelper.create(request);
	}

	@GetMapping
	@Operation(summary = "Lister les services catalogue")
	public List<ServiceCatalogResponse> list() {
		return serviceCatalogHelper.list();
	}

	@GetMapping("/{id}")
	@Operation(summary = "Obtenir un service par identifiant")
	@ApiResponse(responseCode = "404", description = "Service introuvable")
	public ServiceCatalogResponse get(
			@Parameter(description = "Identifiant du service") @PathVariable Long id) {
		return serviceCatalogHelper.getById(id);
	}
}

package com.service.service.web;

import com.service.service.helper.PaymentHelper;
import com.service.service.helper.PrestationHelper;
import com.service.service.web.dto.PaiementRequest;
import com.service.service.web.dto.PrestationRequest;
import com.service.service.web.dto.PrestationResponse;
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
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/prestations")
@Tag(name = "Prestations", description = "Prestations liées à plusieurs services catalogue (M:N)")
public class PrestationController {

	private final PrestationHelper prestationHelper;
	private final PaymentHelper paymentHelper;

	public PrestationController(PrestationHelper prestationHelper, PaymentHelper paymentHelper) {
		this.prestationHelper = prestationHelper;
		this.paymentHelper = paymentHelper;
	}

	@PostMapping
	@ResponseStatus(HttpStatus.CREATED)
	@Operation(
			summary = "Créer une commande de prestation",
			description =
					"1) Si le PIN est fourni, exécute le paiement vers le microservice Wallet et enregistre la prestation avec le statut PAYEE. "
							+ "2) Si le PIN n'est pas fourni, enregistre la prestation avec le statut EN_ATTENTE_PAIEMENT. "
							+ "3) Erreurs 400/404/500 du paiement sont relayées avec le message approprié.")
	@ApiResponses({
		@ApiResponse(responseCode = "201", description = "Prestation créée avec succès"),
		@ApiResponse(responseCode = "400", description = "Validation locale ou message du service de paiement (PIN invalide, solde insuffisant)"),
		@ApiResponse(responseCode = "404", description = "Service catalogue introuvable ou compte client inexistant"),
		@ApiResponse(responseCode = "500", description = "Erreur interne"),
		@ApiResponse(responseCode = "502", description = "Microservice Wallet injoignable")
	})
	public PrestationResponse create(@Valid @RequestBody PrestationRequest request) {
		return prestationHelper.create(request);
	}

	@PutMapping("/{id}")
	@Operation(summary = "Mettre à jour une prestation")
	@ApiResponse(responseCode = "404", description = "Prestation ou service introuvable")
	public PrestationResponse update(
			@Parameter(description = "Identifiant de la prestation") @PathVariable Long id,
			@Valid @RequestBody PrestationRequest request) {
		return prestationHelper.update(id, request);
	}

	@GetMapping
	@Operation(summary = "Lister les prestations (avec services liés et statuts)")
	public List<PrestationResponse> list() {
		return prestationHelper.findAll();
	}

	@PostMapping("/{id}/paiement")
	@Operation(
			summary = "Régler une prestation existante avec le code PIN",
			description =
					"Appelle POST /api/paiements/prestation sur le microservice Wallet avec { \"montant\": ..., \"telephoneClient\": ..., \"pin\": ... }. "
							+ "En cas de succès HTTP 200, le statut de la prestation passe à PAYEE.")
	@ApiResponses({
		@ApiResponse(responseCode = "200", description = "Paiement réussi, prestation mise à jour avec statut PAYEE"),
		@ApiResponse(responseCode = "400", description = "Erreur métier (PIN invalide, solde insuffisant ou prestation déjà payée)"),
		@ApiResponse(responseCode = "401", description = "Token JWT absent ou invalide"),
		@ApiResponse(responseCode = "404", description = "Prestation ou compte introuvable"),
		@ApiResponse(responseCode = "502", description = "Microservice Wallet distant injoignable")
	})
	public PrestationResponse payer(
			@Parameter(description = "Identifiant de la prestation") @PathVariable Long id,
			@Valid @RequestBody PaiementRequest paymentRequest) {
		return prestationHelper.payer(id, paymentRequest.pin());
	}

	@GetMapping("/{id}")
	@Operation(summary = "Obtenir une prestation par identifiant")
	@ApiResponse(responseCode = "404", description = "Prestation introuvable")
	public PrestationResponse get(
			@Parameter(description = "Identifiant de la prestation") @PathVariable Long id) {
		return prestationHelper.findById(id);
	}
}

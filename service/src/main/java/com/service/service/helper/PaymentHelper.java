package com.service.service.helper;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.service.service.domain.Prestation;
import com.service.service.exception.BadRequestException;
import com.service.service.exception.NotFoundException;
import com.service.service.exception.PaymentBusinessException;
import com.service.service.payment.PaymentRestClient;
import com.service.service.persistence.PrestationPersistenceService;
import com.service.service.web.dto.PaymentInitResponse;
import com.service.service.web.dto.PrestationRequest;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.LinkedHashMap;
import java.util.Map;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Component
public class PaymentHelper {

	private final PrestationPersistenceService prestationPersistenceService;
	private final PaymentRestClient paymentRestClient;
	private final ObjectMapper objectMapper;

	public PaymentHelper(
			PrestationPersistenceService prestationPersistenceService,
			PaymentRestClient paymentRestClient,
			ObjectMapper objectMapper) {
		this.prestationPersistenceService = prestationPersistenceService;
		this.paymentRestClient = paymentRestClient;
		this.objectMapper = objectMapper;
	}

	/**
	 * Appelé avant la création ou lors de la confirmation : le service de paiement doit répondre 200 avec {@link com.service.service.web.dto.TransactionResponse}.
	 */
	public PaymentInitResponse initierPaiementPourDemande(PrestationRequest request) {
		if (request.pin() == null || request.pin().isBlank()) {
			throw new BadRequestException("Le code PIN est obligatoire pour valider le paiement du service");
		}
		try {
			String json = objectMapper.writeValueAsString(buildPaymentPayload(request.prix(), request.telephone(), request.pin()));
			PaymentInitResponse reponse = paymentRestClient.initiatePayment(json);
			exigerSuccesPaiementPourCreation(reponse);
			return reponse;
		} catch (JsonProcessingException ex) {
			throw new IllegalStateException("Impossible de construire la requête de paiement", ex);
		}
	}

	@Transactional(readOnly = true)
	public PaymentInitResponse initierPaiementPourPrestation(Long prestationId, String pin) {
		if (pin == null || pin.isBlank()) {
			throw new BadRequestException("Le code PIN est obligatoire pour valider le paiement du service");
		}
		Prestation prestation = prestationPersistenceService
				.findById(prestationId)
				.orElseThrow(() -> new NotFoundException("Prestation introuvable: " + prestationId));
		try {
			String json =
					objectMapper.writeValueAsString(buildPaymentPayload(prestation.getPrix(), prestation.getTelephone(), pin));
			PaymentInitResponse reponse = paymentRestClient.initiatePayment(json);
			exigerSuccesPaiementPourCreation(reponse);
			return reponse;
		} catch (NotFoundException ex) {
			throw ex;
		} catch (JsonProcessingException ex) {
			throw new IllegalStateException("Impossible de construire la requête de paiement", ex);
		}
	}

	private static Map<String, Object> buildPaymentPayload(BigDecimal montant, String telephone, String pin) {
		Map<String, Object> payload = new LinkedHashMap<>();
		payload.put("montant", montantEntier(montant));
		payload.put("telephoneClient", telephone);
		payload.put("pin", pin != null ? pin.trim() : "");
		return payload;
	}

	/**
	 * Le service distant exige un montant entier (cf. message d'erreur Bean Validation côté paiement).
	 */
	private static long montantEntier(BigDecimal montant) {
		if (montant == null) {
			throw new BadRequestException("Le montant est obligatoire");
		}
		if (montant.signum() <= 0) {
			throw new BadRequestException("Le montant doit être positif");
		}
		try {
			return montant.setScale(0, RoundingMode.UNNECESSARY).longValueExact();
		} catch (ArithmeticException ex) {
			throw new BadRequestException("Le montant doit etre un nombre entier (ex: 12000 ou 12000.00)");
		}
	}

	private static void exigerSuccesPaiementPourCreation(PaymentInitResponse reponse) {
		if (reponse.statut() != 200) {
			throw new PaymentBusinessException(reponse.statut(), "Le paiement a échoué (HTTP " + reponse.statut() + ")");
		}
		if (reponse.transaction() == null) {
			throw new PaymentBusinessException(502, "Réponse 200 invalide : TransactionResponse attendu");
		}
	}
}

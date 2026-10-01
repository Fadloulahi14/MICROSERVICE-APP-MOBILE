package com.service.service.helper;

import com.service.service.domain.Prestation;
import com.service.service.domain.ServiceCatalog;
import com.service.service.domain.StatutPrestation;
import com.service.service.exception.BadRequestException;
import com.service.service.exception.NotFoundException;
import com.service.service.mapper.PrestationMapper;
import com.service.service.persistence.PrestationPersistenceService;
import com.service.service.persistence.ServiceCatalogPersistenceService;
import com.service.service.web.dto.PrestationRequest;
import com.service.service.web.dto.PrestationResponse;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionTemplate;

@Component
public class PrestationHelper {

	private final PrestationPersistenceService prestationPersistenceService;
	private final ServiceCatalogPersistenceService serviceCatalogPersistenceService;
	private final PrestationMapper prestationMapper;
	private final PaymentHelper paymentHelper;
	private final TransactionTemplate transactionTemplate;

	public PrestationHelper(
			PrestationPersistenceService prestationPersistenceService,
			ServiceCatalogPersistenceService serviceCatalogPersistenceService,
			PrestationMapper prestationMapper,
			PaymentHelper paymentHelper,
			TransactionTemplate transactionTemplate) {
		this.prestationPersistenceService = prestationPersistenceService;
		this.serviceCatalogPersistenceService = serviceCatalogPersistenceService;
		this.prestationMapper = prestationMapper;
		this.paymentHelper = paymentHelper;
		this.transactionTemplate = transactionTemplate;
	}

	public PrestationResponse create(PrestationRequest request) {
		validateDates(request);

		// Si un code PIN est fourni, on effectue le débit bancaire
		if (request.pin() != null && !request.pin().isBlank()) {
			paymentHelper.initierPaiementPourDemande(request);
			return transactionTemplate.execute(status -> {
				Prestation prestation = new Prestation();
				prestationMapper.applyRequest(prestation, request);
				prestation.setStatut(StatutPrestation.PAYEE);
				prestation.replaceServices(resolveServices(request.serviceIds()));
				Prestation saved = prestationPersistenceService.save(prestation);
				return prestationMapper.toResponse(saved);
			});
		}

		// Sans PIN immédiat, la prestation reste en attente de paiement
		return transactionTemplate.execute(status -> {
			Prestation prestation = new Prestation();
			prestationMapper.applyRequest(prestation, request);
			prestation.setStatut(StatutPrestation.EN_ATTENTE_PAIEMENT);
			prestation.replaceServices(resolveServices(request.serviceIds()));
			Prestation saved = prestationPersistenceService.save(prestation);
			return prestationMapper.toResponse(saved);
		});
	}

	@Transactional
	public PrestationResponse payer(Long id, String pin) {
		Prestation prestation = prestationPersistenceService
				.findById(id)
				.orElseThrow(() -> new NotFoundException("Prestation introuvable: " + id));

		if (prestation.getStatut() == StatutPrestation.PAYEE) {
			throw new BadRequestException("Cette prestation est déjà réglée (statut PAYEE)");
		}

		paymentHelper.initierPaiementPourPrestation(id, pin);
		prestation.setStatut(StatutPrestation.PAYEE);
		Prestation saved = prestationPersistenceService.save(prestation);
		return prestationMapper.toResponse(saved);
	}

	@Transactional
	public PrestationResponse update(Long id, PrestationRequest request) {
		validateDates(request);
		Prestation prestation = prestationPersistenceService
				.findById(id)
				.orElseThrow(() -> new NotFoundException("Prestation introuvable: " + id));
		prestationMapper.applyRequest(prestation, request);
		prestation.replaceServices(resolveServices(request.serviceIds()));
		Prestation saved = prestationPersistenceService.save(prestation);
		return prestationMapper.toResponse(saved);
	}

	@Transactional(readOnly = true)
	public List<PrestationResponse> findAll() {
		return prestationPersistenceService.findAllWithServices().stream()
				.map(prestationMapper::toResponse)
				.toList();
	}

	@Transactional(readOnly = true)
	public PrestationResponse findById(Long id) {
		return prestationPersistenceService
				.findByIdWithServices(id)
				.map(prestationMapper::toResponse)
				.orElseThrow(() -> new NotFoundException("Prestation introuvable: " + id));
	}

	private static void validateDates(PrestationRequest request) {
		if (request.dateFin().isBefore(request.dateDebut())) {
			throw new BadRequestException("dateFin doit être postérieure ou égale à dateDebut");
		}
	}

	private Set<ServiceCatalog> resolveServices(Set<Long> serviceIds) {
		List<ServiceCatalog> found = serviceCatalogPersistenceService.findAllById(serviceIds);
		if (found.size() != serviceIds.size()) {
			throw new NotFoundException("Un ou plusieurs services du catalogue sont introuvables");
		}
		return new HashSet<>(found);
	}
}

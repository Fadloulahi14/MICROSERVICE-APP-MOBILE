package com.service.service.mapper;

import com.service.service.domain.Prestation;
import com.service.service.domain.ServiceCatalog;
import com.service.service.web.dto.PrestationRequest;
import com.service.service.web.dto.PrestationResponse;
import com.service.service.web.dto.ServiceCatalogResponse;
import java.util.Comparator;
import java.util.List;
import org.springframework.stereotype.Component;

@Component
public class PrestationMapper {

	private final ServiceCatalogMapper serviceCatalogMapper;

	public PrestationMapper(ServiceCatalogMapper serviceCatalogMapper) {
		this.serviceCatalogMapper = serviceCatalogMapper;
	}

	public void applyRequest(Prestation prestation, PrestationRequest request) {
		prestation.setDateDebut(request.dateDebut());
		prestation.setDateFin(request.dateFin());
		prestation.setDescription(request.description());
		prestation.setPrix(request.prix());
		prestation.setTelephone(request.telephone());
	}

	public PrestationResponse toResponse(Prestation prestation) {
		List<ServiceCatalogResponse> services = prestation.getServices().stream()
				.sorted(Comparator.comparing(ServiceCatalog::getId))
				.map(serviceCatalogMapper::toResponse)
				.toList();
		return new PrestationResponse(
				prestation.getId(),
				prestation.getDateDebut(),
				prestation.getDateFin(),
				prestation.getDescription(),
				prestation.getPrix(),
				prestation.getTelephone(),
				prestation.getStatut(),
				services);
	}
}

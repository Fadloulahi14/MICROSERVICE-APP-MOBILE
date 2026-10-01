package com.service.service.mapper;

import com.service.service.domain.ServiceCatalog;
import com.service.service.web.dto.ServiceCatalogRequest;
import com.service.service.web.dto.ServiceCatalogResponse;
import org.springframework.stereotype.Component;

@Component
public class ServiceCatalogMapper {

	public ServiceCatalog toEntity(ServiceCatalogRequest request) {
		return new ServiceCatalog(request.nom());
	}

	public ServiceCatalogResponse toResponse(ServiceCatalog entity) {
		return new ServiceCatalogResponse(entity.getId(), entity.getNom());
	}
}

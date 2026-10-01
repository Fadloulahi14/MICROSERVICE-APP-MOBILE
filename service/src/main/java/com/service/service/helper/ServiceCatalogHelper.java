package com.service.service.helper;

import com.service.service.exception.NotFoundException;
import com.service.service.mapper.ServiceCatalogMapper;
import com.service.service.persistence.ServiceCatalogPersistenceService;
import com.service.service.web.dto.ServiceCatalogRequest;
import com.service.service.web.dto.ServiceCatalogResponse;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Component
public class ServiceCatalogHelper {

	@Autowired
	private ServiceCatalogPersistenceService serviceCatalogPersistenceService;

	@Autowired
	private ServiceCatalogMapper serviceCatalogMapper;


	@Transactional
	public ServiceCatalogResponse create(ServiceCatalogRequest request) {
		var entity = serviceCatalogMapper.toEntity(request);
		var saved = serviceCatalogPersistenceService.save(entity);
		return serviceCatalogMapper.toResponse(saved);
	}

	@Transactional(readOnly = true)
	public List<ServiceCatalogResponse> list() {
		return serviceCatalogPersistenceService.findAll().stream()
				.map(serviceCatalogMapper::toResponse)
				.toList();
	}

	@Transactional(readOnly = true)
	public ServiceCatalogResponse getById(Long id) {
		return serviceCatalogPersistenceService
				.findById(id)
				.map(serviceCatalogMapper::toResponse)
				.orElseThrow(() -> new NotFoundException("Service introuvable: " + id));
	}
}

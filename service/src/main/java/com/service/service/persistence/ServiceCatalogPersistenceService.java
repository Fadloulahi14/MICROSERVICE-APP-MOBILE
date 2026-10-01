package com.service.service.persistence;

import com.service.service.domain.ServiceCatalog;
import com.service.service.repository.ServiceCatalogRepository;
import java.util.Collection;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional(readOnly = true)
public class ServiceCatalogPersistenceService {
	@Autowired
	private ServiceCatalogRepository serviceCatalogRepository;

	@Transactional
	public ServiceCatalog save(ServiceCatalog entity) {
		return serviceCatalogRepository.save(entity);
	}

	public List<ServiceCatalog> findAll() {
		return serviceCatalogRepository.findAll();
	}

	public Optional<ServiceCatalog> findById(Long id) {
		return serviceCatalogRepository.findById(id);
	}

	public List<ServiceCatalog> findAllById(Collection<Long> ids) {
		return serviceCatalogRepository.findAllById(ids);
	}
}

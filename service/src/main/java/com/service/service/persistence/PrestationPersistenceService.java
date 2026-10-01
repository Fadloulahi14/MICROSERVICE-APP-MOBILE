package com.service.service.persistence;

import com.service.service.domain.Prestation;
import com.service.service.repository.PrestationRepository;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional(readOnly = true)
public class PrestationPersistenceService {

	@Autowired
	private PrestationRepository prestationRepository;

	@Transactional
	public Prestation save(Prestation entity) {
		return prestationRepository.save(entity);
	}

	public List<Prestation> findAllWithServices() {
		return prestationRepository.findAllWithServices();
	}

	public Optional<Prestation> findByIdWithServices(Long id) {
		return prestationRepository.findByIdWithServices(id);
	}

	public Optional<Prestation> findById(Long id) {
		return prestationRepository.findById(id);
	}
}

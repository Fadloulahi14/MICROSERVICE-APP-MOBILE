package com.service.service.repository;

import com.service.service.domain.Prestation;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface PrestationRepository extends JpaRepository<Prestation, Long> {

	@Query("SELECT DISTINCT p FROM Prestation p LEFT JOIN FETCH p.services")
	List<Prestation> findAllWithServices();

	@Query("SELECT DISTINCT p FROM Prestation p LEFT JOIN FETCH p.services WHERE p.id = :id")
	Optional<Prestation> findByIdWithServices(@Param("id") Long id);
}

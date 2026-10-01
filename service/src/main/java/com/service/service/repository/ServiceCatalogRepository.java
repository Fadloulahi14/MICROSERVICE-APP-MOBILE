package com.service.service.repository;

import com.service.service.domain.ServiceCatalog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ServiceCatalogRepository extends JpaRepository<ServiceCatalog, Long> {
}

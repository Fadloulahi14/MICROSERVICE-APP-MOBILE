package com.service.service.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "prestation")
@Getter
@Setter
@NoArgsConstructor
public class Prestation {

	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	private Long id;

	@Column(name = "date_debut", nullable = false)
	private LocalDateTime dateDebut;

	@Column(name = "date_fin", nullable = false)
	private LocalDateTime dateFin;

	@Column(length = 4000)
	private String description;

	@Column(nullable = false, precision = 19, scale = 2)
	private BigDecimal prix;

	@Column(nullable = false, length = 64)
	private String telephone;

	@jakarta.persistence.Enumerated(jakarta.persistence.EnumType.STRING)
	@Column(name = "statut", nullable = false, length = 32)
	private StatutPrestation statut = StatutPrestation.EN_ATTENTE_PAIEMENT;

	@ManyToMany(fetch = FetchType.LAZY)
	@JoinTable(
			name = "prestation_service_catalog",
			joinColumns = @JoinColumn(name = "prestation_id"),
			inverseJoinColumns = @JoinColumn(name = "service_catalog_id"))
	private Set<ServiceCatalog> services = new HashSet<>();

	public void replaceServices(Set<ServiceCatalog> next) {
		services.clear();
		if (next != null) {
			services.addAll(next);
		}
	}
}

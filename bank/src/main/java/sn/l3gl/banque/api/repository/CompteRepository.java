package sn.l3gl.banque.api.repository;

import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import sn.l3gl.banque.api.model.Compte;

@Repository
public interface CompteRepository extends JpaRepository<Compte, Long> {
    Optional<Compte> findByNumero(String numero);

    Optional<Compte> findByTelephone(String telephone);

    @Query("""
                SELECT c
                FROM Compte c
                WHERE c.numero = :value OR c.telephone = :value
            """)
    Optional<Compte> findByNumeroOrTelephone(String value);
}

package sn.l3gl.banque.api.repository;

import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import sn.l3gl.banque.api.model.TypeTransaction;

@Repository
public interface TypeRepository extends JpaRepository<TypeTransaction, Long> {
    Optional<TypeTransaction> findFirstByLibelleOrderByIdAsc(String libelle);
}

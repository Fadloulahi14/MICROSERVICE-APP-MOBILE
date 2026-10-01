package sn.l3gl.banque.api.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import sn.l3gl.banque.api.model.TypeTransaction;
import sn.l3gl.banque.api.repository.TypeRepository;

import java.util.Optional;

@Service
public class TypeService {

    @Autowired
    private TypeRepository typeRepository;

    public Optional<TypeTransaction> findByLibelle(String libelle) {
        return typeRepository.findFirstByLibelleOrderByIdAsc(libelle);
    }
}

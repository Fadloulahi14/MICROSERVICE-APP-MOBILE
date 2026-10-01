package sn.l3gl.banque.api.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import sn.l3gl.banque.api.model.Compte;
import sn.l3gl.banque.api.repository.CompteRepository;

import java.util.Optional;

@Service
public class CompteService {

    @Autowired
    private CompteRepository compteRepository;

    public Compte save(Compte compte) {
        return compteRepository.save(compte);
    }

    public Optional<Compte> findByNumero(String numero) {
        return compteRepository.findByNumero(numero);
    }

    public Optional<Compte> findByTelephone(String telephone) {
        return compteRepository.findByTelephone(telephone);
    }

    public Optional<Compte> findByNumeroOrTelephone(String numeroOrTelephone) {
        return compteRepository.findByNumeroOrTelephone(numeroOrTelephone);
    }
}

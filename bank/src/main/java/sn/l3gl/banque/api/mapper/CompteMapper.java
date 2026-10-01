package sn.l3gl.banque.api.mapper;

import java.time.LocalDate;

import org.springframework.stereotype.Component;
import sn.l3gl.banque.api.dto.CompteResponse;
import sn.l3gl.banque.api.dto.CreateCompteRequest;
import sn.l3gl.banque.api.model.Compte;

@Component
public class CompteMapper {

    public Compte toEntity(CreateCompteRequest request) {
        if (request == null) {
            return null;
        }
        Compte compte = new Compte();
        compte.setSolde(request.getSolde());
        compte.setNumPiece(request.getNumPiece());
        compte.setPrenom(request.getPrenom());
        compte.setNom(request.getNom());
        compte.setAdresse(request.getAdresse());
        compte.setDateNaissance(request.getDateNaissance());
        compte.setTelephone(request.getTelephone());
        compte.setDateCreation(LocalDate.now());
        return compte;
    }

    public CompteResponse toResponse(Compte compte) {
        if (compte == null) {
            return null;
        }
        CompteResponse response = new CompteResponse();
        response.setNumero(compte.getNumero());
        response.setSolde(compte.getSolde());
        response.setDateCreation(compte.getDateCreation());
        response.setNumPiece(compte.getNumPiece());
        response.setPrenom(compte.getPrenom());
        response.setNom(compte.getNom());
        response.setAdresse(compte.getAdresse());
        response.setDateNaissance(compte.getDateNaissance());
        response.setTelephone(compte.getTelephone());
        return response;
    }
}

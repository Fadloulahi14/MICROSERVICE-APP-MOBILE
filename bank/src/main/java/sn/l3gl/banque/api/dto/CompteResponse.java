package sn.l3gl.banque.api.dto;

import lombok.Getter;
import lombok.Setter;
import java.time.LocalDate;

@Getter
@Setter
public class CompteResponse {
    private String numero;
    private long solde;
    private LocalDate dateCreation;
    private String numPiece;
    private String prenom;
    private String nom;
    private String adresse;
    private LocalDate dateNaissance;
    private String telephone;
}

package sn.l3gl.banque.api.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;
import java.time.LocalDate;

@Getter
@Setter
public class CreateCompteRequest {
    
    @Min(value = 10000, message = "Le montant initial doit etre minimum 10000 !")
    private int solde;

    //infos client
    @NotNull(message = "Le prenom est requis!")
    private String prenom;
    @NotNull(message = "Le nom est requis!")
    private String nom;

    @NotNull(message = "Le numéro de téléphone est requis!")
    private String telephone;
    @NotNull(message = "L'adresse est requise!")
    private String adresse;

    @NotNull(message = "Le numéro de pièce est requis!")
    private String numPiece;
    @NotNull(message = "La date de naissance est requise!")
    private LocalDate dateNaissance;

    @NotNull(message = "Le code PIN est obligatoire!")
    @jakarta.validation.constraints.Pattern(regexp = "^\\d{4,6}$", message = "Le code PIN doit comporter entre 4 et 6 chiffres")
    private String pin;

    @NotNull(message = "Le code OTP est obligatoire!")
    @jakarta.validation.constraints.Pattern(regexp = "^\\d{6}$", message = "Le code OTP doit comporter 6 chiffres")
    private String otp;
}

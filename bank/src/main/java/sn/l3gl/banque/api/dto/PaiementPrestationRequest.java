package sn.l3gl.banque.api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;

@Getter
@Setter
public class PaiementPrestationRequest {

    @NotNull(message = "Le montant est obligatoire")
    @Positive(message = "Le montant doit etre superieur a 0")
    private BigDecimal montant;

    @NotBlank(message = "Le telephone du client est obligatoire")
    private String telephoneClient;

    @NotBlank(message = "Le code PIN est obligatoire pour valider le paiement")
    private String pin;
}

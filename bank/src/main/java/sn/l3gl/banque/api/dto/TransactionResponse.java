package sn.l3gl.banque.api.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.LocalDate;

@Getter
@AllArgsConstructor
public class TransactionResponse {
    private String numeroCompte;
    private String type;
    private long montant;
    private long nouveauSolde;
    private LocalDate date;
}

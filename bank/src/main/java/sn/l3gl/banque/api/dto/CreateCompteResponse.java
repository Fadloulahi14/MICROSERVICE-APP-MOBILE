package sn.l3gl.banque.api.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class CreateCompteResponse {
    private String message;
    private String numeroCompte;
    private String telephone;
    private String token;

    public CreateCompteResponse(String message, String numeroCompte) {
        this.message = message;
        this.numeroCompte = numeroCompte;
    }
}

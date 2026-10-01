package sn.l3gl.banque.api.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Réponse d'authentification avec JWT")
public class AuthResponse {

    @Schema(description = "Token JWT", example = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...")
    private String token;

    @Schema(description = "Type de token", example = "Bearer")
    private String tokenType = "Bearer";

    @Schema(description = "Numéro de téléphone", example = "+221771000001")
    private String telephone;

    @Schema(description = "Numéro de compte associé", example = "CP-123456")
    private String numeroCompte;

    public AuthResponse(String token) {
        this.token = token;
        this.tokenType = "Bearer";
    }

    public AuthResponse(String token, String telephone, String numeroCompte) {
        this.token = token;
        this.tokenType = "Bearer";
        this.telephone = telephone;
        this.numeroCompte = numeroCompte;
    }
}

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
@Schema(description = "Demande d'authentification par téléphone et PIN (ou identifiants)")
public class AuthRequest {

    @Schema(description = "Numéro de téléphone ou nom d'utilisateur", example = "+221771000001")
    private String username;

    @Schema(description = "Code PIN ou mot de passe", example = "1234")
    private String password;

    private String telephone;
    private String pin;

    public String resolveIdentifier() {
        if (telephone != null && !telephone.isBlank()) {
            return telephone.trim();
        }
        return username != null ? username.trim() : "";
    }

    public String resolveSecret() {
        if (pin != null && !pin.isBlank()) {
            return pin.trim();
        }
        return password != null ? password.trim() : "";
    }
}

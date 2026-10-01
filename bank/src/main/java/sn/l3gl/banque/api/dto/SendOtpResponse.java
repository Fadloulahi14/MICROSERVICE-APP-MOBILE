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
@Schema(description = "Réponse suite à la demande d'OTP (simulation)")
public class SendOtpResponse {

    @Schema(description = "Message de confirmation", example = "Code OTP généré avec succès")
    private String message;

    @Schema(description = "Numéro de téléphone concerné", example = "+221771000001")
    private String telephone;

    @Schema(description = "Code OTP simulé pour les tests", example = "482915")
    private String otp;
}

package sn.l3gl.banque.api.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Demande d'envoi de code OTP pour validation du numéro de téléphone")
public class SendOtpRequest {

    @NotBlank(message = "Le numéro de téléphone est obligatoire")
    @Schema(description = "Numéro de téléphone du client", example = "+221771000001")
    private String telephone;
}

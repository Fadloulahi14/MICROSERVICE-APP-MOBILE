package sn.l3gl.banque.api.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CreateTransactionRequest {

    @NotBlank(message = "Le type de transaction est obligatoire")
    private String type;

    @Min(value = 1, message = "Le montant doit etre superieur a 0")
    private long montant;

    private String pin;
}

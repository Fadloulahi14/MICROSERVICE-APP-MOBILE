package sn.l3gl.banque.api.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import sn.l3gl.banque.api.dto.PaiementPrestationRequest;
import sn.l3gl.banque.api.dto.TransactionResponse;
import sn.l3gl.banque.api.helper.CompteHelper;

@Tag(name = "Paiements", description = "Paiements et prestations")
@RequestMapping("/api/paiements")
@RestController
public class PaiementController {

    @Autowired
    private CompteHelper compteHelper;

    @Operation(
            summary = "Paiement de prestation (débit sécurisé avec PIN)",
            description = "Vérifie l'identité du client, la validité du PIN haché en BCrypt et la suffisance du solde avant d'enregistrer le débit."
    )
    @PostMapping("/prestation")
    @PreAuthorize("hasAnyRole('AGENT', 'USER', 'ADMIN') or isAuthenticated()")
    public ResponseEntity<TransactionResponse> payerPrestation(
            @Valid @RequestBody PaiementPrestationRequest request
    ) {
        return ResponseEntity.ok(compteHelper.paiementPrestationAgent(request));
    }
}

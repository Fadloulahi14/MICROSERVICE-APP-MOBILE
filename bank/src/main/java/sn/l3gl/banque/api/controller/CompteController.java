package sn.l3gl.banque.api.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import sn.l3gl.banque.api.dto.CompteResponse;
import sn.l3gl.banque.api.dto.CreateCompteRequest;
import sn.l3gl.banque.api.dto.CreateCompteResponse;
import sn.l3gl.banque.api.dto.CreateTransactionRequest;
import sn.l3gl.banque.api.dto.TransactionResponse;
import sn.l3gl.banque.api.helper.CompteHelper;

import java.net.URI;

@Tag(name = "Comptes", description = "Gestion des comptes bancaires")
@RequestMapping("/api/comptes")
@RestController
public class CompteController {

    @Autowired
    private CompteHelper compteHelper;

    @Operation(summary = "Créer un nouveau compte", description = "Crée un compte avec client existant ou nouveau")
    @PostMapping
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<CreateCompteResponse> saveCompte(@Valid @RequestBody CreateCompteRequest request) {
        CreateCompteResponse response = compteHelper.saveCompte(request);
        URI uri = URI.create("/api/comptes/" + response.getNumeroCompte());
        return ResponseEntity.created(uri).body(response);
    }

    @Operation(summary = "Rechercher un compte par numéro de compte ou par téléphone", description = "Retourne les détails du compte")
    @GetMapping("/{numero}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<CompteResponse> getCompteByNumero(@PathVariable String numero) {
        return ResponseEntity.ok(compteHelper.getCompteByNumeroOrTelephone(numero));
    }

    @Operation(summary = "Faire une transaction", description = "Permet de faire un depot ou un retrait sur un compte")
    @PostMapping("/{numero}/transactions")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<TransactionResponse> createTransaction(
            @PathVariable String numero,
            @Valid @RequestBody CreateTransactionRequest request
    ) {
        return ResponseEntity.ok(compteHelper.createTransaction(numero, request));
    }
}

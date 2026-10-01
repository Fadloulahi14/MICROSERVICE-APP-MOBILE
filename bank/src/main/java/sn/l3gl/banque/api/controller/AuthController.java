package sn.l3gl.banque.api.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import sn.l3gl.banque.api.dto.AuthRequest;
import sn.l3gl.banque.api.dto.AuthResponse;
import sn.l3gl.banque.api.dto.CreateCompteRequest;
import sn.l3gl.banque.api.dto.CreateCompteResponse;
import sn.l3gl.banque.api.dto.SendOtpRequest;
import sn.l3gl.banque.api.dto.SendOtpResponse;
import sn.l3gl.banque.api.helper.CompteHelper;
import sn.l3gl.banque.api.model.Compte;
import sn.l3gl.banque.api.security.JwtService;
import sn.l3gl.banque.api.service.CompteService;
import sn.l3gl.banque.api.service.OtpService;

import java.util.Optional;

@Tag(name = "Authentification & OTP", description = "Endpoints d'inscription, d'OTP et de connexion JWT")
@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired
    private AuthenticationManager authenticationManager;

    @Autowired
    private JwtService jwtService;

    @Autowired
    private OtpService otpService;

    @Autowired
    private CompteHelper compteHelper;

    @Autowired
    private CompteService compteService;

    @Operation(summary = "Demander un code OTP", description = "Génère un code OTP simulé pour la validation du numéro de téléphone lors de l'inscription")
    @PostMapping("/otp/send")
    public ResponseEntity<SendOtpResponse> sendOtp(@Valid @RequestBody SendOtpRequest request) {
        String otp = otpService.generateOtp(request.getTelephone());
        return ResponseEntity.ok(new SendOtpResponse("Code OTP généré avec succès (valide 5 minutes)", request.getTelephone().trim(), otp));
    }

    @Operation(summary = "Inscription avec validation OTP et PIN", description = "Valide le code OTP, enregistre le compte avec son PIN haché en BCrypt et renvoie le token JWT")
    @PostMapping("/register")
    public ResponseEntity<CreateCompteResponse> register(@Valid @RequestBody CreateCompteRequest request) {
        CreateCompteResponse response = compteHelper.saveCompte(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @Operation(summary = "Connexion utilisateur / client", description = "Authentifie l'utilisateur via son téléphone et son code PIN (ou identifiants) et retourne un token JWT")
    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody AuthRequest request) {
        String identifier = request.resolveIdentifier();
        String secret = request.resolveSecret();

        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(identifier, secret)
        );

        UserDetails userDetails = (UserDetails) authentication.getPrincipal();
        String token = jwtService.generateToken(userDetails);

        String telephone = userDetails.getUsername();
        String numeroCompte = null;
        Optional<Compte> compteOpt = compteService.findByTelephone(telephone);
        if (compteOpt.isPresent()) {
            numeroCompte = compteOpt.get().getNumero();
        }

        return ResponseEntity.ok(new AuthResponse(token, "Bearer", telephone, numeroCompte));
    }
}

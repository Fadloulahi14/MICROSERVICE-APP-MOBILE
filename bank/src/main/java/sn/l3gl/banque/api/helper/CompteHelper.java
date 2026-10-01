package sn.l3gl.banque.api.helper;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import sn.l3gl.banque.api.dto.CompteResponse;
import sn.l3gl.banque.api.dto.CreateCompteRequest;
import sn.l3gl.banque.api.dto.CreateCompteResponse;
import sn.l3gl.banque.api.dto.CreateTransactionRequest;
import sn.l3gl.banque.api.dto.PaiementPrestationRequest;
import sn.l3gl.banque.api.dto.TransactionResponse;
import sn.l3gl.banque.api.exception.BadRequestException;
import sn.l3gl.banque.api.exception.ResourceNotFoundException;
import sn.l3gl.banque.api.mapper.CompteMapper;
import sn.l3gl.banque.api.mapper.TransactionMapper;
import sn.l3gl.banque.api.model.Compte;
import sn.l3gl.banque.api.model.Transaction;
import sn.l3gl.banque.api.model.TypeTransaction;
import sn.l3gl.banque.api.security.AppUserDetailsService;
import sn.l3gl.banque.api.security.JwtService;
import sn.l3gl.banque.api.service.CompteService;
import sn.l3gl.banque.api.service.OtpService;
import sn.l3gl.banque.api.service.TransactionService;
import sn.l3gl.banque.api.service.TypeService;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.concurrent.ThreadLocalRandom;

@Component
public class CompteHelper {
    private static final long MIN_DEPOT = 100L;
    private static final long MIN_SOLDE_APRES_RETRAIT = 0L;

    @Autowired
    private CompteService compteService;

    @Autowired
    private TransactionService transactionService;

    @Autowired
    private TypeService typeService;

    @Autowired
    private OtpService otpService;

    @Autowired
    @Lazy
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtService jwtService;

    @Autowired
    @Lazy
    private AppUserDetailsService appUserDetailsService;

    @Autowired
    private CompteMapper compteMapper;

    @Autowired
    private TransactionMapper transactionMapper;

    public CreateCompteResponse saveCompte(CreateCompteRequest request) {
        String telephone = request.getTelephone().trim();

        // 1. Validation de l'OTP
        if (!otpService.validateOtp(telephone, request.getOtp())) {
            throw new BadRequestException("Code OTP invalide ou expiré pour le numéro " + telephone);
        }

        // 2. Unicité du téléphone
        if (compteService.findByTelephone(telephone).isPresent()) {
            throw new BadRequestException("Ce numéro de téléphone existe déjà");
        }

        String numeroCompte = resolveNumeroCompte();

        Compte compte = compteMapper.toEntity(request);
        compte.setNumero(numeroCompte);
        compte.setTelephone(telephone);
        compte.setPin(passwordEncoder.encode(request.getPin().trim()));
        compte = compteService.save(compte);

        if (request.getSolde() > 0) {
            Transaction transaction = transactionMapper.toInitialCreditTransaction(compte, request.getSolde());
            TypeTransaction typeTransactionDepot = typeService.findByLibelle("DEPOT")
                    .orElseThrow(() -> new ResourceNotFoundException("Type DEPOT non trouvé"));
            transaction.setTypeTransaction(typeTransactionDepot);
            transactionService.save(transaction);
        }

        // Génération du token JWT pour l'utilisateur
        UserDetails userDetails = appUserDetailsService.loadUserByUsername(compte.getTelephone());
        String token = jwtService.generateToken(userDetails);

        return new CreateCompteResponse("Compte créé avec succès", compte.getNumero(), compte.getTelephone(), token);
    }

    public CompteResponse getCompteByNumeroOrTelephone(String numeroOrTelephone) {
        Compte compte = compteService.findByNumeroOrTelephone(numeroOrTelephone)
                .orElseThrow(() -> new ResourceNotFoundException("Compte non trouvé"));
        return compteMapper.toResponse(compte);
    }

    public CompteResponse getCompteByTelephone(String telephone) {
        Compte compte = compteService.findByTelephone(telephone)
                .orElseThrow(() -> new ResourceNotFoundException("Compte non trouvé"));
        return compteMapper.toResponse(compte);
    }

    public TransactionResponse createTransaction(String numeroCompte, CreateTransactionRequest request) {
        Compte compte = compteService.findByNumero(numeroCompte)
                .orElseThrow(() -> new ResourceNotFoundException("Compte non trouvé"));

        String normalizedType = normalizeType(request.getType());
        long montant = request.getMontant();

        if ("DEPOT".equals(normalizedType)) {
            if (montant < MIN_DEPOT) {
                throw new BadRequestException("Le dépôt minimum est de " + MIN_DEPOT);
            }
            long nouveauSolde = compte.getSolde() + montant;
            return finalizeTransaction(compte, normalizedType, montant, nouveauSolde);
        } else {
            // RETRAIT : vérification du PIN et du solde
            if (request.getPin() == null || request.getPin().isBlank()) {
                throw new BadRequestException("Le code PIN est obligatoire pour effectuer un retrait");
            }
            if (!passwordEncoder.matches(request.getPin().trim(), compte.getPin())) {
                throw new BadRequestException("Code PIN invalide");
            }

            if (compte.getSolde() - montant < MIN_SOLDE_APRES_RETRAIT) {
                throw new BadRequestException("Solde insuffisant pour effectuer le retrait");
            }
            long nouveauSolde = compte.getSolde() - montant;
            return finalizeTransaction(compte, normalizedType, montant, nouveauSolde);
        }
    }

    public TransactionResponse paiementPrestationAgent(PaiementPrestationRequest request) {
        String telephone = request.getTelephoneClient().trim();
        Compte compte = compteService.findByTelephone(telephone)
                .orElseThrow(() -> new ResourceNotFoundException("Compte non trouvé pour ce téléphone : " + telephone));

        if (request.getPin() == null || request.getPin().isBlank()) {
            throw new BadRequestException("Le code PIN est obligatoire pour valider le paiement");
        }

        if (!passwordEncoder.matches(request.getPin().trim(), compte.getPin())) {
            throw new BadRequestException("Code PIN invalide");
        }

        long montant = toMontantEntier(request.getMontant());

        if (compte.getSolde() - montant < MIN_SOLDE_APRES_RETRAIT) {
            throw new BadRequestException("Solde insuffisant pour effectuer le paiement de la prestation");
        }
        long nouveauSolde = compte.getSolde() - montant;

        String typeLibelle = typeService.findByLibelle("PAIEMENT").isPresent() ? "PAIEMENT" : "RETRAIT";
        return finalizeTransaction(compte, typeLibelle, montant, nouveauSolde);
    }

    private TransactionResponse finalizeTransaction(Compte compte, String normalizedType, long montant, long nouveauSolde) {
        compte.setSolde(nouveauSolde);
        compteService.save(compte);

        TypeTransaction typeTransaction = typeService.findByLibelle(normalizedType)
                .or(() -> typeService.findByLibelle("RETRAIT"))
                .orElseThrow(() -> new ResourceNotFoundException("Type de transaction non trouvé : " + normalizedType));

        Transaction transaction = transactionMapper.toTransaction(compte, montant);
        transaction.setTypeTransaction(typeTransaction);
        transactionService.save(transaction);

        return new TransactionResponse(
                compte.getNumero(),
                normalizedType,
                montant,
                nouveauSolde,
                transaction.getDate()
        );
    }

    private static long toMontantEntier(BigDecimal montant) {
        try {
            return montant.setScale(0, RoundingMode.UNNECESSARY).longValueExact();
        } catch (ArithmeticException e) {
            throw new BadRequestException("Le montant doit être un nombre entier (ex: 12000 ou 12000.00)");
        }
    }

    private String normalizeType(String rawType) {
        if (rawType == null || rawType.isBlank()) {
            throw new BadRequestException("Type de transaction invalide");
        }

        String value = rawType.trim().toUpperCase();

        if (!"DEPOT".equals(value) && !"RETRAIT".equals(value)) {
            throw new BadRequestException("Type de transaction invalide. Utiliser DEPOT ou RETRAIT");
        }

        return value;
    }

    private String resolveNumeroCompte() {
        String generatedNumero;
        do {
            generatedNumero = "CP-" + ThreadLocalRandom.current().nextInt(100000, 999999);
        } while (compteService.findByNumero(generatedNumero).isPresent());
        return generatedNumero;
    }
}

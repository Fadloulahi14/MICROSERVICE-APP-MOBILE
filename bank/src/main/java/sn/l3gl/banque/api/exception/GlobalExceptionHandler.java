package sn.l3gl.banque.api.exception;

import org.springframework.dao.DataAccessException;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.AuthenticationException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.HashMap;
import java.util.Map;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<Map<String, String>> handleNotFound(ResourceNotFoundException ex) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error(ex.getMessage()));
    }

    @ExceptionHandler(BadRequestException.class)
    public ResponseEntity<Map<String, String>> handleBadRequest(BadRequestException ex) {
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error(ex.getMessage()));
    }

    @ExceptionHandler(AuthenticationException.class)
    public ResponseEntity<Map<String, String>> handleAuthentication(AuthenticationException ex) {
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(error("Identifiants ou code PIN incorrects"));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String, String>> handleValidation(MethodArgumentNotValidException ex) {
        String message = ex.getBindingResult().getFieldErrors().stream()
                .findFirst()
                .map(fieldError -> fieldError.getDefaultMessage())
                .orElse("Requete invalide");
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error(message));
    }

    @ExceptionHandler(DataIntegrityViolationException.class)
    public ResponseEntity<Map<String, String>> handleDataIntegrityViolation(DataIntegrityViolationException ex) {
        String rawMessage = ex.getMostSpecificCause() != null
                ? ex.getMostSpecificCause().getMessage()
                : ex.getMessage();
        String message = toBusinessMessage(rawMessage);
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error(message));
    }

    @ExceptionHandler(DataAccessException.class)
    public ResponseEntity<Map<String, String>> handleDataAccess(DataAccessException ex) {
        String rawMessage = ex.getMostSpecificCause() != null
                ? ex.getMostSpecificCause().getMessage()
                : ex.getMessage();
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error(toBusinessMessage(rawMessage)));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<Map<String, String>> handleUnexpectedException(Exception ex) {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(error("Une erreur interne est survenue"));
    }

    private String toBusinessMessage(String rawMessage) {
        if (rawMessage == null) {
            return "Donnees invalides";
        }

        String message = rawMessage.toLowerCase();
        if (message.contains("num_piece")) {
            return "Ce numero de piece existe deja";
        }
        if (message.contains("telephone")) {
            return "Ce numero de telephone existe deja";
        }
        if (message.contains("numero")) {
            return "Ce numero de compte existe deja";
        }
        if (message.contains("not-null") || message.contains("null value")) {
            return "Des champs obligatoires sont manquants";
        }
        if (message.contains("relation") && message.contains("does not exist")) {
            return "Erreur de base de donnees: table manquante. Redemarrer l'application";
        }
        return "Donnees invalides: contrainte base de donnees violee";
    }

    private Map<String, String> error(String message) {
        Map<String, String> payload = new HashMap<>();
        payload.put("message", message);
        return payload;
    }
}

package sn.l3gl.banque.api.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ThreadLocalRandom;

@Service
public class OtpService {

    private static final Logger log = LoggerFactory.getLogger(OtpService.class);
    private static final long OTP_VALIDITY_SECONDS = 300L; // 5 minutes

    private static class OtpEntry {
        final String code;
        final Instant expiresAt;

        OtpEntry(String code, Instant expiresAt) {
            this.code = code;
            this.expiresAt = expiresAt;
        }

        boolean isExpired() {
            return Instant.now().isAfter(expiresAt);
        }
    }

    private final Map<String, OtpEntry> otpStorage = new ConcurrentHashMap<>();

    public String generateOtp(String rawTelephone) {
        String telephone = normalizeTelephone(rawTelephone);
        String code = String.format("%06d", ThreadLocalRandom.current().nextInt(0, 1000000));
        Instant expiresAt = Instant.now().plusSeconds(OTP_VALIDITY_SECONDS);
        otpStorage.put(telephone, new OtpEntry(code, expiresAt));
        log.info("[OTP SIMULATION] Code OTP généré pour {}: {}", telephone, code);
        return code;
    }

    public boolean validateOtp(String rawTelephone, String code) {
        if (rawTelephone == null || code == null) {
            return false;
        }
        String telephone = normalizeTelephone(rawTelephone);
        OtpEntry entry = otpStorage.get(telephone);
        if (entry == null) {
            return false;
        }
        if (entry.isExpired()) {
            otpStorage.remove(telephone);
            return false;
        }
        boolean isValid = entry.code.equals(code.trim());
        if (isValid) {
            otpStorage.remove(telephone); // Utilisation unique
        }
        return isValid;
    }

    private String normalizeTelephone(String rawTelephone) {
        return rawTelephone.trim().replaceAll("\\s+", "");
    }
}

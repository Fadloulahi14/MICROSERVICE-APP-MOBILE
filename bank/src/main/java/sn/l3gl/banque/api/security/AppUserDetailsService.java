package sn.l3gl.banque.api.security;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import sn.l3gl.banque.api.model.Compte;
import sn.l3gl.banque.api.service.CompteService;

import java.util.Optional;

@Service
public class AppUserDetailsService implements UserDetailsService {

    @Autowired
    @Lazy
    private CompteService compteService;

    @Autowired
    private SecurityUsersConfig securityUsersConfig;

    @Autowired
    @Lazy
    private PasswordEncoder passwordEncoder;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        if (username == null || username.isBlank()) {
            throw new UsernameNotFoundException("Identifiant vide");
        }

        String normalizedIdentifier = username.trim();

        // 1. Recherche par numéro de téléphone dans les comptes bancaires
        Optional<Compte> compteOpt = compteService.findByTelephone(normalizedIdentifier);
        if (compteOpt.isPresent()) {
            Compte compte = compteOpt.get();
            return User.builder()
                    .username(compte.getTelephone())
                    .password(compte.getPin())
                    .roles("USER")
                    .build();
        }

        // 2. Recherche par nom d'utilisateur dans la config statique (agents, admins)
        if (securityUsersConfig.getUsers() != null) {
            Optional<SecurityUser> secUserOpt = securityUsersConfig.getUsers()
                    .stream()
                    .filter(u -> u.getName().equalsIgnoreCase(normalizedIdentifier))
                    .findFirst();

            if (secUserOpt.isPresent()) {
                SecurityUser user = secUserOpt.get();
                String pwd = user.getPassword();
                if (pwd != null && !pwd.startsWith("$2a$") && !pwd.startsWith("$2b$") && !pwd.startsWith("$2y$")) {
                    pwd = passwordEncoder.encode(pwd);
                }
                return User.builder()
                        .username(user.getName())
                        .password(pwd)
                        .roles(user.getRoles())
                        .build();
            }
        }

        throw new UsernameNotFoundException("Utilisateur non trouvé avec l'identifiant : " + username);
    }
}

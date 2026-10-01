package sn.l3gl.banque.api.security;

import jakarta.annotation.PostConstruct;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;


@Getter
@Setter
@Configuration
@ConfigurationProperties(prefix = "security")
public class SecurityUsersConfig {

    private List<SecurityUser> users;
}

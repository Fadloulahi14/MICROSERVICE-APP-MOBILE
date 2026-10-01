package sn.l3gl.banque.api;


import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.EnableConfigurationProperties;

import sn.l3gl.banque.api.security.SecurityUsersConfig;

@SpringBootApplication
@EnableConfigurationProperties(SecurityUsersConfig.class)
public class Application {

	public static void main(String[] args) {
		SpringApplication.run(Application.class, args);
	}
}

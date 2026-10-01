package com.service.service.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
public class SecurityConfiguration {

	@Bean
	SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
		return http.csrf(csrf -> csrf.disable())
				.authorizeHttpRequests(auth -> auth.requestMatchers(
								"/api/**",
								"/swagger-ui.html",
								"/swagger-ui/**",
								"/v3/api-docs",
								"/v3/api-docs/**",
								"/h2-console/**")
						.permitAll()
						.anyRequest()
						.authenticated())
				.headers(headers -> headers.frameOptions(frame -> frame.sameOrigin()))
				.build();
	}
}

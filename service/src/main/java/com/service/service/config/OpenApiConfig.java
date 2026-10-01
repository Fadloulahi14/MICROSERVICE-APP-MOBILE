package com.service.service.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.servers.Server;
import java.util.List;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {

	@Bean
	OpenAPI serviceOpenAPI(
			@Value("${server.port:8080}") String serverPort,
			@Value("${spring.application.name:service}") String applicationName) {
		String localUrl = "http://localhost:" + serverPort;
		return new OpenAPI()
				.info(new Info()
						.title("API « " + applicationName + " »")
						.description(
								"Catalogue des services et prestations (liaison many-to-many). "
										+ "Documentation interactive via Swagger UI.")
						.version("1.0.0")
						.contact(new Contact().name("Équipe").email("support@example.com"))
						.license(new License().name("Propriétaire").url("https://example.com")))
				.servers(List.of(new Server().url(localUrl).description("Instance locale")));
	}
}

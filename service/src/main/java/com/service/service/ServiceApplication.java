package com.service.service;

import io.github.cdimascio.dotenv.Dotenv;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class ServiceApplication {

	public static void main(String[] args) {
		Dotenv dotenv = Dotenv.configure().ignoreIfMissing().load();
		dotenv
				.entries()
				.forEach(entry -> {
					String key = entry.getKey();
					if (System.getenv(key) == null && System.getProperty(key) == null) {
						System.setProperty(key, entry.getValue());
					}
				});
		SpringApplication.run(ServiceApplication.class, args);
	}
}

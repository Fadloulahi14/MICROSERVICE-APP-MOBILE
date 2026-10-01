package com.service.service.config;

import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestTemplate;

@Configuration
@EnableConfigurationProperties(PaymentProperties.class)
public class PaymentClientConfig {

	@Bean
	@Qualifier("paymentRestTemplate")
	RestTemplate paymentRestTemplate() {
		return new RestTemplate();
	}
}

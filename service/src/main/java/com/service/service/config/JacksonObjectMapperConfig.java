package com.service.service.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class JacksonObjectMapperConfig {

	@Bean
	ObjectMapper objectMapper() {
		ObjectMapper mapper = new ObjectMapper();
		mapper.findAndRegisterModules();
		return mapper;
	}
}

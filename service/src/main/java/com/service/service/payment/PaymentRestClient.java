package com.service.service.payment;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.service.service.config.PaymentProperties;
import com.service.service.exception.PaymentBusinessException;
import com.service.service.web.dto.PaymentInitResponse;
import com.service.service.web.dto.TransactionResponse;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;
import org.springframework.web.client.HttpStatusCodeException;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

@Component
public class PaymentRestClient {

	private final RestTemplate restTemplate;
	private final PaymentProperties paymentProperties;
	private final ObjectMapper objectMapper;
	private volatile String cachedBearerToken;

	public PaymentRestClient(
			@Qualifier("paymentRestTemplate") RestTemplate restTemplate,
			PaymentProperties paymentProperties,
			ObjectMapper objectMapper) {
		this.restTemplate = restTemplate;
		this.paymentProperties = paymentProperties;
		this.objectMapper = objectMapper;
	}

	public PaymentInitResponse initiatePayment(String paymentRequestJson) {
		String idempotencyKey = UUID.randomUUID().toString();
		if (hasAuthCredentials() && (cachedBearerToken == null || cachedBearerToken.isBlank())) {
			cachedBearerToken = loginAndExtractToken();
		}
		return postPaymentWithOptionalAuthRetry(paymentRequestJson, idempotencyKey, cachedBearerToken, true);
	}

	private boolean hasAuthCredentials() {
		return paymentProperties.getAuth().getUsername() != null
				&& !paymentProperties.getAuth().getUsername().isBlank()
				&& paymentProperties.getAuth().getPassword() != null
				&& !paymentProperties.getAuth().getPassword().isBlank();
	}

	private PaymentInitResponse postPaymentWithOptionalAuthRetry(
			String jsonBody, String idempotencyKey, String bearerToken, boolean allowLogin) {
		ResponseEntity<String> response = postJson(paymentProperties.getPaths().getInit(), jsonBody, idempotencyKey, bearerToken);
		int code = response.getStatusCode().value();
		if (response.getStatusCode().is2xxSuccessful()) {
			return buildSuccessResponse(code, response.getBody());
		}
		if (requiresAuth(response.getStatusCode()) && allowLogin) {
			cachedBearerToken = loginAndExtractToken();
			return postPaymentWithOptionalAuthRetry(jsonBody, idempotencyKey, cachedBearerToken, false);
		}
		throw new PaymentBusinessException(code, extractMessage(response.getBody()));
	}

	private PaymentInitResponse buildSuccessResponse(int httpStatus, String body) {
		String raw = body != null ? body : "";
		TransactionResponse transaction = null;
		if (!raw.isBlank()) {
			try {
				transaction = objectMapper.readValue(raw, TransactionResponse.class);
			} catch (Exception ignored) {
				// corps conservé dans corpsBrut
			}
		}
		return new PaymentInitResponse(httpStatus, transaction, raw);
	}

	private String extractMessage(String body) {
		if (body == null || body.isBlank()) {
			return "Erreur du service de paiement";
		}
		try {
			JsonNode root = objectMapper.readTree(body);
			JsonNode message = root.get("message");
			if (message != null && !message.isNull() && !message.asText().isBlank()) {
				return message.asText();
			}
		} catch (Exception ignored) {
			// ignore
		}
		return body;
	}

	private static boolean requiresAuth(HttpStatusCode status) {
		return status.value() == 401 || status.value() == 403;
	}

	private String loginAndExtractToken() {
		if (!hasAuthCredentials()) {
			throw new PaymentBusinessException(
					401,
					"Identifiants distants manquants : définissez PAYMENT_AUTH_USERNAME et PAYMENT_AUTH_PASSWORD dans .env");
		}
		Map<String, String> body = new HashMap<>();
		body.put("username", paymentProperties.getAuth().getUsername());
		body.put("password", paymentProperties.getAuth().getPassword());
		try {
			String json = objectMapper.writeValueAsString(body);
			ResponseEntity<String> response =
					postJson(paymentProperties.getPaths().getLogin(), json, UUID.randomUUID().toString(), null);
			if (!response.getStatusCode().is2xxSuccessful()) {
				throw new PaymentBusinessException(
						response.getStatusCode().value(), extractMessage(response.getBody()));
			}
			JsonNode root = objectMapper.readTree(response.getBody());
			JsonNode token = root.get("token");
			if (token == null || token.isNull() || token.asText().isBlank()) {
				throw new PaymentBusinessException(
						response.getStatusCode().value(), "Réponse login sans champ « token »");
			}
			return token.asText();
		} catch (PaymentBusinessException ex) {
			throw ex;
		} catch (Exception ex) {
			throw new PaymentBusinessException(502, "Login impossible: " + ex.getMessage());
		}
	}

	private ResponseEntity<String> postJson(String path, String jsonBody, String idempotencyKey, String bearerToken) {
		HttpHeaders headers = new HttpHeaders();
		headers.setContentType(MediaType.APPLICATION_JSON);
		headers.setAccept(List.of(MediaType.APPLICATION_JSON));
		headers.add("Idempotency-Key", idempotencyKey);
		if (bearerToken != null && !bearerToken.isBlank()) {
			headers.setBearerAuth(bearerToken);
		}
		String url = buildAbsoluteUrl(path);
		HttpEntity<String> entity = new HttpEntity<>(jsonBody, headers);
		try {
			return restTemplate.exchange(url, HttpMethod.POST, entity, String.class);
		} catch (HttpStatusCodeException ex) {
			String responseBody = ex.getResponseBodyAsString(StandardCharsets.UTF_8);
			return ResponseEntity.status(ex.getStatusCode()).body(responseBody);
		} catch (RestClientException ex) {
			throw new PaymentBusinessException(502, "Service de paiement injoignable: " + ex.getMessage());
		}
	}

	private String buildAbsoluteUrl(String path) {
		String base = paymentProperties.getBaseUrl().replaceAll("/+$", "");
		String suffix = path.startsWith("/") ? path : "/" + path;
		return base + suffix;
	}
}

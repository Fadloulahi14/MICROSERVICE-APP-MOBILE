package com.service.service;

import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.service.service.payment.PaymentRestClient;
import com.service.service.web.dto.PaymentInitResponse;
import com.service.service.web.dto.TransactionResponse;
import java.time.LocalDate;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

@SpringBootTest
@AutoConfigureMockMvc
class PrestationManyToManyIntegrationTest {

	@Autowired
	private MockMvc mockMvc;

	@Autowired
	private ObjectMapper objectMapper;

	@MockitoBean
	private PaymentRestClient paymentRestClient;

	@BeforeEach
	void stubPaiementDistant() throws Exception {
		TransactionResponse tx =
				new TransactionResponse("CP-TEST", "RETRAIT", 12000L, 138000L, LocalDate.of(2026, 5, 13));
		String raw = objectMapper.writeValueAsString(tx);
		when(paymentRestClient.initiatePayment(anyString())).thenReturn(new PaymentInitResponse(200, tx, raw));
	}

	@Test
	void createPrestationLinksSeveralCatalogServicesAndMarksAsPaidWhenPinProvided() throws Exception {
		long s1 = createService("API REST");
		long s2 = createService("Front React");

		String body =
				"""
				{
				  "datedebut": "2026-06-01T09:00:00",
				  "datefin": "2026-08-31T18:00:00",
				  "description": "Livraison plateforme",
				  "prix": 12000.00,
				  "telephone": "+221771234567",
				  "pin": "1234",
				  "serviceIds": [%d, %d]
				}
				"""
						.formatted(s1, s2);

		mockMvc.perform(post("/api/prestations").contentType(MediaType.APPLICATION_JSON).content(body))
				.andExpect(status().isCreated())
				.andExpect(jsonPath("$.services.length()").value(2))
				.andExpect(jsonPath("$.datedebut").exists())
				.andExpect(jsonPath("$.prix").value(12000.00))
				.andExpect(jsonPath("$.telephone").value("+221771234567"))
				.andExpect(jsonPath("$.statut").value("PAYEE"));

		mockMvc.perform(get("/api/prestations"))
				.andExpect(status().isOk())
				.andExpect(jsonPath("$[0].services.length()").value(2));
	}

	@Test
	void createPrestationWithoutPinSetsStatusToEnAttentePaiementAndAllowsLaterPayment() throws Exception {
		long s1 = createService("Audit Sécurité");

		String createBody =
				"""
				{
				  "datedebut": "2026-07-01T09:00:00",
				  "datefin": "2026-07-15T18:00:00",
				  "description": "Audit de code",
				  "prix": 50000.00,
				  "telephone": "+221771000001",
				  "serviceIds": [%d]
				}
				"""
						.formatted(s1);

		MvcResult result = mockMvc.perform(post("/api/prestations").contentType(MediaType.APPLICATION_JSON).content(createBody))
				.andExpect(status().isCreated())
				.andExpect(jsonPath("$.statut").value("EN_ATTENTE_PAIEMENT"))
				.andReturn();

		JsonNode createdJson = objectMapper.readTree(result.getResponse().getContentAsString());
		long prestationId = createdJson.get("id").asLong();

		// Effectuer le règlement avec PIN
		String payBody = "{\"pin\":\"1234\"}";
		mockMvc.perform(post("/api/prestations/" + prestationId + "/paiement")
						.contentType(MediaType.APPLICATION_JSON)
						.content(payBody))
				.andExpect(status().isOk())
				.andExpect(jsonPath("$.statut").value("PAYEE"));
	}

	private long createService(String nom) throws Exception {
		MvcResult r = mockMvc.perform(
						post("/api/services").contentType(MediaType.APPLICATION_JSON).content("{\"nom\":\"" + nom + "\"}"))
				.andExpect(status().isCreated())
				.andReturn();
		JsonNode id = objectMapper.readTree(r.getResponse().getContentAsString()).get("id");
		if (id == null || id.isNull()) {
			throw new IllegalStateException("missing service id");
		}
		return id.asLong();
	}
}

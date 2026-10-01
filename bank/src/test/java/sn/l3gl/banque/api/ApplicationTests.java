package sn.l3gl.banque.api;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
class ApplicationTests {

	@Autowired
	private MockMvc mockMvc;

	private ObjectMapper objectMapper = new ObjectMapper();

	@Test
	void completeUserFlow_Otp_Register_Login_Depot_Retrait_Paiement() throws Exception {
		String telephone = "+221770001122";

		// 1. Demande de code OTP
		MvcResult otpResult = mockMvc.perform(post("/api/auth/otp/send")
						.contentType(MediaType.APPLICATION_JSON)
						.content("{\"telephone\": \"" + telephone + "\"}"))
				.andExpect(status().isOk())
				.andExpect(jsonPath("$.otp").exists())
				.andReturn();

		JsonNode otpJson = objectMapper.readTree(otpResult.getResponse().getContentAsString());
		String otp = otpJson.get("otp").asText();

		// 2. Inscription avec OTP et PIN
		String registerPayload = String.format("""
				{
				  "solde": 20000,
				  "prenom": "Ousmane",
				  "nom": "Diallo",
				  "telephone": "%s",
				  "adresse": "Dakar Plateau",
				  "numPiece": "CNI-998877",
				  "dateNaissance": "1995-05-15",
				  "pin": "5678",
				  "otp": "%s"
				}
				""", telephone, otp);

		MvcResult registerResult = mockMvc.perform(post("/api/auth/register")
						.contentType(MediaType.APPLICATION_JSON)
						.content(registerPayload))
				.andExpect(status().isCreated())
				.andExpect(jsonPath("$.numeroCompte").exists())
				.andExpect(jsonPath("$.token").exists())
				.andReturn();

		JsonNode regJson = objectMapper.readTree(registerResult.getResponse().getContentAsString());
		String numeroCompte = regJson.get("numeroCompte").asText();
		String jwtToken = regJson.get("token").asText();

		// 3. Connexion avec Téléphone et PIN
		String loginPayload = String.format("""
				{
				  "username": "%s",
				  "password": "5678"
				}
				""", telephone);

		mockMvc.perform(post("/api/auth/login")
						.contentType(MediaType.APPLICATION_JSON)
						.content(loginPayload))
				.andExpect(status().isOk())
				.andExpect(jsonPath("$.token").exists())
				.andExpect(jsonPath("$.telephone").value(telephone));

		// 4. Dépôt (sans code PIN)
		String depotPayload = """
				{
				  "type": "DEPOT",
				  "montant": 5000
				}
				""";

		mockMvc.perform(post("/api/comptes/" + numeroCompte + "/transactions")
						.header("Authorization", "Bearer " + jwtToken)
						.contentType(MediaType.APPLICATION_JSON)
						.content(depotPayload))
				.andExpect(status().isOk())
				.andExpect(jsonPath("$.nouveauSolde").value(25000))
				.andExpect(jsonPath("$.type").value("DEPOT"));

		// 5. Retrait avec PIN invalide -> doit échouer (400)
		String badRetraitPayload = """
				{
				  "type": "RETRAIT",
				  "montant": 3000,
				  "pin": "0000"
				}
				""";

		mockMvc.perform(post("/api/comptes/" + numeroCompte + "/transactions")
						.header("Authorization", "Bearer " + jwtToken)
						.contentType(MediaType.APPLICATION_JSON)
						.content(badRetraitPayload))
				.andExpect(status().isBadRequest());

		// 6. Retrait avec PIN valide -> succès (25000 - 5000 = 20000)
		String goodRetraitPayload = """
				{
				  "type": "RETRAIT",
				  "montant": 5000,
				  "pin": "5678"
				}
				""";

		mockMvc.perform(post("/api/comptes/" + numeroCompte + "/transactions")
						.header("Authorization", "Bearer " + jwtToken)
						.contentType(MediaType.APPLICATION_JSON)
						.content(goodRetraitPayload))
				.andExpect(status().isOk())
				.andExpect(jsonPath("$.nouveauSolde").value(20000))
				.andExpect(jsonPath("$.type").value("RETRAIT"));

		// 7. Paiement de prestation depuis l'API Paiement avec PIN (20000 - 8000 = 12000)
		String paiementPayload = String.format("""
				{
				  "telephoneClient": "%s",
				  "montant": 8000,
				  "pin": "5678"
				}
				""", telephone);

		mockMvc.perform(post("/api/paiements/prestation")
						.header("Authorization", "Bearer " + jwtToken)
						.contentType(MediaType.APPLICATION_JSON)
						.content(paiementPayload))
				.andExpect(status().isOk())
				.andExpect(jsonPath("$.nouveauSolde").value(12000));
	}
}

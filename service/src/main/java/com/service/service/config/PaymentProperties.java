package com.service.service.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "payment")
public class PaymentProperties {

	private String baseUrl = "http://localhost:8081";
	private final Auth auth = new Auth();
	private final Paths paths = new Paths();

	public String getBaseUrl() {
		return baseUrl;
	}

	public void setBaseUrl(String baseUrl) {
		this.baseUrl = baseUrl;
	}

	public Auth getAuth() {
		return auth;
	}

	public Paths getPaths() {
		return paths;
	}

	public static class Auth {
		private String username = "";
		private String password = "";

		public String getUsername() {
			return username;
		}

		public void setUsername(String username) {
			this.username = username;
		}

		public String getPassword() {
			return password;
		}

		public void setPassword(String password) {
			this.password = password;
		}
	}

	public static class Paths {
		private String login = "/api/auth/login";
		private String init = "/api/paiements/prestation";

		public String getLogin() {
			return login;
		}

		public void setLogin(String login) {
			this.login = login;
		}

		public String getInit() {
			return init;
		}

		public void setInit(String init) {
			this.init = init;
		}
	}
}

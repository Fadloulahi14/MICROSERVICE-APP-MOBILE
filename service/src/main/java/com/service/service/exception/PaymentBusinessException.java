package com.service.service.exception;

import org.springframework.http.HttpStatus;

public class PaymentBusinessException extends RuntimeException {

	private final int httpStatus;

	public PaymentBusinessException(int httpStatus, String message) {
		super(message != null && !message.isBlank() ? message : "Erreur du service de paiement");
		this.httpStatus = httpStatus;
	}

	public HttpStatus resolveHttpStatus() {
		HttpStatus resolved = HttpStatus.resolve(httpStatus);
		return resolved != null ? resolved : HttpStatus.BAD_GATEWAY;
	}
}

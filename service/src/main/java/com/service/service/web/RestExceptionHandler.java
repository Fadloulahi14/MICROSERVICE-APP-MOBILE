package com.service.service.web;

import com.service.service.exception.BadRequestException;
import com.service.service.exception.NotFoundException;
import com.service.service.exception.PaymentBusinessException;
import java.util.Map;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class RestExceptionHandler {

	private static ResponseEntity<Map<String, String>> messageBody(HttpStatus status, String message) {
		return ResponseEntity.status(status)
				.contentType(MediaType.APPLICATION_JSON)
				.body(Map.of("message", message));
	}

	@ExceptionHandler(NotFoundException.class)
	public ResponseEntity<Map<String, String>> handleNotFound(NotFoundException ex) {
		return messageBody(HttpStatus.NOT_FOUND, ex.getMessage());
	}

	@ExceptionHandler(BadRequestException.class)
	public ResponseEntity<Map<String, String>> handleBadRequest(BadRequestException ex) {
		return messageBody(HttpStatus.BAD_REQUEST, ex.getMessage());
	}

	@ExceptionHandler(PaymentBusinessException.class)
	public ResponseEntity<Map<String, String>> handlePaymentBusiness(PaymentBusinessException ex) {
		return messageBody(ex.resolveHttpStatus(), ex.getMessage());
	}
}

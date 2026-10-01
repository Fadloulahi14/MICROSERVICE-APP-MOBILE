package sn.l3gl.banque.api.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import sn.l3gl.banque.api.model.Transaction;
import sn.l3gl.banque.api.repository.TransactionRepository;

@Service
public class TransactionService {

    @Autowired
    private TransactionRepository transactionRepository;

    public Transaction save(Transaction transaction) {
        return transactionRepository.save(transaction);
    }
}

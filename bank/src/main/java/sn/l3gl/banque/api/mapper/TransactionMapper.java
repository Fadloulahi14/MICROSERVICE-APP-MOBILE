package sn.l3gl.banque.api.mapper;

import org.springframework.stereotype.Component;
import sn.l3gl.banque.api.model.Compte;
import sn.l3gl.banque.api.model.Transaction;

@Component
public class TransactionMapper {

    public Transaction toInitialCreditTransaction(Compte compte, long solde) {
        Transaction transaction = new Transaction();
        transaction.setMontant(String.valueOf(solde));
        transaction.setDate(java.time.LocalDate.now());
        // Type CREDIT will be set in service/helper after fetch
        transaction.setCompte(compte);
        return transaction;
    }

    public Transaction toTransaction(Compte compte, long montant) {
        Transaction transaction = new Transaction();
        transaction.setMontant(String.valueOf(montant));
        transaction.setDate(java.time.LocalDate.now());
        transaction.setCompte(compte);
        return transaction;
    }
}

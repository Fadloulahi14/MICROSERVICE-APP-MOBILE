package sn.l3gl.banque.api.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;

import java.time.LocalDate;
import java.util.Collection;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Compte {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long id;

    //Infos compte
    @Column(unique = true, nullable = false)
    private String numero;

    @Column(nullable = false)
    private long solde;

    @DateTimeFormat(pattern = "yyyy-MM-dd")
    private LocalDate dateCreation;


    //Infos client
    @Column(unique = true, nullable = false)
    private String numPiece;

    @Column(nullable = false)
    private String prenom;

    @Column(nullable = false)
    private String nom;

    private String adresse;

    @DateTimeFormat(pattern = "yyyy-MM-dd")
    private LocalDate dateNaissance;

    @Column(unique = true, nullable = false, length = 20)
    private String telephone;

    @Column(nullable = false)
    private String pin;

    @OneToMany(mappedBy = "compte")
    private Collection<Transaction> transactions;

}

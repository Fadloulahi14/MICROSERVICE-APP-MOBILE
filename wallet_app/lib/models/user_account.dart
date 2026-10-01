class UserAccount {
  final String numero;
  final int solde;
  final String? numPiece;
  final String? prenom;
  final String? nom;
  final String? adresse;
  final String? dateNaissance;
  final String telephone;
  final String? dateCreation;

  UserAccount({
    required this.numero,
    required this.solde,
    this.numPiece,
    this.prenom,
    this.nom,
    this.adresse,
    this.dateNaissance,
    required this.telephone,
    this.dateCreation,
  });

  String get fullName => '${prenom ?? ''} ${nom ?? ''}'.trim().isNotEmpty
      ? '${prenom ?? ''} ${nom ?? ''}'.trim()
      : 'Utilisateur';

  factory UserAccount.fromJson(Map<String, dynamic> json) {
    return UserAccount(
      numero: json['numero'] ?? '',
      solde: (json['solde'] is num) ? (json['solde'] as num).toInt() : 0,
      numPiece: json['numPiece'],
      prenom: json['prenom'],
      nom: json['nom'],
      adresse: json['adresse'],
      dateNaissance: json['dateNaissance'],
      telephone: json['telephone'] ?? '',
      dateCreation: json['dateCreation'],
    );
  }

  Map<String, dynamic> toJson() => {
        'numero': numero,
        'solde': solde,
        'numPiece': numPiece,
        'prenom': prenom,
        'nom': nom,
        'adresse': adresse,
        'dateNaissance': dateNaissance,
        'telephone': telephone,
        'dateCreation': dateCreation,
      };
}

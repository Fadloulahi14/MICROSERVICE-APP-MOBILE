class WalletTransaction {
  final String numeroCompte;
  final String type;
  final int montant;
  final int nouveauSolde;
  final String date;

  WalletTransaction({
    required this.numeroCompte,
    required this.type,
    required this.montant,
    required this.nouveauSolde,
    required this.date,
  });

  bool get isDepot => type.toUpperCase() == 'DEPOT';

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      numeroCompte: json['numeroCompte'] ?? '',
      type: json['type'] ?? 'TRANSACTION',
      montant: (json['montant'] is num) ? (json['montant'] as num).toInt() : 0,
      nouveauSolde: (json['nouveauSolde'] is num) ? (json['nouveauSolde'] as num).toInt() : 0,
      date: json['date'] ?? DateTime.now().toIso8601String().split('T')[0],
    );
  }
}

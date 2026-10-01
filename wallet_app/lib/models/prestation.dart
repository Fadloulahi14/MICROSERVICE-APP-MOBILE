import 'service_item.dart';

class PrestationModel {
  final int id;
  final String dateDebut;
  final String dateFin;
  final String? description;
  final double prix;
  final String telephone;
  final String statut;
  final List<ServiceItem> services;

  PrestationModel({
    required this.id,
    required this.dateDebut,
    required this.dateFin,
    this.description,
    required this.prix,
    required this.telephone,
    required this.statut,
    required this.services,
  });

  bool get isPayee => statut == 'PAYEE';
  bool get isEnAttente => statut == 'EN_ATTENTE_PAIEMENT';

  String get statutLabel {
    switch (statut) {
      case 'PAYEE':
        return 'Payée';
      case 'ECHOUEE':
        return 'Échouée';
      case 'EN_ATTENTE_PAIEMENT':
        return 'À payer';
      default:
        return 'En cours';
    }
  }

  String get periodeLabel =>
      '${_dateEnFrancais(dateDebut)} → ${_dateEnFrancais(dateFin)}';

  static String _dateEnFrancais(String valeur) {
    final date = DateTime.tryParse(valeur);
    if (date == null) return valeur;

    final jour = date.day.toString().padLeft(2, '0');
    final mois = date.month.toString().padLeft(2, '0');
    return '$jour/$mois/${date.year}';
  }

  factory PrestationModel.fromJson(Map<String, dynamic> json) {
    List<ServiceItem> svcList = [];
    if (json['services'] != null && json['services'] is List) {
      svcList = (json['services'] as List)
          .map((item) => ServiceItem.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return PrestationModel(
      id: (json['id'] is num) ? (json['id'] as num).toInt() : 0,
      dateDebut: json['datedebut'] ?? json['dateDebut'] ?? '',
      dateFin: json['datefin'] ?? json['dateFin'] ?? '',
      description: json['description'],
      prix: (json['prix'] is num) ? (json['prix'] as num).toDouble() : 0.0,
      telephone: json['telephone'] ?? '',
      statut: json['statut'] ?? 'EN_ATTENTE_PAIEMENT',
      services: svcList,
    );
  }
}

class ServiceItem {
  final int id;
  final String nom;

  ServiceItem({
    required this.id,
    required this.nom,
  });

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      id: (json['id'] is num) ? (json['id'] as num).toInt() : 0,
      nom: json['nom'] ?? '',
    );
  }
}

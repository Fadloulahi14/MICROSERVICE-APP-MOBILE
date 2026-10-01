import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../models/user_account.dart';
import '../models/transaction.dart';
import '../models/service_item.dart';
import '../models/prestation.dart';

class ApiService {
  static String errorMessage(Object error) {
    if (error is http.ClientException) {
      return 'Serveur indisponible. Réessayez dans un instant.';
    }
    if (error is FormatException) {
      return 'Réponse du serveur invalide.';
    }

    return error.toString().replaceFirst('Exception: ', '');
  }

  // 1. Envoyer OTP
  static Future<Map<String, dynamic>> sendOtp(String telephone) async {
    final url = Uri.parse('${AppConstants.bankBaseUrl}/api/auth/otp/send');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'telephone': telephone}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }
    throw Exception(data['message'] ?? 'Erreur lors de l\'envoi de l\'OTP');
  }

  // 2. Inscription
  static Future<Map<String, dynamic>> register({
    required String telephone,
    required String pin,
    required String otp,
    required String prenom,
    required String nom,
    required String numPiece,
    required String adresse,
    required String dateNaissance,
    int solde = 10000,
  }) async {
    final url = Uri.parse('${AppConstants.bankBaseUrl}/api/auth/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'telephone': telephone,
        'pin': pin,
        'otp': otp,
        'prenom': prenom,
        'nom': nom,
        'numPiece': numPiece,
        'adresse': adresse,
        'dateNaissance': dateNaissance,
        'solde': solde,
      }),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }
    throw Exception(data['message'] ?? 'Erreur lors de l\'inscription');
  }

  // 3. Connexion
  static Future<Map<String, dynamic>> login(
    String identifier,
    String secret,
  ) async {
    final url = Uri.parse('${AppConstants.bankBaseUrl}/api/auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': identifier, 'password': secret}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }
    throw Exception(data['message'] ?? 'Identifiants ou code PIN incorrects');
  }

  // 4. Obtenir Compte
  static Future<UserAccount> getCompte(
    String numeroOrTelephone,
    String token,
  ) async {
    final url = Uri.parse(
      '${AppConstants.bankBaseUrl}/api/comptes/$numeroOrTelephone',
    );
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return UserAccount.fromJson(data);
    }
    throw Exception(data['message'] ?? 'Compte introuvable');
  }

  // 5. Faire une transaction (Dépôt ou Retrait avec PIN)
  static Future<WalletTransaction> createTransaction({
    required String numeroCompte,
    required String type,
    required int montant,
    String? pin,
    required String token,
  }) async {
    final url = Uri.parse(
      '${AppConstants.bankBaseUrl}/api/comptes/$numeroCompte/transactions',
    );
    final Map<String, dynamic> body = {'type': type, 'montant': montant};
    if (pin != null && pin.isNotEmpty) {
      body['pin'] = pin;
    }

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return WalletTransaction.fromJson(data);
    }
    throw Exception(data['message'] ?? 'Échec de la transaction');
  }

  // 6. Catalogue Services
  static Future<List<ServiceItem>> getServices() async {
    final url = Uri.parse('${AppConstants.serviceBaseUrl}/api/services');
    final response = await http.get(url);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final List list = jsonDecode(response.body);
      return list.map((item) => ServiceItem.fromJson(item)).toList();
    }
    return [];
  }

  // 7. Créer service catalogue
  static Future<ServiceItem> createService(String nom) async {
    final url = Uri.parse('${AppConstants.serviceBaseUrl}/api/services');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nom': nom}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ServiceItem.fromJson(data);
    }
    throw Exception(data['message'] ?? 'Erreur création service');
  }

  // 8. Lister prestations
  static Future<List<PrestationModel>> getPrestations() async {
    final url = Uri.parse('${AppConstants.serviceBaseUrl}/api/prestations');
    final response = await http.get(url);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final List list = jsonDecode(response.body);
      return list.map((item) => PrestationModel.fromJson(item)).toList();
    }
    return [];
  }

  // 9. Commander prestation
  static Future<PrestationModel> createPrestation({
    required String dateDebut,
    required String dateFin,
    required String description,
    required double prix,
    required String telephone,
    String? pin,
    required List<int> serviceIds,
  }) async {
    final url = Uri.parse('${AppConstants.serviceBaseUrl}/api/prestations');
    final Map<String, dynamic> body = {
      'datedebut': dateDebut,
      'datefin': dateFin,
      'description': description,
      'prix': prix,
      'telephone': telephone,
      'serviceIds': serviceIds,
    };
    if (pin != null && pin.isNotEmpty) {
      body['pin'] = pin;
    }

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return PrestationModel.fromJson(data);
    }
    throw Exception(
      data['message'] ?? 'Échec lors de la commande de prestation',
    );
  }

  // 10. Régler une prestation avec PIN
  static Future<PrestationModel> payPrestation(int id, String pin) async {
    final url = Uri.parse(
      '${AppConstants.serviceBaseUrl}/api/prestations/$id/paiement',
    );
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'pin': pin}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return PrestationModel.fromJson(data);
    }
    throw Exception(data['message'] ?? 'Échec du paiement de la prestation');
  }
}

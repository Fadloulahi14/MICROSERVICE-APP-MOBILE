import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_account.dart';
import '../models/transaction.dart';
import '../models/prestation.dart';
import '../models/service_item.dart';
import 'api_service.dart';

class AuthState extends ChangeNotifier {
  static final AuthState _instance = AuthState._internal();
  factory AuthState() => _instance;
  AuthState._internal();

  String? _token;
  String? _telephone;
  UserAccount? _account;
  List<WalletTransaction> _transactions = [];
  List<PrestationModel> _prestations = [];
  List<ServiceItem> _servicesList = [];
  bool _isLoading = false;

  String? get token => _token;
  String? get telephone => _telephone;
  UserAccount? get account => _account;
  List<WalletTransaction> get transactions => _transactions;
  List<PrestationModel> get prestations => _prestations;
  List<ServiceItem> get servicesList => _servicesList;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    _telephone = prefs.getString('user_telephone');
    if (_token != null && _telephone != null) {
      await refreshAccount();
      await refreshPrestations();
      await refreshServices();
    }
  }

  void setSession({required String token, required String telephone, UserAccount? account}) async {
    _token = token;
    _telephone = telephone;
    _account = account;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_telephone', telephone);
    notifyListeners();
    await refreshAccount();
    await refreshPrestations();
    await refreshServices();
  }

  Future<void> refreshAccount() async {
    if (_token == null || _telephone == null) return;
    try {
      _account = await ApiService.getCompte(_telephone!, _token!);
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur refresh account: $e');
    }
  }

  Future<void> refreshPrestations() async {
    try {
      _prestations = await ApiService.getPrestations();
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur refresh prestations: $e');
    }
  }

  Future<void> refreshServices() async {
    try {
      _servicesList = await ApiService.getServices();
      // Si catalogue vide, injecter quelques démos
      if (_servicesList.isEmpty) {
        try {
          await ApiService.createService('Développement Web');
          await ApiService.createService('Application Mobile');
          await ApiService.createService('Audit Cybersécurité');
          _servicesList = await ApiService.getServices();
        } catch (_) {}
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur refresh services: $e');
    }
  }

  void addTransaction(WalletTransaction tx) {
    _transactions.insert(0, tx);
    refreshAccount();
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _telephone = null;
    _account = null;
    _transactions.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_telephone');
    notifyListeners();
  }
}

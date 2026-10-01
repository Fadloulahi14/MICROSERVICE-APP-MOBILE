import 'package:flutter/foundation.dart';

class AppConstants {
  // URLs par défaut pour les deux microservices
  // Sur émulateur Android : 10.0.2.2, sur Web/iOS/Desktop : localhost ou 127.0.0.1
  static String get defaultBankUrl {
    if (kIsWeb) return 'http://localhost:8081';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8081';
    }
    return 'http://localhost:8081';
  }

  static String get defaultServiceUrl {
    if (kIsWeb) return 'http://localhost:8082';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8082';
    }
    return 'http://localhost:8082';
  }

  static String bankBaseUrl = defaultBankUrl;
  static String serviceBaseUrl = defaultServiceUrl;

  static const String appName = 'Portefeuille Nikitin';
  static const String appSubtitle = 'Votre argent et vos services, simplement';
}

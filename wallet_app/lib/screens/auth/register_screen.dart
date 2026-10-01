import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../services/auth_state.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../home/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _phoneController = TextEditingController(text: '+22177');
  final _otpController = TextEditingController();
  final _pinController = TextEditingController();
  final _prenomController = TextEditingController(text: 'Amadou');
  final _nomController = TextEditingController(text: 'Ba');
  final _numPieceController = TextEditingController(text: 'CNI-10293847');
  final _adresseController = TextEditingController(text: 'Dakar Almadies');
  final _soldeController = TextEditingController(text: '50000');

  bool _isOtpSent = false;
  String? _simulatedOtp;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _pinController.dispose();
    _prenomController.dispose();
    _nomController.dispose();
    _numPieceController.dispose();
    _adresseController.dispose();
    _soldeController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.length < 8) {
      setState(() => _errorMessage = 'Numéro de téléphone invalide.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await ApiService.sendOtp(phone);
      final otp = res['otp'] ?? '';
      setState(() {
        _isOtpSent = true;
        _simulatedOtp = otp;
        _otpController.text = otp; // Auto-remplissage pour confort de démo
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.surfaceLight,
            content: Text(
              'Code OTP : $otp — valide 5 minutes',
              style: GoogleFonts.outfit(
                color: AppColors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = ApiService.errorMessage(e));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRegister() async {
    if (_pinController.text.trim().length < 4) {
      setState(
        () => _errorMessage = 'Le code PIN doit contenir au moins 4 chiffres.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await ApiService.register(
        telephone: _phoneController.text.trim(),
        pin: _pinController.text.trim(),
        otp: _otpController.text.trim(),
        prenom: _prenomController.text.trim(),
        nom: _nomController.text.trim(),
        numPiece: _numPieceController.text.trim(),
        adresse: _adresseController.text.trim(),
        dateNaissance: '1998-04-12',
        solde: int.tryParse(_soldeController.text.trim()) ?? 20000,
      );

      final token = res['token'] ?? '';
      final telephone = res['telephone'] ?? _phoneController.text.trim();

      AuthState().setSession(token: token, telephone: telephone);

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = ApiService.errorMessage(e));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Créer un compte',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 18,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '1. Vérifiez votre numéro',
                style: GoogleFonts.outfit(
                  color: AppColors.orange,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _phoneController,
                      hintText: 'Téléphone (+221...)',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      onPressed: _isLoading ? null : _handleSendOtp,
                      child: Text(
                        _isOtpSent ? 'Renvoyer' : 'Envoyer le code',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              if (_simulatedOtp != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Code reçu : $_simulatedOtp',
                  style: GoogleFonts.outfit(
                    color: AppColors.success,
                    fontSize: 12,
                  ),
                ),
              ],

              const SizedBox(height: 16),
              CustomTextField(
                controller: _otpController,
                hintText: 'Code OTP à 6 chiffres',
                prefixIcon: Icons.pin_outlined,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 24),
              Text(
                '2. Créez votre code PIN',
                style: GoogleFonts.outfit(
                  color: AppColors.orange,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _pinController,
                hintText: 'Code PIN (4 à 6 chiffres)',
                prefixIcon: Icons.lock_outline,
                isPassword: true,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 24),
              Text(
                '3. Vos informations',
                style: GoogleFonts.outfit(
                  color: AppColors.orange,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _prenomController,
                      hintText: 'Prénom',
                      prefixIcon: Icons.badge_outlined,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomTextField(
                      controller: _nomController,
                      hintText: 'Nom',
                      prefixIcon: Icons.badge_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _numPieceController,
                hintText: 'Numéro de CNI ou passeport',
                prefixIcon: Icons.credit_card_outlined,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _adresseController,
                hintText: 'Adresse',
                prefixIcon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _soldeController,
                hintText: 'Solde initial (minimum 10 000 FCFA)',
                prefixIcon: Icons.account_balance_wallet_outlined,
                keyboardType: TextInputType.number,
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: GoogleFonts.outfit(
                      color: AppColors.error,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 28),
              PrimaryButton(
                text: 'Créer mon compte',
                isLoading: _isLoading,
                onPressed: _handleRegister,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

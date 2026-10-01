import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../services/api_service.dart';
import '../../services/auth_state.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'register_screen.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController(text: '+221771000001');
  final _pinController = TextEditingController(text: '1234');
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final identifier = _phoneController.text.trim();
    final pin = _pinController.text.trim();

    if (identifier.isEmpty || pin.isEmpty) {
      setState(
        () => _errorMessage = 'Saisissez votre numéro et votre code PIN.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.login(identifier, pin);
      final token = response['token'] ?? '';
      final telephone = response['telephone'] ?? identifier;

      AuthState().setSession(token: token, telephone: telephone);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
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

  void _fillDemoUser(String phone, String pin) {
    setState(() {
      _phoneController.text = phone;
      _pinController.text = pin;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Shield Logo
              const AppLogo(size: 84),
              const SizedBox(height: 24),

              // App Name & Tagline
              Text(
                AppConstants.appName,
                style: GoogleFonts.outfit(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                AppConstants.appSubtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 36),

              // Inputs (Telephone & PIN)
              CustomTextField(
                controller: _phoneController,
                hintText: 'Numéro de téléphone',
                prefixIcon: Icons.person_outline_rounded,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _pinController,
                hintText: 'Code PIN',
                prefixIcon: Icons.lock_outline_rounded,
                isPassword: true,
                keyboardType: TextInputType.number,
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: GoogleFonts.outfit(
                            color: AppColors.error,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Primary "Log In" Pill Button
              PrimaryButton(
                text: 'Se connecter',
                isLoading: _isLoading,
                onPressed: _handleLogin,
              ),
              const SizedBox(height: 16),

              // "Sign Up" Button
              SecondaryButton(
                text: 'Créer un compte',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Quick Demo accounts
              Text(
                'COMPTES DE DÉMONSTRATION',
                style: GoogleFonts.outfit(
                  color: AppColors.textTertiary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  ActionChip(
                    backgroundColor: AppColors.surface,
                    side: const BorderSide(color: AppColors.surfaceBorder),
                    label: Text(
                      'Client 1 (+221771000001)',
                      style: GoogleFonts.outfit(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    onPressed: () => _fillDemoUser('+221771000001', '1234'),
                  ),
                  ActionChip(
                    backgroundColor: AppColors.surface,
                    side: const BorderSide(color: AppColors.surfaceBorder),
                    label: Text(
                      'Client 2 (+221771000002)',
                      style: GoogleFonts.outfit(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    onPressed: () => _fillDemoUser('+221771000002', '1234'),
                  ),
                  ActionChip(
                    backgroundColor: AppColors.surface,
                    side: const BorderSide(color: AppColors.surfaceBorder),
                    label: Text(
                      'Agent (agent1)',
                      style: GoogleFonts.outfit(
                        color: AppColors.orange,
                        fontSize: 12,
                      ),
                    ),
                    onPressed: () => _fillDemoUser('agent1', 'agent123'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Forget password link
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Créez un nouveau PIN avec la vérification OTP.',
                      ),
                    ),
                  );
                },
                child: Text(
                  'Code PIN oublié ?',
                  style: GoogleFonts.outfit(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

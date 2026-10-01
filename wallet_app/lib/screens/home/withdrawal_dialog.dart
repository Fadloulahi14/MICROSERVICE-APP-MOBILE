import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../services/auth_state.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class WithdrawalDialog extends StatefulWidget {
  const WithdrawalDialog({super.key});

  @override
  State<WithdrawalDialog> createState() => _WithdrawalDialogState();
}

class _WithdrawalDialogState extends State<WithdrawalDialog> {
  final _amountController = TextEditingController(text: '5000');
  final _pinController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _amountController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _handleWithdrawal() async {
    final amount = int.tryParse(_amountController.text.trim()) ?? 0;
    final pin = _pinController.text.trim();

    if (amount <= 0) {
      setState(() => _errorMessage = 'Montant invalide.');
      return;
    }
    if (pin.isEmpty) {
      setState(() => _errorMessage = 'Saisissez votre code PIN.');
      return;
    }

    final authState = AuthState();
    final accountNumber = authState.account?.numero;
    final token = authState.token;

    if (accountNumber == null || token == null) {
      setState(() => _errorMessage = 'Compte non identifié');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final tx = await ApiService.createTransaction(
        numeroCompte: accountNumber,
        type: 'RETRAIT',
        montant: amount,
        pin: pin,
        token: token,
      );

      authState.addTransaction(tx);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.success,
            content: Text(
              'Retrait réussi. Nouveau solde : ${tx.nouveauSolde} FCFA.',
              style: GoogleFonts.outfit(
                color: Colors.white,
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Faire un retrait',
                  style: GoogleFonts.outfit(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Votre code PIN est requis.',
              style: GoogleFonts.outfit(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),

            CustomTextField(
              controller: _amountController,
              hintText: 'Montant (FCFA)',
              prefixIcon: Icons.money_off_csred_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: _pinController,
              hintText: 'Code PIN',
              prefixIcon: Icons.lock_outline,
              isPassword: true,
              keyboardType: TextInputType.number,
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: GoogleFonts.outfit(color: AppColors.error, fontSize: 12),
              ),
            ],

            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Retirer',
              isLoading: _isLoading,
              onPressed: _handleWithdrawal,
            ),
          ],
        ),
      ),
    );
  }
}

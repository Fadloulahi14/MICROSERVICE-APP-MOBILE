import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../services/auth_state.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class DepositDialog extends StatefulWidget {
  const DepositDialog({super.key});

  @override
  State<DepositDialog> createState() => _DepositDialogState();
}

class _DepositDialogState extends State<DepositDialog> {
  final _amountController = TextEditingController(text: '10000');
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _handleDeposit() async {
    final amount = int.tryParse(_amountController.text.trim()) ?? 0;
    if (amount < 100) {
      setState(() => _errorMessage = 'Le dépôt minimum est de 100 FCFA.');
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
        type: 'DEPOT',
        montant: amount,
        token: token,
      );

      authState.addTransaction(tx);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.success,
            content: Text(
              'Dépôt réussi. Nouveau solde : ${tx.nouveauSolde} FCFA.',
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
                  'Faire un dépôt',
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
              'Ajoutez de l’argent sans code PIN.',
              style: GoogleFonts.outfit(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),

            CustomTextField(
              controller: _amountController,
              hintText: 'Montant (FCFA)',
              prefixIcon: Icons.payments_outlined,
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
              text: 'Déposer',
              isLoading: _isLoading,
              onPressed: _handleDeposit,
            ),
          ],
        ),
      ),
    );
  }
}

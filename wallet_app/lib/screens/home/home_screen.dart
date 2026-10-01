import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../services/auth_state.dart';
import '../../widgets/credit_card_3d.dart';
import '../../widgets/custom_button.dart';
import 'deposit_dialog.dart';
import 'withdrawal_dialog.dart';
import '../services/services_screen.dart';
import '../details/details_screen.dart';
import '../auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _currencyFormat = NumberFormat.currency(
    locale: 'fr_FR',
    symbol: 'FCFA',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    AuthState().refreshAccount();
    AuthState().refreshPrestations();
  }

  void _showDepositDialog() {
    showDialog(context: context, builder: (_) => const DepositDialog());
  }

  void _showWithdrawalDialog() {
    showDialog(context: context, builder: (_) => const WithdrawalDialog());
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthState(),
      builder: (context, _) {
        final authState = AuthState();
        final account = authState.account;
        final solde = account?.solde ?? 10000000;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Navigation Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Hamburger Menu icon
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.surfaceBorder),
                        ),
                        child: IconButton(
                          tooltip: 'Menu',
                          icon: const Icon(
                            Icons.menu_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () => _showSideMenu(context),
                        ),
                      ),

                      // Badge "%58 Easily Manage"
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.surfaceBorder),
                        ),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Portefeuille',
                                  style: GoogleFonts.outfit(
                                    color: AppColors.textSecondary,
                                    fontSize: 9,
                                  ),
                                ),
                                Text(
                                  'Simple et sécurisé',
                                  style: GoogleFonts.outfit(
                                    color: AppColors.textSecondary,
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.orange.withOpacity(0.5),
                                ),
                              ),
                              child: Text(
                                '100 %',
                                style: GoogleFonts.outfit(
                                  color: AppColors.orange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Search icon
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.surfaceBorder),
                        ),
                        child: IconButton(
                          tooltip: 'Actualiser',
                          icon: const Icon(
                            Icons.refresh_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () {
                            AuthState().refreshAccount();
                            AuthState().refreshPrestations();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Hero Header Text
                  Text(
                    'Gérez votre argent\nen toute simplicité',
                    style: GoogleFonts.outfit(
                      color: AppColors.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      height: 1.25,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // 3D Credit Card Interactive Element
                  CreditCard3D(account: account),
                  const SizedBox(height: 28),

                  // Balance Text "$ 2,589" / "10 000 000 FCFA"
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'SOLDE DISPONIBLE',
                          style: GoogleFonts.outfit(
                            color: AppColors.textTertiary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _currencyFormat.format(solde),
                          style: GoogleFonts.outfit(
                            color: AppColors.textPrimary,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),

                  // Action Buttons matching Screen 2
                  Row(
                    children: [
                      // Scan Card / Dépôt (Orange Pill)
                      Expanded(
                        child: PrimaryButton(
                          text: 'Déposer',
                          icon: const Icon(
                            Icons.qr_code_scanner_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          onPressed: _showDepositDialog,
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Demo Site / Retrait (Dark Outline Pill)
                      Expanded(
                        child: SecondaryButton(
                          text: 'Retirer',
                          icon: const Icon(
                            Icons.arrow_downward_rounded,
                            color: AppColors.orange,
                            size: 18,
                          ),
                          onPressed: _showWithdrawalDialog,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Prestations & Details Navigation Cards
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: Column(
                      children: [
                        _buildMenuRow(
                          icon: Icons.design_services_outlined,
                          title: 'Services et prestations',
                          subtitle: 'Consulter, commander et payer',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ServicesScreen(),
                              ),
                            );
                          },
                        ),
                        const Divider(
                          color: AppColors.surfaceBorder,
                          height: 24,
                        ),
                        _buildMenuRow(
                          icon: Icons.insert_chart_outlined_rounded,
                          title: 'Mes dépenses',
                          subtitle: 'Voir le détail et les statistiques',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const DetailsScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Semantics(
      label: '$title. $subtitle',
      button: true,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.orange.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.orange, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.textTertiary,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  void _showSideMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Mon profil',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.phone_android, color: AppColors.orange),
              title: Text(
                AuthState().telephone ?? '',
                style: GoogleFonts.outfit(color: Colors.white),
              ),
              subtitle: Text(
                'Compte : ${AuthState().account?.numero ?? ""}',
                style: GoogleFonts.outfit(color: AppColors.textSecondary),
              ),
            ),
            const Divider(color: AppColors.surfaceBorder),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: Text(
                'Déconnexion',
                style: GoogleFonts.outfit(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                AuthState().logout();
                Navigator.of(ctx).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../services/auth_state.dart';
import '../../models/prestation.dart';
import '../../widgets/stats_chart.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final _currencyFormat = NumberFormat.currency(
    locale: 'fr_FR',
    symbol: 'FCFA',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    AuthState().refreshPrestations();
    AuthState().refreshAccount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 18,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Détails et statistiques',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.orange),
            onPressed: () {
              AuthState().refreshPrestations();
              AuthState().refreshAccount();
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: AuthState(),
        builder: (context, _) {
          final prestations = AuthState().prestations;
          final account = AuthState().account;

          final paid = prestations.where((p) => p.isPayee).toList();
          final pending = prestations.where((p) => p.isEnAttente).toList();
          final failed = prestations
              .where((p) => p.statut == 'ECHOUEE')
              .toList();

          final totalDepense = paid.fold<double>(0.0, (sum, p) => sum + p.prix);

          return RefreshIndicator(
            onRefresh: () async {
              await AuthState().refreshPrestations();
              await AuthState().refreshAccount();
            },
            color: AppColors.orange,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Cards Row
                  _buildSummaryRow(
                    solde: account?.solde.toDouble() ?? 0.0,
                    totalDepense: totalDepense,
                    countPaid: paid.length,
                    countPending: pending.length,
                    countFailed: failed.length,
                  ),
                  const SizedBox(height: 24),

                  // Chart
                  if (paid.isNotEmpty) ...[
                    Text(
                      'Répartition des dépenses',
                      style: GoogleFonts.outfit(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    StatsChart(prestations: paid),
                    const SizedBox(height: 24),
                  ],

                  // Prestations history
                  Text(
                    'Historique des prestations',
                    style: GoogleFonts.outfit(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (prestations.isEmpty)
                    _buildEmptyState()
                  else
                    ...prestations.map((p) => _buildHistoryCard(p)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryRow({
    required double solde,
    required double totalDepense,
    required int countPaid,
    required int countPending,
    required int countFailed,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Solde',
                value: _currencyFormat.format(solde),
                icon: Icons.account_balance_wallet_rounded,
                color: AppColors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Dépenses',
                value: _currencyFormat.format(totalDepense),
                icon: Icons.trending_down_rounded,
                color: AppColors.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Payées',
                value: '$countPaid',
                icon: Icons.check_circle_outline,
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatCard(
                title: 'À payer',
                value: '$countPending',
                icon: Icons.access_time_rounded,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatCard(
                title: 'Échouées',
                value: '$countFailed',
                icon: Icons.cancel_outlined,
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHistoryCard(PrestationModel p) {
    Color statusColor;
    IconData statusIcon;
    switch (p.statut) {
      case 'PAYEE':
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle_outline;
        break;
      case 'ECHOUEE':
        statusColor = AppColors.error;
        statusIcon = Icons.cancel_outlined;
        break;
      default:
        statusColor = AppColors.warning;
        statusIcon = Icons.access_time_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(statusIcon, color: statusColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.description ?? 'Prestation #${p.id}',
                  style: GoogleFonts.outfit(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  p.periodeLabel,
                  style: GoogleFonts.outfit(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                  ),
                ),
                if (p.services.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    p.services.map((s) => s.nom).join(', '),
                    style: GoogleFonts.outfit(
                      color: AppColors.orange,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _currencyFormat.format(p.prix),
            style: GoogleFonts.outfit(
              color: p.isPayee ? AppColors.success : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.bar_chart_rounded,
              color: AppColors.textTertiary,
              size: 56,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune statistique',
              style: GoogleFonts.outfit(
                color: AppColors.textSecondary,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Vos prestations apparaîtront ici.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: AppColors.textTertiary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: GoogleFonts.outfit(
              color: AppColors.textTertiary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

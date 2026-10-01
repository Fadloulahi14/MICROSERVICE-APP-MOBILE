import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../services/auth_state.dart';
import '../../services/api_service.dart';
import '../../models/service_item.dart';
import '../../models/prestation.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    AuthState().refreshServices();
    AuthState().refreshPrestations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          'Services et prestations',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            fontSize: 18,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.orange,
          indicatorWeight: 2.5,
          labelStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          unselectedLabelStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.w400,
            fontSize: 13,
          ),
          labelColor: AppColors.orange,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Services'),
            Tab(text: 'Mes demandes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_CatalogueTab(), _PrestationsTab()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.orange,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'Commander',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: () => _showOrderDialog(context),
      ),
    );
  }

  void _showOrderDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const _OrderPrestationSheet(),
    ).then((_) {
      AuthState().refreshPrestations();
      AuthState().refreshAccount();
    });
  }
}

class _CatalogueTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthState(),
      builder: (context, _) {
        final services = AuthState().servicesList;
        if (services.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.design_services_outlined,
                  color: AppColors.textTertiary,
                  size: 56,
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucun service disponible',
                  style: GoogleFonts.outfit(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => AuthState().refreshServices(),
                  child: Text(
                    'Rafraîchir',
                    style: GoogleFonts.outfit(color: AppColors.orange),
                  ),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: services.length,
          itemBuilder: (ctx, i) => _ServiceCard(service: services[i]),
        );
      },
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ServiceItem service;
  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.orange.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.design_services_rounded,
              color: AppColors.orange,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.nom,
                  style: GoogleFonts.outfit(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Service n° ${service.id}',
                  style: GoogleFonts.outfit(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Disponible',
              style: GoogleFonts.outfit(
                color: AppColors.success,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrestationsTab extends StatelessWidget {
  final _currencyFormat = NumberFormat.currency(
    locale: 'fr_FR',
    symbol: 'FCFA',
    decimalDigits: 0,
  );

  _PrestationsTab();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthState(),
      builder: (context, _) {
        final prestations = AuthState().prestations;
        if (prestations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.receipt_long_outlined,
                  color: AppColors.textTertiary,
                  size: 56,
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucune demande',
                  style: GoogleFonts.outfit(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Créez votre première demande',
                  style: GoogleFonts.outfit(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => AuthState().refreshPrestations(),
          color: AppColors.orange,
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: prestations.length,
            itemBuilder: (ctx, i) => _PrestationCard(
              prestation: prestations[i],
              currencyFormat: _currencyFormat,
            ),
          ),
        );
      },
    );
  }
}

class _PrestationCard extends StatefulWidget {
  final PrestationModel prestation;
  final NumberFormat currencyFormat;
  const _PrestationCard({
    required this.prestation,
    required this.currencyFormat,
  });

  @override
  State<_PrestationCard> createState() => _PrestationCardState();
}

class _PrestationCardState extends State<_PrestationCard> {
  bool _isPaying = false;

  Color get _statusColor {
    switch (widget.prestation.statut) {
      case 'PAYEE':
        return AppColors.success;
      case 'ECHOUEE':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  IconData get _statusIcon {
    switch (widget.prestation.statut) {
      case 'PAYEE':
        return Icons.check_circle_outline;
      case 'ECHOUEE':
        return Icons.cancel_outlined;
      default:
        return Icons.access_time_rounded;
    }
  }

  Future<void> _payNow() async {
    final pinController = TextEditingController();
    final confirmed = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Confirmer le paiement',
          style: GoogleFonts.outfit(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Montant : ${widget.currencyFormat.format(widget.prestation.prix)}',
              style: GoogleFonts.outfit(
                color: AppColors.orange,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              style: GoogleFonts.outfit(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Code PIN',
                hintStyle: GoogleFonts.outfit(color: AppColors.textTertiary),
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: AppColors.orange,
                ),
                filled: true,
                fillColor: AppColors.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                counterText: '',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Annuler',
              style: GoogleFonts.outfit(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, pinController.text.trim()),
            child: Text(
              'Payer',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == null || confirmed.isEmpty) return;

    setState(() => _isPaying = true);
    try {
      await ApiService.payPrestation(widget.prestation.id, confirmed);
      await AuthState().refreshPrestations();
      await AuthState().refreshAccount();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paiement réussi.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ApiService.errorMessage(e)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPaying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.prestation;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  p.description ?? 'Prestation #${p.id}',
                  style: GoogleFonts.outfit(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_statusIcon, color: _statusColor, size: 13),
                    const SizedBox(width: 4),
                    Text(
                      p.statutLabel,
                      style: GoogleFonts.outfit(
                        color: _statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                color: AppColors.textTertiary,
                size: 13,
              ),
              const SizedBox(width: 4),
              Text(
                p.periodeLabel,
                style: GoogleFonts.outfit(
                  color: AppColors.textTertiary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (p.services.isNotEmpty) ...[
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: p.services
                  .map(
                    (s) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.orange.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        s.nom,
                        style: GoogleFonts.outfit(
                          color: AppColors.orange,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 8),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.currencyFormat.format(p.prix),
                style: GoogleFonts.outfit(
                  color: AppColors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              if (p.isEnAttente)
                _isPaying
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.orange,
                        ),
                      )
                    : ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        onPressed: _payNow,
                        icon: const Icon(
                          Icons.payment_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        label: Text(
                          'Payer',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderPrestationSheet extends StatefulWidget {
  const _OrderPrestationSheet();

  @override
  State<_OrderPrestationSheet> createState() => _OrderPrestationSheetState();
}

class _OrderPrestationSheetState extends State<_OrderPrestationSheet> {
  final _descController = TextEditingController();
  final _prixController = TextEditingController(text: '50000');
  final _pinController = TextEditingController();
  DateTime _dateDebut = DateTime.now();
  DateTime _dateFin = DateTime.now().add(const Duration(days: 7));
  final Set<int> _selectedServiceIds = {};
  bool _isLoading = false;
  String? _error;

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _submit() async {
    if (_selectedServiceIds.isEmpty) {
      setState(() => _error = 'Sélectionnez au moins un service.');
      return;
    }
    final prix = double.tryParse(_prixController.text.trim()) ?? 0;
    if (prix <= 0) {
      setState(() => _error = 'Budget invalide.');
      return;
    }
    if (_pinController.text.trim().length < 4) {
      setState(() => _error = 'Saisissez un PIN d’au moins 4 chiffres.');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await ApiService.createPrestation(
        dateDebut: _formatDate(_dateDebut),
        dateFin: _formatDate(_dateFin),
        description: _descController.text.trim().isEmpty
            ? 'Prestation de service'
            : _descController.text.trim(),
        prix: prix,
        telephone: AuthState().telephone ?? '',
        pin: _pinController.text.trim(),
        serviceIds: _selectedServiceIds.toList(),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _error = ApiService.errorMessage(e));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    _prixController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final services = AuthState().servicesList;
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceBorder,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Nouvelle prestation',
              style: GoogleFonts.outfit(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),

            // Services selection
            Text(
              'Services souhaités',
              style: GoogleFonts.outfit(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: services.map((s) {
                final selected = _selectedServiceIds.contains(s.id);
                return FilterChip(
                  label: Text(
                    s.nom,
                    style: GoogleFonts.outfit(
                      color: selected ? Colors.white : AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  selected: selected,
                  selectedColor: AppColors.orange,
                  backgroundColor: AppColors.surfaceLight,
                  checkmarkColor: Colors.white,
                  side: BorderSide(
                    color: selected
                        ? AppColors.orange
                        : AppColors.surfaceBorder,
                  ),
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        _selectedServiceIds.add(s.id);
                      } else {
                        _selectedServiceIds.remove(s.id);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Description
            TextField(
              controller: _descController,
              style: GoogleFonts.outfit(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Votre besoin (facultatif)',
                hintStyle: GoogleFonts.outfit(color: AppColors.textTertiary),
                filled: true,
                fillColor: AppColors.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Prix
            TextField(
              controller: _prixController,
              keyboardType: TextInputType.number,
              style: GoogleFonts.outfit(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Budget (FCFA)',
                hintStyle: GoogleFonts.outfit(color: AppColors.textTertiary),
                prefixIcon: const Icon(
                  Icons.payments_outlined,
                  color: AppColors.orange,
                ),
                filled: true,
                fillColor: AppColors.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // PIN
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              style: GoogleFonts.outfit(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Code PIN pour payer',
                hintStyle: GoogleFonts.outfit(color: AppColors.textTertiary),
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: AppColors.orange,
                ),
                filled: true,
                fillColor: AppColors.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                counterText: '',
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _error!,
                  style: GoogleFonts.outfit(
                    color: AppColors.error,
                    fontSize: 13,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Commander',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

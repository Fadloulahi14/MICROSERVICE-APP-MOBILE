import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../models/user_account.dart';

class CreditCard3D extends StatelessWidget {
  final UserAccount? account;

  const CreditCard3D({super.key, this.account});

  @override
  Widget build(BuildContext context) {
    final String cardNumber = account?.numero.isNotEmpty == true
        ? account!.numero
        : 'CP-DEMO-1000001';
    final String cardHolder = account?.fullName.isNotEmpty == true
        ? account!.fullName
        : 'Mamadou Ndiaye';

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Card shadow layer 1
          Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0018)
              ..rotateZ(-0.24)
              ..rotateX(0.20)
              ..translate(15.0, -10.0, -40.0),
            child: _buildCardBackLayer(opacity: 0.35, scale: 0.92),
          ),

          // Background Card shadow layer 2
          Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0018)
              ..rotateZ(-0.16)
              ..rotateX(0.15)
              ..translate(8.0, -5.0, -20.0),
            child: _buildCardBackLayer(opacity: 0.6, scale: 0.96),
          ),

          // Main Foreground Interactive 3D Card
          Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0018)
              ..rotateZ(-0.08)
              ..rotateX(0.10)
              ..rotateY(-0.05),
            child: _buildMainCard(cardNumber, cardHolder),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBackLayer({required double opacity, required double scale}) {
    return Container(
      width: 260 * scale,
      height: 160 * scale,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight.withOpacity(opacity),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
    );
  }

  Widget _buildMainCard(String cardNumber, String cardHolder) {
    return Container(
      width: 270,
      height: 170,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF222C42), Color(0xFF161D2D), Color(0xFF0F1522)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.55),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: AppColors.orange.withOpacity(0.18),
            blurRadius: 36,
            spreadRadius: -4,
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.2),
      ),
      child: Stack(
        children: [
          // Subtle stylish orange glow inside card
          Positioned(
            right: -30,
            bottom: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.orange.withOpacity(0.35),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Card Elements
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Row: Chip & Contactless
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Gold Chip
                  Container(
                    width: 32,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37),
                      borderRadius: BorderRadius.circular(5),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFDF73), Color(0xFFC59B27)],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Container(
                            width: 24,
                            height: 16,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black26,
                                width: 0.8,
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Contactless & Brand
                  Row(
                    children: [
                      const Icon(
                        Icons.contactless,
                        color: Colors.white70,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'BANQUE 221',
                        style: GoogleFonts.outfit(
                          color: AppColors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Card Number
              Text(
                _formatCardNumber(cardNumber),
                style: GoogleFonts.sourceCodePro(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.2,
                ),
              ),

              // Bottom Row: Holder & Expiry
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TITULAIRE',
                          style: GoogleFonts.outfit(
                            color: AppColors.textTertiary,
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          cardHolder.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'EXPIRE',
                        style: GoogleFonts.outfit(
                          color: AppColors.textTertiary,
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '12/28',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCardNumber(String raw) {
    if (raw.length >= 12) {
      return '${raw.substring(0, 4)}  ${raw.substring(4, 8)}  ${raw.substring(8, 12)}';
    }
    return raw;
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.maxLines = 1,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _obscure = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.surfaceBorder, width: 1),
      ),
      child: TextFormField(
        controller: widget.controller,
        obscureText: widget.isPassword ? _obscure : false,
        keyboardType: widget.keyboardType,
        validator: widget.validator,
        maxLines: widget.maxLines,
        style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 15),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: GoogleFonts.outfit(
            color: AppColors.textTertiary,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            widget.prefixIcon,
            color: AppColors.textSecondary,
            size: 20,
          ),
          suffixIcon: widget.isPassword
              ? IconButton(
                  tooltip: _obscure
                      ? 'Afficher le code PIN'
                      : 'Masquer le code PIN',
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}

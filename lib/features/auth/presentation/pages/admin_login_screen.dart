import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

const _bgDark = Color(0xFF030712);
const _accent1 = Color(0xFF06B6D4);
const _accent2 = Color(0xFF3B82F6);
const _accent3 = Color(0xFF8B5CF6);
const _glassBg = Color(0x12FFFFFF);
const _glassBorder = Color(0x1AFFFFFF);
const _textWhite = Colors.white;
const _textMuted = Color(0x60FFFFFF);

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _adminIdController = TextEditingController();
  final _passwordController = TextEditingController();

  final FocusNode _adminIdFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  @override
  void dispose() {
    _adminIdController.dispose();
    _passwordController.dispose();
    _adminIdFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _handleLogin() {
    context.go('/admin/dashboard');
  }

  Widget _buildLiquidGlass({required Widget child, EdgeInsetsGeometry? padding, double borderRadius = 24}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: _glassBg,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: _glassBorder, width: 0.8),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0AFFFFFF),
                blurRadius: 20,
                spreadRadius: 1,
                blurStyle: BlurStyle.inner,
              ),
              BoxShadow(
                color: Color(0x08FFFFFF),
                offset: Offset(0, 2),
                blurRadius: 12,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: Stack(
        children: [
          _buildBackgroundLayer(),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: 440,
                child: _buildLiquidGlass(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 36),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0x0AFFFFFF),
                          shape: BoxShape.circle,
                          border: Border.all(color: _glassBorder, width: 0.8),
                        ),
                        child: Icon(
                          Icons.admin_panel_settings_outlined,
                          size: 48,
                          color: _accent1,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'ADMINISTRATOR LOGIN',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                          color: _textWhite,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Secure Access Portal',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: _textMuted,
                        ),
                      ),
                      const SizedBox(height: 36),

                      _buildInputField(
                        label: 'Admin ID',
                        icon: Icons.person_outline,
                        controller: _adminIdController,
                        focusNode: _adminIdFocus,
                        onSubmitted: () => _passwordFocus.requestFocus(),
                      ),
                      const SizedBox(height: 18),

                      _buildInputField(
                        label: 'Password',
                        icon: Icons.lock_outline,
                        controller: _passwordController,
                        focusNode: _passwordFocus,
                        isPassword: true,
                        onSubmitted: _handleLogin,
                      ),

                      const SizedBox(height: 32),

                      GestureDetector(
                        onTap: _handleLogin,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [_accent1, _accent2, _accent3],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'LOGIN',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      TextButton(
                        onPressed: () => context.go('/punch'),
                        child: Text(
                          'Back to Punch Portal',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required FocusNode focusNode,
    bool isPassword = false,
    VoidCallback? onSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: const Color(0x80FFFFFF),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          focusNode: focusNode,
          obscureText: isPassword,
          textInputAction: isPassword ? TextInputAction.done : TextInputAction.next,
          onSubmitted: (_) => onSubmitted?.call(),
          style: GoogleFonts.plusJakartaSans(fontSize: 14, color: _textWhite),
          decoration: InputDecoration(
            hintText: isPassword ? '••••••••' : 'Enter Admin ID',
            hintStyle: GoogleFonts.plusJakartaSans(fontSize: 14, color: const Color(0x40FFFFFF)),
            prefixIcon: Icon(icon, color: const Color(0x88FFFFFF), size: 20),
            filled: true,
            fillColor: Colors.white.withOpacity(0.08),        // White background
            contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0x1AFFFFFF), width: 0.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0x1AFFFFFF), width: 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _accent1, width: 1.6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackgroundLayer() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/tech_bg.jpg'),
              fit: BoxFit.cover,
              opacity: 0.35,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.4, 0.7, 1.0],
              colors: [
                Color(0xFF020617).withOpacity(0.88),
                Color(0xFF0F172A).withOpacity(0.78),
                Color(0xFF172554).withOpacity(0.68),
                Color(0xFF020617).withOpacity(0.92),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
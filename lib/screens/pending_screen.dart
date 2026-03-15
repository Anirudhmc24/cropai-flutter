import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class PendingScreen extends StatelessWidget {
  const PendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 88, height: 88,
                decoration: BoxDecoration(
                  color: AppTheme.warning.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hourglass_empty_rounded,
                  size: 44, color: AppTheme.warning),
              ),
              const SizedBox(height: 24),
              Text('Awaiting Approval',
                style: GoogleFonts.dmSans(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                )),
              const SizedBox(height: 12),
              Text(
                'Hello ${user?.name ?? 'Farmer'}, your registration has been submitted. An admin will review and approve your account shortly.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 15, height: 1.6),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  children: [
                    _infoRow('Name',     user?.name     ?? '—'),
                    _infoRow('Phone',    user?.phone    ?? '—'),
                    _infoRow('District', user?.district ?? '—'),
                    _infoRow('Status',   'Pending Review',
                      valueColor: AppTheme.warning),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              TextButton.icon(
                onPressed: () {
                  context.read<AuthProvider>().logout();
                  Navigator.pushReplacement(context,
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen()));
                },
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Sign Out'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {Color? valueColor}) =>
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
            style: const TextStyle(
              color: AppTheme.textMuted, fontSize: 14)),
          Text(value,
            style: TextStyle(
              color:      valueColor ?? AppTheme.textDark,
              fontSize:   14,
              fontWeight: FontWeight.w600,
            )),
        ],
      ),
    );
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import 'admin/admin_screen.dart';
import 'pending_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool  _obscure   = true;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final auth = context.read<AuthProvider>();
    final ok   = await auth.login(
      phone:    _phoneCtrl.text.trim(),
      password: _passCtrl.text,
    );
    if (!mounted) return;
    if (ok) {
      if (auth.isAdmin) {
        Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const AdminScreen()));
      } else if (auth.isApproved) {
        Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const HomeScreen()));
      } else {
        Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const PendingScreen()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top green header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(32, 56, 32, 40),
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.only(
                    bottomLeft:  Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.agriculture,
                        color: Colors.white, size: 32),
                    ),
                    const SizedBox(height: 20),
                    Text('Welcome back',
                      style: GoogleFonts.dmSans(
                        color: Colors.white70, fontSize: 15)),
                    Text('CropAI',
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1,
                      )),
                  ],
                ),
              ),

              // Form
              Padding(
                padding: const EdgeInsets.all(24),
                child: Consumer<AuthProvider>(
                  builder: (ctx, auth, _) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      _label('Phone Number'),
                      const SizedBox(height: 6),
                      TextField(
                        controller:  _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          hintText:    '10-digit mobile number',
                          prefixIcon:  Icon(Icons.phone_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _label('Password'),
                      const SizedBox(height: 6),
                      TextField(
                        controller:  _passCtrl,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          hintText:   'Enter password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                            onPressed: () =>
                              setState(() => _obscure = !_obscure),
                          ),
                        ),
                      ),

                      if (auth.error.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.danger.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppTheme.danger.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                color: AppTheme.danger, size: 18),
                              const SizedBox(width: 8),
                              Text(auth.error,
                                style: const TextStyle(
                                  color: AppTheme.danger, fontSize: 13)),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: auth.loading ? null : _login,
                          child: auth.loading
                            ? const SizedBox(
                                width: 20, height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                            : const Text('Sign In'),
                        ),
                      ),

                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account? ",
                            style: TextStyle(color: AppTheme.textMuted)),
                          GestureDetector(
                            onTap: () => Navigator.push(context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen())),
                            child: Text('Register',
                              style: const TextStyle(
                                color: AppTheme.primaryLight,
                                fontWeight: FontWeight.w600,
                              )),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),
                      
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text,
    style: GoogleFonts.dmSans(
      fontWeight: FontWeight.w600,
      fontSize: 14,
      color: AppTheme.textDark,
    ));
}
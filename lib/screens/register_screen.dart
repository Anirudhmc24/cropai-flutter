import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../providers/crop_provider.dart';
import '../theme/app_theme.dart';
import 'pending_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl    = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _villageCtrl = TextEditingController();
  final _passCtrl    = TextEditingController();
  String? _district;
  bool    _obscure = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
      context.read<CropProvider>().loadDistricts());
  }

  Future<void> _register() async {
    if (_nameCtrl.text.isEmpty || _phoneCtrl.text.isEmpty ||
        _district == null || _passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')));
      return;
    }
    final auth = context.read<AuthProvider>();
    await auth.register(
      name:     _nameCtrl.text.trim(),
      phone:    _phoneCtrl.text.trim(),
      district: _district!,
      village:  _villageCtrl.text.trim(),
      password: _passCtrl.text,
    );
    if (!mounted) return;
    Navigator.pushReplacement(context,
      MaterialPageRoute(builder: (_) => const PendingScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: AppTheme.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Consumer2<AuthProvider, CropProvider>(
          builder: (ctx, auth, crop, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryLight.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                      color: AppTheme.primaryLight, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Your registration will be reviewed by an admin before you can access recommendations.',
                        style: TextStyle(
                          color: AppTheme.primaryLight,
                          fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _label('Full Name'),
              const SizedBox(height: 6),
              TextField(
                controller:  _nameCtrl,
                decoration: const InputDecoration(
                  hintText:   'Your full name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),

              _label('Phone Number'),
              const SizedBox(height: 6),
              TextField(
                controller:   _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText:   '10-digit mobile number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 16),

              _label('District'),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color:        Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value:      _district,
                    hint:       const Text('Select your district'),
                    items:      crop.districts.map((d) =>
                      DropdownMenuItem(value: d, child: Text(d))
                    ).toList(),
                    onChanged: (v) => setState(() => _district = v),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _label('Village / Town'),
              const SizedBox(height: 6),
              TextField(
                controller: _villageCtrl,
                decoration: const InputDecoration(
                  hintText:   'Your village or town name',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 16),

              _label('Password'),
              const SizedBox(height: 6),
              TextField(
                controller:  _passCtrl,
                obscureText: _obscure,
                decoration: InputDecoration(
                  hintText:   'Create a password',
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
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: auth.loading ? null : _register,
                  child: auth.loading
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                    : const Text('Submit Registration'),
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
      fontWeight: FontWeight.w600, fontSize: 14,
      color: AppTheme.textDark));
}
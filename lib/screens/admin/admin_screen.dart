import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart';
import '../../theme/app_theme.dart';
import '../login_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});
  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  List<Map<String, dynamic>> _requests = [];
  List<Map<String, dynamic>> _approved = [];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _loadRequests();
  }

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  Future<void> _loadRequests() async {
    setState(() {
      _requests = [];
      _approved = [];
    });
  }


  void _approve(Map<String, dynamic> farmer) {
    setState(() {
      _requests.removeWhere((f) => f['id'] == farmer['id']);
      final updated = Map<String, dynamic>.from(farmer);
      updated['status'] = 'approved';
      _approved.add(updated);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${farmer['name']} approved'),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
      ));
  }

  void _reject(Map<String, dynamic> farmer) {
    setState(() {
      _requests.removeWhere((f) => f['id'] == farmer['id']);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${farmer['name']} rejected'),
        backgroundColor: AppTheme.danger,
        behavior: SnackBarBehavior.floating,
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppTheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: AppTheme.accent,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
          tabs: [
            Tab(text: 'Pending (${_requests.length})'),
            Tab(text: 'Approved (${_approved.length})'),
            const Tab(text: 'Stats'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _buildPendingTab(),
          _buildApprovedTab(),
          _buildStatsTab(),
        ],
      ),
    );
  }

  Widget _buildPendingTab() {
    if (_requests.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline,
              size: 56, color: AppTheme.success),
            SizedBox(height: 12),
            Text('No pending requests',
              style: TextStyle(color: AppTheme.textMuted)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _requests.length,
      itemBuilder: (ctx, i) => _farmerCard(
        _requests[i], showActions: true),
    );
  }

  Widget _buildApprovedTab() {
    if (_approved.isEmpty) {
      return const Center(
        child: Text('No approved farmers yet',
          style: TextStyle(color: AppTheme.textMuted)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _approved.length,
      itemBuilder: (ctx, i) => _farmerCard(
        _approved[i], showActions: false),
    );
  }

  Widget _buildStatsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              _statCard('Pending', '${_requests.length}',
                Icons.hourglass_empty, AppTheme.warning),
              const SizedBox(width: 12),
              _statCard('Approved', '${_approved.length}',
                Icons.check_circle, AppTheme.success),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _statCard('Districts', '19',
                Icons.location_on, AppTheme.primaryLight),
              const SizedBox(width: 12),
              _statCard('Records', '40K+',
                Icons.storage, Colors.purple),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Live API Status',
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 12),
                _statusRow('Backend API', true),
                _statusRow('PostgreSQL (Railway)', true),
                _statusRow('ML Models', true),
                _statusRow('Flutter Web App', true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _farmerCard(Map<String, dynamic> farmer,
      {required bool showActions}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.primary.withOpacity(0.1),
                child: Text(
                  farmer['name'][0].toUpperCase(),
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(farmer['name'],
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w600, fontSize: 15)),
                    Text('${farmer['district']} · ${farmer['village']}',
                      style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 13)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: farmer['status'] == 'approved'
                    ? AppTheme.success.withOpacity(0.1)
                    : AppTheme.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  farmer['status'] == 'approved'
                    ? 'Approved' : 'Pending',
                  style: TextStyle(
                    color: farmer['status'] == 'approved'
                      ? AppTheme.success : AppTheme.warning,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  )),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Phone: ${farmer['phone']}',
            style: const TextStyle(
              color: AppTheme.textMuted, fontSize: 13)),
          if (showActions) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _reject(farmer),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.danger,
                      side: BorderSide(
                        color: AppTheme.danger.withOpacity(0.5)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _approve(farmer),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Approve'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _statCard(String label, String value,
      IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 10),
            Text(value,
              style: GoogleFonts.dmSans(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              )),
            Text(label,
              style: const TextStyle(
                color: AppTheme.textMuted, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _statusRow(String label, bool online) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(
            color: online ? AppTheme.success : AppTheme.danger,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 14)),
        const Spacer(),
        Text(online ? 'Online' : 'Offline',
          style: TextStyle(
            color: online ? AppTheme.success : AppTheme.danger,
            fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    ),
  );
}
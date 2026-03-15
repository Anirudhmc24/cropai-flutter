import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/crop_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
      context.read<CropProvider>().loadDistricts()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text('CropAI — Smart Farming'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showAbout(context),
          )
        ],
      ),
      body: Consumer<CropProvider>(
        builder: (ctx, provider, _) {
          if (provider.isLoading && provider.districts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error.isNotEmpty && provider.districts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(provider.error,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadDistricts(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildDistrictSelector(provider),
                const SizedBox(height: 16),
                _buildMonthSelector(provider),
                const SizedBox(height: 24),
                _buildGetRecommendationsButton(provider),
                const SizedBox(height: 24),
                _buildQuickStats(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    final now = DateTime.now();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Good day, Farmer!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            )),
          const SizedBox(height: 4),
          Text(
            DateFormat('EEEE, d MMMM yyyy').format(now),
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 12),
          const Text(
            'Select your district and month to get AI-powered crop recommendations based on 15 years of market data.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildDistrictSelector(CropProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Your District',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded:  true,
              value:       provider.selectedDistrict.isEmpty
                               ? null
                               : provider.selectedDistrict,
              hint:        const Text('Select district'),
              items:       provider.districts.map((d) =>
                DropdownMenuItem(value: d, child: Text(d))
              ).toList(),
              onChanged: (val) {
                if (val != null) provider.setDistrict(val);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthSelector(CropProvider provider) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Planting Month',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount:       12,
            itemBuilder: (ctx, i) {
              final selected = provider.selectedMonth == i + 1;
              return GestureDetector(
                onTap: () => provider.setMonth(i + 1),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color:        selected
                                      ? const Color(0xFF2E7D32)
                                      : Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: selected
                                 ? const Color(0xFF2E7D32)
                                 : Colors.green.shade200),
                  ),
                  child: Text(months[i],
                    style: TextStyle(
                      color:      selected ? Colors.white : Colors.green.shade800,
                      fontWeight: FontWeight.w600,
                      fontSize:   13,
                    )),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGetRecommendationsButton(CropProvider provider) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: provider.isLoading
            ? null
            : () {
                provider.loadRecommendations();
                Navigator.pushNamed(context, '/recommendations');
              },
        icon: provider.isLoading
            ? const SizedBox(
                width:  20, height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.agriculture),
        label: Text(
          provider.isLoading ? 'Loading...' : 'Get Crop Recommendations',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildQuickStats(CropProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Data Coverage',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Row(
          children: [
            _statCard('Districts', '${provider.districts.length}', Icons.location_on),
            const SizedBox(width: 12),
            _statCard('Years', '14+', Icons.calendar_today),
            const SizedBox(width: 12),
            _statCard('Records', '40K+', Icons.storage),          ],
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade100),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF2E7D32), size: 24),
            const SizedBox(height: 8),
            Text(value,
              style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32))),
            Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('About CropAI'),
        content: const Text(
          'CropAI uses 14 years of market data from Karnataka mandis '
          'to predict which crops will give the best returns each season.\n\n'
          'Data source: Agmarknet (Government of India)\n'
          'Model: XGBoost ML classifier'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close')),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:personal_expense_tracker/data/web_services/currency_api.dart';
import 'package:personal_expense_tracker/utils/app_colors.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  final CurrencyApi _currencyApi = CurrencyApi();
  
  Map<String, double> _rates = {};
  bool _isLoading = true;
  String? _errorMessage;
  String _lastUpdate = '';

  @override
  void initState() {
    super.initState();
    _fetchRates();
  }

  Future<void> _fetchRates() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final rates = await _currencyApi.getExchangeRates();
      setState(() {
        _rates = rates;
        _lastUpdate = DateTime.now().toString().substring(0, 16);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _getCurrencyName(String code) {
    switch (code) {
      case 'USD': return 'US Dollar';
      case 'EUR': return 'Euro';
      case 'GBP': return 'British Pound';
      case 'SAR': return 'Saudi Riyal';
      case 'AED': return 'UAE Dirham';
      case 'KWD': return 'Kuwaiti Dinar';
      default: return code;
    }
  }

  String _getCurrencyFlag(String code) {
    switch (code) {
      case 'USD': return '🇺🇸';
      case 'EUR': return '🇪🇺';
      case 'GBP': return '🇬🇧';
      case 'SAR': return '🇸🇦';
      case 'AED': return '🇦🇪';
      case 'KWD': return '🇰🇼';
      default: return '🏦';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Rates'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchRates,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchRates,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(_errorMessage!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchRates,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: AppColors.black,
                          ),
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _rates.length,
                    itemBuilder: (context, index) {
                      final currency = _rates.keys.elementAt(index);
                      final rate = _rates[currency]!;
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: Text(
                            _getCurrencyFlag(currency),
                            style: const TextStyle(fontSize: 32),
                          ),
                          title: Text(
                            _getCurrencyName(currency),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(currency),
                          trailing: Text(
                            '${rate.toStringAsFixed(2)} EGP',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
      bottomNavigationBar: _lastUpdate.isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(12),
              color: AppColors.grey200,
              child: Center(
                child: Text(
                  'Last updated: $_lastUpdate',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            )
          : null,
    );
  }
}
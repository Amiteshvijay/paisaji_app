import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/features/home/data/insurance_data.dart';
import 'package:zeokash/shared/widgets/cards/service_icon.dart';
import 'package:zeokash/shared/widgets/inputs/custom_text_field.dart';

class ViewAllServicesScreen extends StatefulWidget {
  const ViewAllServicesScreen({super.key});

  @override
  State<ViewAllServicesScreen> createState() => _ViewAllServicesScreenState();
}

class _ViewAllServicesScreenState extends State<ViewAllServicesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _allCategories = [
    {
      'title': 'Recharge & Bills',
      'services': [
        {'label': 'Mobile Recharge', 'icon': Icons.phone_android},
        {'label': 'DTH Recharge', 'icon': Icons.tv},
        {'label': 'Postpaid Bill', 'icon': Icons.receipt_long},
        {'label': 'Google Play', 'icon': Icons.play_arrow_outlined},
        {'label': 'FASTag Recharge', 'icon': Icons.directions_car_outlined},
        {'label': 'Credit Card Bill', 'icon': Icons.credit_card},
      ],
    },
    {
      'title': 'Utilities',
      'services': [
        {'label': 'Electricity', 'icon': Icons.lightbulb_outline},
        {'label': 'Loan EMI', 'icon': Icons.account_balance_wallet_outlined},
        {'label': 'Gas Cylinder', 'icon': Icons.local_fire_department_outlined},
        {'label': 'Broadband', 'icon': Icons.router_outlined},
        {'label': 'Water Bill', 'icon': Icons.water_drop_outlined},
        {'label': 'Prepaid Meter', 'icon': Icons.speed_outlined},
      ],
    },
    {
      'title': 'Vehicle & Insurance Payments',
      'services': [
        {'label': 'FASTag', 'icon': Icons.directions_car_outlined},
        {'label': 'Car Insurance', 'icon': Icons.directions_car},
        {'label': 'Bike Insurance', 'icon': Icons.two_wheeler},
        {'label': 'e-Challan', 'icon': Icons.receipt_outlined},
      ],
    },
  ];

  void _handleServiceTap(BuildContext context, String label) {
    final l = label.toLowerCase();
    if (l.contains('mobile')) {
      context.push('/recharge/mobile');
    } else if (l.contains('dth')) {
      context.push('/recharge/dth');
    } else if (l.contains('google play')) {
      context.push('/recharge/plans', extra: '9876543210');
    } else if (l.contains('electricity') || l.contains('postpaid') || l.contains('broadband') || l.contains('water') || l.contains('gas')) {
      context.push('/electricity/providers');
    } else if (l.contains('credit card')) {
      context.push('/credit-card/providers');
    } else if (l.contains('fastag')) {
      context.push('/fastag/providers');
    } else if (l.contains('challan')) {
      launchUrl(Uri.parse('https://echallan.parivahan.nic.in/index/accused-challan'), mode: LaunchMode.externalApplication);
    } else if (l.contains('loan')) {
      context.go('/loan');
    } else if (l.contains('car insurance')) {
      final item = kInsuranceOffers.firstWhere((i) => i.id == 'car_insurance_4w', orElse: () => kInsuranceOffers.first);
      context.push('/insurance/detail', extra: item);
    } else if (l.contains('bike insurance')) {
      final item = kInsuranceOffers.firstWhere((i) => i.id == 'bike_insurance_2w', orElse: () => kInsuranceOffers.first);
      context.push('/insurance/detail', extra: item);
    } else {
      context.push('/electricity/providers');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredCategories = _allCategories.map((cat) {
      final filteredServices = (cat['services'] as List<Map<String, dynamic>>).where((s) {
        return (s['label'] as String).toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
      return {
        'title': cat['title'],
        'services': filteredServices,
      };
    }).where((cat) => (cat['services'] as List).isNotEmpty).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Services', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar above Recharge & Bills section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CustomTextField(
                  controller: _searchController,
                  hintText: 'Search services, billers...',
                  prefixIcon: const Icon(Icons.search, color: AppTheme.secondaryText),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),

              if (filteredCategories.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Center(child: Text('No services found matching your search.', style: TextStyle(color: AppTheme.secondaryText))),
                ),

              ...filteredCategories.map((cat) {
                return Column(
                  children: [
                    _buildCategorySection(
                      context,
                      title: cat['title'] as String,
                      services: cat['services'] as List<Map<String, dynamic>>,
                    ),
                    const SizedBox(height: 32),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context, {required String title, required List<Map<String, dynamic>> services}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.secondaryText,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          color: AppTheme.surface,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.60,
            ),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final label = services[index]['label'] as String;
              return ServiceIcon(
                label: label,
                icon: services[index]['icon'],
                onTap: () => _handleServiceTap(context, label),
              );
            },
          ),
        ),
      ],
    );
  }
}

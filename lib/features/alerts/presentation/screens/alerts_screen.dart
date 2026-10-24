import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/shared/widgets/buttons/primary_button.dart';
import 'package:zeokash/shared/widgets/buttons/secondary_button.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Bills', 'Cards', 'Security'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 50,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;
                return ChoiceChip(
                  label: Text(
                    filter,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.primaryText,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppTheme.primaryNavy,
                  backgroundColor: AppTheme.surface,
                  side: BorderSide(color: isSelected ? AppTheme.primaryNavy : AppTheme.border),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedFilter = filter);
                    }
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildAlertCard(
                  context,
                  title: 'Electricity bill due tomorrow',
                  amount: 1840.0,
                  subtitle: 'Due 13 Aug',
                  type: 'Bills',
                  isUrgent: true,
                  onPrimaryTap: () {
                    context.push('/payment/review', extra: {
                      'title': 'BESCOM Electricity',
                      'subtitle': 'A/C: 9876543210',
                      'amount': 1840.0,
                    });
                  },
                ),
                const SizedBox(height: 16),
                _buildAlertCard(
                  context,
                  title: 'HDFC Credit Card due soon',
                  amount: 8500.0,
                  subtitle: '4 days left',
                  type: 'Cards',
                  isUrgent: false,
                  onPrimaryTap: () {
                    context.push('/payment/review', extra: {
                      'title': 'HDFC Bank Credit Card',
                      'subtitle': '•••• 4321',
                      'amount': 8500.0,
                    });
                  },
                ),
                const SizedBox(height: 16),
                _buildInfoAlertCard(
                  title: 'Mobile plan expires in 2 days',
                  subtitle: 'Airtel Prepaid • 98765 43210',
                  buttonText: 'Recharge',
                  onTap: () {
                    context.push('/recharge/plans', extra: '9876543210');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(
    BuildContext context, {
    required String title,
    required double amount,
    required String subtitle,
    required String type,
    required bool isUrgent,
    required VoidCallback onPrimaryTap,
  }) {
    // Only show if it matches filter
    if (_selectedFilter != 'All' && _selectedFilter != type) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUrgent ? AppTheme.error.withValues(alpha: 0.05) : AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUrgent ? AppTheme.error.withValues(alpha: 0.3) : AppTheme.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isUrgent ? Icons.warning_amber_rounded : Icons.calendar_today,
                color: isUrgent ? AppTheme.error : AppTheme.warning,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isUrgent ? AppTheme.error : AppTheme.primaryText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('₹${amount.toStringAsFixed(0)}', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: AppTheme.secondaryText, fontSize: 13)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  text: 'Pay Now',
                  onPressed: onPrimaryTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoAlertCard({
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    if (_selectedFilter != 'All' && _selectedFilter != 'Bills') return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: AppTheme.primaryBlue, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primaryBlue),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(color: AppTheme.secondaryText, fontSize: 13)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  text: buttonText,
                  onPressed: onTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

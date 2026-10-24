import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/shared/widgets/inputs/search_field.dart';

class CcProvidersScreen extends StatelessWidget {
  const CcProvidersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final providers = [
      'HDFC Bank Credit Card',
      'SBI Credit Card',
      'ICICI Bank Credit Card',
      'Axis Bank Credit Card',
      'Kotak Mahindra Bank Credit Card',
      'Standard Chartered Credit Card',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit Card Bill', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: SearchField(
              hintText: 'Search Bank',
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: providers.length,
              separatorBuilder: (context, index) => const Divider(color: AppTheme.border, height: 1),
              itemBuilder: (context, index) {
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  leading: const CircleAvatar(
                    backgroundColor: AppTheme.background,
                    child: Icon(Icons.credit_card, color: AppTheme.primaryBlue),
                  ),
                  title: Text(providers[index], style: const TextStyle(fontWeight: FontWeight.w500)),
                  trailing: const Icon(Icons.chevron_right, color: AppTheme.secondaryText),
                  onTap: () {
                    context.push('/credit-card/pay', extra: providers[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

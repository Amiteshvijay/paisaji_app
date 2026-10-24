import 'package:flutter_test/flutter_test.dart';
import 'package:zeokash/features/wallet/data/wallet_model.dart';

void main() {
  group('WalletData Model Tests', () {
    test('WalletData parsing from JSON', () {
      final json = {
        'wallet_id': '12345678-1234-1234-1234-1234567890ab',
        'status': 'ACTIVE',
        'cash_balance': '1850.00',
        'reward_balance': '125.00',
        'reserved_amount': '0.00',
        'available_cash_balance': '1850.00',
        'available_balance': '1975.00',
        'currency': 'INR',
        'kyc_level': 'FULL',
        'is_locked': false,
      };

      final wallet = WalletData.fromJson(json);

      expect(wallet.walletId, '12345678-1234-1234-1234-1234567890ab');
      expect(wallet.status, 'ACTIVE');
      expect(wallet.cashBalance, 1850.0);
      expect(wallet.rewardBalance, 125.0);
      expect(wallet.availableBalance, 1975.0);
      expect(wallet.isLocked, false);
    });

    test('WalletTopup model parsing', () {
      final json = {
        'id': 'TOPUP_001',
        'amount': '1000.00',
        'status': 'CREATED',
        'reference': 'ZKT261007ABC123',
        'upi': {
          'vpa': 'zeokash@icici',
          'payee_name': 'ZeoKash',
          'note': 'ZKT261007ABC123',
          'upi_uri': 'upi://pay?pa=zeokash@icici&pn=ZeoKash&am=1000.00&cu=INR&tn=ZKT261007ABC123',
        },
      };

      final topup = WalletTopup.fromJson(json);
      expect(topup.id, 'TOPUP_001');
      expect(topup.amount, 1000.0);
      expect(topup.status, 'CREATED');
      expect(topup.reference, 'ZKT261007ABC123');
      expect(topup.upiVpa, 'zeokash@icici');
      expect(topup.upiPayeeName, 'ZeoKash');
      expect(topup.upiNote, 'ZKT261007ABC123');
      expect(topup.upiUri, 'upi://pay?pa=zeokash@icici&pn=ZeoKash&am=1000.00&cu=INR&tn=ZKT261007ABC123');
    });

    test('WalletTxItem model parsing', () {
      final json = {
        'id': 'TX_100',
        'transaction_type': 'SPEND',
        'reference_type': 'SPEND_ORDER',
        'reference_id': 'ORD_777',
        'amount': '299.00',
        'status': 'POSTED',
        'description': 'Airtel Recharge',
        'created_at': '2026-10-07T12:00:00Z',
      };

      final item = WalletTxItem.fromJson(json);
      expect(item.id, 'TX_100');
      expect(item.transactionType, 'SPEND');
      expect(item.amount, 299.0);
      expect(item.description, 'Airtel Recharge');
    });
  });
}

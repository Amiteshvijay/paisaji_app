import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zeokash/features/wallet/data/wallet_repository.dart';
import 'package:zeokash/features/wallet/presentation/providers/wallet_provider.dart';

class WalletSecurityScreen extends ConsumerStatefulWidget {
  const WalletSecurityScreen({super.key});

  @override
  ConsumerState<WalletSecurityScreen> createState() => _WalletSecurityScreenState();
}

class _WalletSecurityScreenState extends ConsumerState<WalletSecurityScreen> {
  bool _isLoading = false;

  Future<void> _toggleLockStatus(bool currentLockState) async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(walletRepositoryProvider);
      if (currentLockState) {
        await repo.unlockWallet();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Wallet unlocked successfully.'), backgroundColor: Colors.green),
          );
        }
      } else {
        await repo.lockWallet();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Wallet temporarily locked.'), backgroundColor: Colors.orange),
          );
        }
      }
      ref.invalidate(walletDataProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Action failed: '), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletAsync = ref.watch(walletDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Wallet Security', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: walletAsync.when(
        data: (wallet) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            SwitchListTile(
              title: Text('Temporarily Lock Wallet', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              subtitle: Text(
                wallet.isLocked
                    ? 'Wallet is currently LOCKED. All wallet payments and top-ups are disabled.'
                    : 'Prevent unauthorized transactions by locking your wallet.',
                style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
              ),
              value: wallet.isLocked,
              onChanged: _isLoading ? null : (_) => _toggleLockStatus(wallet.isLocked),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.phonelink_lock),
              title: Text('Single Device Security', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
              subtitle: Text('Wallet transactions are bound to your active registered device.', style: GoogleFonts.outfit(fontSize: 12)),
            ),
            ListTile(
              leading: const Icon(Icons.pin),
              title: Text('M-PIN Protection', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
              subtitle: Text('M-PIN required for step-up authentication and high-risk actions.', style: GoogleFonts.outfit(fontSize: 12)),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error loading security status: ')),
      ),
    );
  }
}

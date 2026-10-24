import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/features/auth/providers/auth_provider.dart';
import 'package:zeokash/shared/widgets/buttons/primary_button.dart';
import 'package:zeokash/core/network/error_handler.dart';

class MpinResetConfirmScreen extends ConsumerStatefulWidget {
  final String resetToken;

  const MpinResetConfirmScreen({super.key, required this.resetToken});

  @override
  ConsumerState<MpinResetConfirmScreen> createState() => _MpinResetConfirmScreenState();
}

class _MpinResetConfirmScreenState extends ConsumerState<MpinResetConfirmScreen> {
  final TextEditingController _newMpinController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _isConfirming = false;
  bool _isLoading = false;

  void _onDigitPressed(String digit) {
    setState(() {
      if (!_isConfirming) {
        if (_newMpinController.text.length < 4) {
          _newMpinController.text += digit;
          if (_newMpinController.text.length == 4) {
            Future.delayed(const Duration(milliseconds: 200), () {
              if (mounted) setState(() => _isConfirming = true);
            });
          }
        }
      } else {
        if (_confirmController.text.length < 4) {
          _confirmController.text += digit;
          if (_confirmController.text.length == 4) {
            _submitNewMpin();
          }
        }
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (!_isConfirming) {
        if (_newMpinController.text.isNotEmpty) {
          _newMpinController.text = _newMpinController.text.substring(0, _newMpinController.text.length - 1);
        }
      } else {
        if (_confirmController.text.isNotEmpty) {
          _confirmController.text = _confirmController.text.substring(0, _confirmController.text.length - 1);
        } else {
          setState(() => _isConfirming = false);
        }
      }
    });
  }

  Future<void> _submitNewMpin() async {
    final newMpin = _newMpinController.text;
    final confirm = _confirmController.text;

    if (newMpin.length != 4 || confirm.length != 4) return;

    if (newMpin != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('M-PINs do not match. Please try again.')),
      );
      setState(() {
        _confirmController.clear();
        _isConfirming = false;
        _newMpinController.clear();
      });
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(authControllerProvider.notifier).confirmMpinReset(widget.resetToken, newMpin, confirm);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('M-PIN reset successfully!')),
        );
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        final msg = getFriendlyErrorMessage(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg.isNotEmpty ? msg : 'Failed to reset M-PIN')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentText = _isConfirming ? _confirmController.text : _newMpinController.text;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New M-PIN'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_isConfirming) {
              setState(() {
                _isConfirming = false;
                _confirmController.clear();
              });
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(),
              Text(
                _isConfirming ? 'Confirm New M-PIN' : 'Enter New M-PIN',
                style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _isConfirming ? 'Re-enter your new 4-digit M-PIN' : 'Choose a new 4-digit M-PIN for Paisaजी',
                style: const TextStyle(color: AppTheme.secondaryText, fontSize: 14),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final isFilled = index < currentText.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: isFilled ? AppTheme.primaryBlue : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primaryBlue, width: 2),
                    ),
                  );
                }),
              ),
              const Spacer(),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                childAspectRatio: 2.2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 16,
                children: [
                  ...['1', '2', '3', '4', '5', '6', '7', '8', '9'].map((digit) => InkWell(
                    onTap: () => _onDigitPressed(digit),
                    borderRadius: BorderRadius.circular(16),
                    child: Center(
                      child: Text(digit, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w600)),
                    ),
                  )),
                  const SizedBox.shrink(),
                  InkWell(
                    onTap: () => _onDigitPressed('0'),
                    borderRadius: BorderRadius.circular(16),
                    child: const Center(
                      child: Text('0', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  InkWell(
                    onTap: _onBackspace,
                    borderRadius: BorderRadius.circular(16),
                    child: const Center(
                      child: Icon(Icons.backspace_outlined),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: _isConfirming ? 'Reset & Save' : 'Continue',
                isLoading: _isLoading,
                onPressed: currentText.length == 4 ? _submitNewMpin : () {},
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

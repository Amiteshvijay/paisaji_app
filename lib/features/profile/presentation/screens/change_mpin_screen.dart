import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/features/auth/providers/auth_provider.dart';
import 'package:zeokash/shared/widgets/buttons/primary_button.dart';
import 'package:zeokash/core/network/error_handler.dart';

class ChangeMpinScreen extends ConsumerStatefulWidget {
  const ChangeMpinScreen({super.key});

  @override
  ConsumerState<ChangeMpinScreen> createState() => _ChangeMpinScreenState();
}

class _ChangeMpinScreenState extends ConsumerState<ChangeMpinScreen> {
  final TextEditingController _currentMpinController = TextEditingController();
  final TextEditingController _newMpinController = TextEditingController();
  final TextEditingController _confirmMpinController = TextEditingController();
  int _step = 0; // 0: current, 1: new, 2: confirm
  bool _isLoading = false;

  void _onDigitPressed(String digit) {
    setState(() {
      if (_step == 0) {
        if (_currentMpinController.text.length < 4) {
          _currentMpinController.text += digit;
          if (_currentMpinController.text.length == 4) {
            Future.delayed(const Duration(milliseconds: 150), () {
              if (mounted) setState(() => _step = 1);
            });
          }
        }
      } else if (_step == 1) {
        if (_newMpinController.text.length < 4) {
          _newMpinController.text += digit;
          if (_newMpinController.text.length == 4) {
            Future.delayed(const Duration(milliseconds: 150), () {
              if (mounted) setState(() => _step = 2);
            });
          }
        }
      } else if (_step == 2) {
        if (_confirmMpinController.text.length < 4) {
          _confirmMpinController.text += digit;
          if (_confirmMpinController.text.length == 4) {
            _submitChange();
          }
        }
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (_step == 0) {
        if (_currentMpinController.text.isNotEmpty) {
          _currentMpinController.text = _currentMpinController.text.substring(0, _currentMpinController.text.length - 1);
        }
      } else if (_step == 1) {
        if (_newMpinController.text.isNotEmpty) {
          _newMpinController.text = _newMpinController.text.substring(0, _newMpinController.text.length - 1);
        } else {
          _step = 0;
        }
      } else if (_step == 2) {
        if (_confirmMpinController.text.isNotEmpty) {
          _confirmMpinController.text = _confirmMpinController.text.substring(0, _confirmMpinController.text.length - 1);
        } else {
          _step = 1;
        }
      }
    });
  }

  Future<void> _submitChange() async {
    final current = _currentMpinController.text;
    final newMpin = _newMpinController.text;
    final confirm = _confirmMpinController.text;

    if (newMpin != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New M-PIN and Confirm M-PIN do not match.')),
      );
      setState(() {
        _newMpinController.clear();
        _confirmMpinController.clear();
        _step = 1;
      });
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(authControllerProvider.notifier).changeMpin(current, newMpin, confirm);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('M-PIN changed successfully!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        final msg = getFriendlyErrorMessage(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg.isNotEmpty ? msg : 'Failed to change M-PIN')),
        );
        setState(() {
          _currentMpinController.clear();
          _newMpinController.clear();
          _confirmMpinController.clear();
          _step = 0;
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String get _title {
    if (_step == 0) return 'Current M-PIN';
    if (_step == 1) return 'New M-PIN';
    return 'Confirm New M-PIN';
  }

  String get _subtitle {
    if (_step == 0) return 'Enter your existing 4-digit M-PIN';
    if (_step == 1) return 'Enter a new 4-digit M-PIN';
    return 'Re-enter your new 4-digit M-PIN';
  }

  String get _currentText {
    if (_step == 0) return _currentMpinController.text;
    if (_step == 1) return _newMpinController.text;
    return _confirmMpinController.text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change M-PIN'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(),
              Text(_title, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(_subtitle, style: const TextStyle(color: AppTheme.secondaryText, fontSize: 14)),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final isFilled = index < _currentText.length;
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
                text: _step == 2 ? 'Change M-PIN' : 'Continue',
                isLoading: _isLoading,
                onPressed: _currentText.length == 4
                    ? () {
                        if (_step < 2) {
                          setState(() => _step++);
                        } else {
                          _submitChange();
                        }
                      }
                    : () {},
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zeokash/core/theme/app_theme.dart';
import 'package:zeokash/core/theme/paisaji_brand.dart';

class MainNavigationScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainNavigationScreen({
    super.key,
    required this.navigationShell,
  });

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentBarIndex = navigationShell.currentIndex;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            top: BorderSide(
              color: AppTheme.border,
              width: 1.0,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0A2342).withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildNavItem(
                  context,
                  index: 0,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_filled,
                  label: 'Home',
                  isSelected: currentBarIndex == 0,
                ),
                _buildNavItem(
                  context,
                  index: 1,
                  icon: Icons.grid_view_outlined,
                  activeIcon: Icons.grid_view,
                  label: 'Services',
                  isSelected: currentBarIndex == 1,
                ),
                _buildCenterJiAiButton(
                  context,
                  isSelected: currentBarIndex == 2,
                ),
                _buildNavItem(
                  context,
                  index: 3,
                  icon: Icons.history_outlined,
                  activeIcon: Icons.history,
                  label: 'History',
                  isSelected: currentBarIndex == 3,
                ),
                _buildNavItem(
                  context,
                  index: 4,
                  icon: Icons.account_balance_wallet_outlined,
                  activeIcon: Icons.account_balance_wallet,
                  label: 'Loan',
                  isSelected: currentBarIndex == 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isSelected,
  }) {
    final color = isSelected ? AppTheme.primaryBlue : AppTheme.secondaryText;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onTap(context, index),
          splashColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
          highlightColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                size: 24,
                color: color,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontFamily: 'Inter',
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterJiAiButton(
    BuildContext context, {
    required bool isSelected,
  }) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onTap(context, 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: const Offset(0, -8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                  border: Border.all(
                    color: isSelected ? const Color(0xFF007BFF) : const Color(0xFFBFDBFE),
                    width: isSelected ? 2.5 : 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF007BFF).withValues(alpha: isSelected ? 0.35 : 0.20),
                      blurRadius: isSelected ? 12 : 8,
                      offset: const Offset(0, 4),
                      spreadRadius: isSelected ? 1 : 0,
                    ),
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    PaisaJiBrand.monogram,
                    width: 32,
                    height: 32,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -6),
              child: Text(
                'Ji-AI',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                  fontFamily: 'Inter',
                  color: isSelected ? const Color(0xFF0047AB) : const Color(0xFF007BFF),
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

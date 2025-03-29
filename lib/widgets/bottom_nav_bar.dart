import 'package:agrotech_hacakaton/core/localization/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: local?.home ?? 'Home',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person),
          label: local?.profile ?? 'Profile',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.settings),
          label: local?.settings ?? 'Settings',
        ),
      ],
    );
  }
}

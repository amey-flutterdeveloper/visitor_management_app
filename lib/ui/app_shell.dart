import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/app_theme.dart';
import '../logic/visitor/visitor_bloc.dart';
import '../logic/visitor/visitor_event.dart';
import 'dashboard_page.dart';
import 'scanner_page.dart';
import 'visitor_list_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  DateTime? _lastBackPress;

  static const Color _selectedPurple = Color(0xFF7E57C2);
  static const Color _lightPurple = Color(0xFFEDE7F6);

  final List<Widget> _pages = const [
    DashboardPage(),
    VisitorListPage(),
    ScannerPage(),
  ];

  void _onDestinationSelected(int index) {
    if (_index == index) return;

    setState(() {
      _index = index;
      _lastBackPress = null;
    });

    if (index == 0 || index == 1) {
      context.read<VisitorBloc>().add(const VisitorsRequested());
    }
  }

  Future<void> _handleBack() async {
    if (_index != 0) {
      setState(() {
        _index = 0;
        _lastBackPress = null;
      });

      context.read<VisitorBloc>().add(const VisitorsRequested());
      return;
    }

    final now = DateTime.now();
    final lastPress = _lastBackPress;

    if (lastPress == null ||
        now.difference(lastPress) > const Duration(seconds: 2)) {
      _lastBackPress = now;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.exit_to_app_rounded, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('Press back again to exit')),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.ink,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            duration: const Duration(seconds: 2),
          ),
        );

      return;
    }

    await SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleBack();
        }
      },
      child: Scaffold(
        extendBody: true,
        body: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: _index,
            children: _pages,
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: AppTheme.border,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.ink.withValues(alpha: 0.09),
                  blurRadius: 24,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: NavigationBarTheme(
                data: NavigationBarThemeData(
                  height: 72,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  indicatorColor: _lightPurple,
                  indicatorShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
                    (states) {
                      final isSelected = states.contains(WidgetState.selected);

                      return IconThemeData(
                        color: isSelected ? _selectedPurple : AppTheme.muted,
                        size: isSelected ? 23 : 22,
                      );
                    },
                  ),
                  labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
                    (states) {
                      final isSelected = states.contains(WidgetState.selected);

                      return TextStyle(
                        color: isSelected ? _selectedPurple : AppTheme.muted,
                        fontSize: 11,
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w500,
                      );
                    },
                  ),
                ),
                child: NavigationBar(
                  selectedIndex: _index,
                  onDestinationSelected: _onDestinationSelected,
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.grid_view_rounded),
                      label: 'Dashboard',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.people_alt_outlined),
                      label: 'Visitors',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.qr_code_scanner_rounded),
                      label: 'Scan QR',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:visitor_management_app/models/visitor.dart';
import 'package:visitor_management_app/ui/app_shell.dart';
import 'package:visitor_management_app/ui/dashboard_page.dart';
import 'package:visitor_management_app/ui/scanner_page.dart';
import 'package:visitor_management_app/ui/visitor_details_page.dart';
import 'package:visitor_management_app/ui/visitor_form_page.dart';
import 'package:visitor_management_app/ui/visitor_list_page.dart';
import 'package:visitor_management_app/ui/splash_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/',
      name: 'initial',
      builder: (context, state) => const AppShell(),
    ),
    GoRoute(
      path: '/dashboard',
      name: 'dashboard',
      builder: (context, state) => const DashboardPage(),
    ),
    GoRoute(
      path: '/visitors',
      name: 'visitors',
      builder: (context, state) => const VisitorListPage(),
    ),
    GoRoute(
      path: '/visitors/add',
      name: 'addVisitor',
      builder: (context, state) => const VisitorFormPage(),
    ),
    GoRoute(
      path: '/visitors/details',
      name: 'visitorDetails',
      builder: (context, state) {
        final visitor = state.extra;

        if (visitor is! Visitor) {
          return const InvalidRoutePage(
            message: 'Visitor details are unavailable.',
          );
        }

        return VisitorDetailsPage(visitor: visitor);
      },
    ),
    GoRoute(
      path: '/visitors/edit',
      name: 'editVisitor',
      builder: (context, state) {
        final visitor = state.extra;

        if (visitor is! Visitor) {
          return const InvalidRoutePage(
            message: 'Visitor information is unavailable for editing.',
          );
        }

        return VisitorFormPage(visitor: visitor);
      },
    ),
    GoRoute(
      path: '/scanner',
      name: 'scanner',
      builder: (context, state) => const ScannerPage(),
    ),
  ],
);

class InvalidRoutePage extends StatelessWidget {
  const InvalidRoutePage({
    required this.message,
    super.key,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unable to open page'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 48,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => context.go('/'),
                child: const Text('Back to dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

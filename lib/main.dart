import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:visitor_management_app/router/app_router.dart';

import 'core/app_theme.dart';
import 'data/visitor_repository.dart';
import 'logic/visitor/visitor_bloc.dart';
import 'logic/visitor/visitor_event.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VisitorManagementApp());
}

class VisitorManagementApp extends StatelessWidget {
  const VisitorManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<VisitorRepository>(
      create: (_) => VisitorRepository(),
      child: BlocProvider<VisitorBloc>(
        create: (context) => VisitorBloc(
          context.read<VisitorRepository>(),
        )..add(const VisitorsRequested()),
        child: MaterialApp.router(
          title: 'Visitor Management',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          routerConfig: appRouter,
        ),
      ),
    );
  }
}

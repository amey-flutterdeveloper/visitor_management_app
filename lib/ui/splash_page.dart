
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/app_theme.dart';

class SplashPage extends StatefulWidget {
const SplashPage({super.key});

@override
State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
static const Color _purple = Color(0xFF7E57C2);

@override
void initState() {
super.initState();

Future.delayed(const Duration(seconds: 2), () {
if (mounted) {
context.go('/');
}
});
}

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: _purple,
body: Center(
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
Container(
width: 96,
height: 96,
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(28),
),
child: const Icon(
Icons.badge_rounded,
size: 58,
color: _purple,
),
),
const SizedBox(height: 24),
const Text(
'Visitor Management',
textAlign: TextAlign.center,
style: TextStyle(
color: Colors.white,
fontSize: 26,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 10),
Text(
'Smart. Secure. Simple.',
style: TextStyle(
color: Colors.white.withValues(alpha: 0.85),
fontSize: 14,
),
),
const SizedBox(height: 32),
const SizedBox(
width: 26,
height: 26,
child: CircularProgressIndicator(
strokeWidth: 2.5,
color: Colors.white,
),
),
],
),
),
);
}
}
